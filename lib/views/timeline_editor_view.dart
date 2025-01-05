import 'dart:async';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_text_field/json_text_field.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/page_header_widget.dart';
import 'package:sapphire_editor/widgets/sanity/sanity_call_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_list.dart';
import 'package:toastification/toastification.dart';

class TimelineEditorView extends StatefulWidget {
  const TimelineEditorView({super.key});

  @override
  State<TimelineEditorView> createState() => _TimelineEditorViewState();
}

class _TimelineEditorViewState extends State<TimelineEditorView> with AutomaticKeepAliveClientMixin<TimelineEditorView> {
  TimelineModel? _timeline;
  final JsonTextFieldController _jsonTextFieldController = JsonTextFieldController();

  DateTime _lastAutosave = DateTime(0);
  Timer _autosaveTimer = Timer(const Duration(seconds: 3), () {});

  @override
  bool get wantKeepAlive => true;

  void _autosave(String json) async {
    var autosaveBox = StorageHelper().getTable(StorageTable.autosaveTimeline);
    var autosaveKeys = await autosaveBox.getAllKeys();

    if(autosaveKeys.isNotEmpty) {
      // todo: i hate hive (can't save timestamp ms as key because it's "out of range of 0xFFFFFFFF")
      // don't feel like adding a billion overhead for hive adapters and generators either

      int lastTimestamp = int.parse(autosaveKeys.last);
      _lastAutosave = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    }

    var timestamp = DateTime.now();

    // todo: only autosave every 5 minutes (need UI and stuff)
    _autosaveTimer.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 1), () async {
      await autosaveBox.put(timestamp.millisecondsSinceEpoch.toString(), json);

      _lastAutosave = timestamp;

      autosaveKeys = await autosaveBox.getAllKeys();
      
      int historySize = 15;

      if(autosaveKeys.length > historySize) {
        var clearHistory = autosaveKeys.take(autosaveKeys.length - historySize);
        await autosaveBox.deleteAll(clearHistory.toList());
      }

      setState(() {
        
      });
    });
  }

  bool _parseJSONToTimeline(String jsonStr) {
    try {
      var jsonDec = jsonDecode(jsonStr);
      if(jsonDec != null) {
        _timeline = TimelineModel.fromJson(jsonDec);

        setState(() {
          
        });

        return true;
      }
    }
    catch(e) {
      // ignore error
    }

    return false;
  }

  void _onTimelineDataUpdate() {
    _parseTimelineToJSON();
    _autosave(_jsonTextFieldController.text);
  }

  bool _parseTimelineToJSON() {
    _jsonTextFieldController.text = jsonEncode(_timeline!.toJson());
    _jsonTextFieldController.formatJson(sortJson: true);  
    //_autosave(_jsonTextFieldController.text);

    return true;
  }

  Future<bool> _recoverTimeline() async {
    bool hasTimeline = false;
    if(_timeline != null) {
      return true;
    }
    
    try {
      var autosave = StorageHelper().getTable(StorageTable.autosaveTimeline);
      var autosaveKeys = await autosave.getAllKeys();
      
      if(autosaveKeys.isNotEmpty) {
        hasTimeline = _parseJSONToTimeline(await autosave.get(autosaveKeys.last));
      }

      _parseTimelineToJSON();
    }
    catch(_) {
      hasTimeline = false;
    }

    if(!hasTimeline) {
      _timeline = TimelineModel(name: "Brand new timeline");
      _timeline!.addNewActor(
        bnpcName: "Ifrit",
        layoutId: 4126276,
        hp: 13884
      );
      _timeline!.addNewActor(
        bnpcName: "Ifrit Control",
        layoutId: 4126284,
        hp: 445
      );
      _timeline!.addNewActor(
        bnpcName: "Ifrit Nail 1",
        layoutId: 4126285,
        hp: 445
      );
      _timeline!.addNewPhase(_timeline!.actors.first);
      _timeline!.addNewCondition();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          PageHeaderWidget(
            title: "Timeline Editor",
            subtitle: "Outputs encounter timeline data in JSON",
            heading: Image.asset("assets/images/icon_trials.png"),
            trailing: SanityCallWidget(
              timelineModel: _timeline
            )
          ),
          const Divider(),
          FutureBuilder<bool>(
            future: _recoverTimeline(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return Container();
              }
              
              return Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 7,
                          child: TimelineList(
                            timeline: _timeline!,
                            onUpdate: (timeline) {
                              _onTimelineDataUpdate();
                            },
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 4,
                          child: Stack(
                            children: [
                              JsonTextField(
                                controller: _jsonTextFieldController,
                                keyboardType: TextInputType.multiline,
                                isFormatting: true,
                                maxLines: null,
                                expands: true,
                                showErrorMessage: true,
                                decoration: InputDecoration(
                                  fillColor: const Color(0xFF141414),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(16.0)
                                  ),
                                  hintText: "To load a timeline, paste the JSON here."
                                ),
                                onChanged: (value) {
                                  if(_parseJSONToTimeline(value)) {
                                    _autosave(value);
                                  }
                                },
                                commonTextStyle: const TextStyle(fontFamily: "monospace"),
                                keyHighlightStyle: const TextStyle(color: Color(0xFF7587A6)),
                                stringHighlightStyle: const TextStyle(color: Color(0xFF8F9D6A)),
                                numberHighlightStyle: const TextStyle(color: Color(0xFFCF6A4C)),
                                boolHighlightStyle: const TextStyle(color: Color(0xFFCF6A4C)),
                                nullHighlightStyle: const TextStyle(color: Colors.white),
                                specialCharHighlightStyle: const TextStyle(color: Colors.white),
                                enableSuggestions: false,
                                enableIMEPersonalizedLearning: false,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Row(
                                  children: [
                                    IconButton(
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _jsonTextFieldController.text));
                                        try {
                                          toastification.show(
                                            context: context,
                                            type: ToastificationType.success,
                                            style: ToastificationStyle.fillColored,
                                            title: const Text("Touch your monitor. It is warm, like flesh.\nBut it is not flesh.\nNot yet."),
                                            autoCloseDuration: const Duration(seconds: 3),
                                          );
                                        }
                                        catch(e) {
                                          // this plugin seems to fire errors at random
                                        }
                                      },
                                      icon: const Icon(Icons.copy_rounded),
                                      tooltip: "Copy",
                                    ),
                                    const SizedBox(width: 8.0,),
                                    IconButton(
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _jsonTextFieldController.text));
                                        try {
                                          exportStringAsJson(_jsonTextFieldController.text, _timeline!.name);
                                        }
                                        catch(e) {
                                          toastification.show(
                                            context: context,
                                            type: ToastificationType.error,
                                            style: ToastificationStyle.fillColored,
                                            title: const Text("Failed to save JSON.\nWe are beyond salvation."),
                                            autoCloseDuration: const Duration(seconds: 3),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.download_rounded),
                                      tooltip: "Save",
                                    ),
                                  ],
                                ),
                              ),
                              _lastAutosave.year == 0 ? Container() : Positioned(
                                bottom: 8,
                                right: 8,
                                child: Opacity(
                                  opacity: 0.5,
                                  child: FilledButton(
                                    onPressed: null,
                                    child: Row(
                                      children: [
                                        Icon(Icons.save),
                                        SizedBox(width: 6.0,),
                                        Text(DateFormat("yyyy/MM/dd HH:mm").format(_lastAutosave),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}