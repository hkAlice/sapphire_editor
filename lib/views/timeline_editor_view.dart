import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_text_field/json_text_field.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/utils/timeline_sanity.dart';
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
  TimelineModel _timeline = TimelineModel(name: "Brand new timeline");
  final JsonTextFieldController _jsonTextFieldController = JsonTextFieldController();
  List<SanityItem> _sanityCheck = [];

  @override
  bool get wantKeepAlive => true;

  bool _parseJSONToTimeline() {
    try {
      var jsonDec = jsonDecode(_jsonTextFieldController.text);
      if(jsonDec != null) {
        _timeline = TimelineModel.fromJson(jsonDec);
        _sanityCheck = TimelineSanitySvc.run(_timeline);
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
    _sanityCheck = TimelineSanitySvc.run(_timeline);

    setState(() {
      
    });
  }

  bool _parseTimelineToJSON() {
    _jsonTextFieldController.text = jsonEncode(_timeline.toJson());
    _jsonTextFieldController.formatJson(sortJson: true);

    return true;
  }

  @override
  void initState() {
    _timeline.addNewPhase();
    _timeline.addNewCondition();

    super.initState();
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
            trailing: SanityCallWidget(items: _sanityCheck,)
          ),
          const Divider(),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: TimelineList(
                          timeline: _timeline,
                          onUpdate: (timeline) {
                            _onTimelineDataUpdate();
                        },),
                      ),
                    ),
                    const VerticalDivider(),
                    Flexible(
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
                            decoration: const InputDecoration(
                              fillColor: Color(0xFF141414),
                              border: InputBorder.none,
                              hintText: "To load a timeline, paste the JSON here."
                            ),
                            onChanged: (value) {
                              _parseJSONToTimeline();
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
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Row(
                              children: [
                                ElevatedButton.icon(
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
                                  icon: const Icon(Icons.copy),
                                  label: const Text("Copy")
                                ),
                                const SizedBox(width: 8.0,),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _jsonTextFieldController.text));
                                    try {
                                      exportStringAsJson(_jsonTextFieldController.text, _timeline.name);
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
                                  icon: const Icon(Icons.download),
                                  label: const Text("Save")
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}