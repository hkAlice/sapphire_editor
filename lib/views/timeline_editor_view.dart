import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_text_field/json_text_field.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/widgets/page_header_widget.dart';
import 'package:sapphire_editor/widgets/sanity/sanity_call_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/timeline_list.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

class TimelineEditorView extends StatefulWidget {
  const TimelineEditorView({super.key});

  @override
  State<TimelineEditorView> createState() => _TimelineEditorViewState();
}

class _TimelineEditorViewState extends State<TimelineEditorView> {
  TimelineEditorSignal? _signal;

  @override
  void initState() {
    super.initState();
    _initializeSignal();
  }

  Future<void> _initializeSignal() async {
    final autosave = StorageHelper().getTable(StorageTable.autosaveTimeline);
    final autosaveKeys = await autosave.getAllKeys();

    TimelineModel? timeline;
    if(autosaveKeys.isNotEmpty) {
      try {
        final json = await autosave.get(autosaveKeys.last);
        timeline = TimelineModel.fromJson(jsonDecode(json));
      } catch (_) {
      }
    }

    setState(() {
      _signal = TimelineEditorSignal(timeline);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_signal == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SignalsProvider(
      signals: _signal!,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              PageHeaderWidget(
                title: "Timeline Editor",
                subtitle: "Outputs encounter timeline data in JSON",
                heading: Image.asset("assets/images/icon_trials.png"),
                trailing: SanityCallWidget(),
              ),
              const Divider(),
              Expanded(
                child: Center(
                  child: Watch((context) {
                      final actorId = _signal!.selectedActorId.value ?? 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 7,
                            child: TimelineList(
                              actorId: actorId,
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 4,
                            child: _JsonEditorPanel(),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JsonEditorPanel extends StatefulWidget {
  @override
  State<_JsonEditorPanel> createState() => _JsonEditorPanelState();
}

class _JsonEditorPanelState extends State<_JsonEditorPanel> {
  final JsonTextFieldController _jsonController = JsonTextFieldController();

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final json = signals.jsonOutput.value;
      if(!_jsonController.text.isNotEmpty || _jsonController.text != json) {
        _jsonController.text = json;
        _jsonController.formatJson(sortJson: true);
      }

      return Stack(
        children: [
          JsonTextField(
            controller: _jsonController,
            keyboardType: TextInputType.multiline,
            isFormatting: true,
            maxLines: null,
            expands: true,
            showErrorMessage: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).hoverColor,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16.0)
              ),
              hintText: "To load a timeline, paste the JSON here."
            ),
        onChanged: (value) {
          signals.setPendingJson(value);
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
                    Clipboard.setData(ClipboardData(text: _jsonController.text));
                    try {
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.fillColored,
                        title: const Text("Copied to clipboard."),
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    }
                    catch(e) {
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: "Copy",
                ),
                const SizedBox(width: 8.0,),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _jsonController.text));
                    try {
                      exportStringAsJson(_jsonController.text, signals.timeline.value.name);
                    }
                    catch(e) {
                      toastification.show(
                        context: context,
                        type: ToastificationType.error,
                        style: ToastificationStyle.fillColored,
                        title: const Text("Failed to save JSON."),
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
          Watch((context) {
            final lastSave = signals.lastAutosave.value;
            if(lastSave == null) return const SizedBox.shrink();

            return Positioned(
              bottom: 8,
              right: 8,
              child: Opacity(
                opacity: 0.5,
                child: FilledButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      const Icon(Icons.save),
                      const SizedBox(width: 6.0,),
                      Text(DateFormat("yyyy/MM/dd HH:mm").format(lastSave),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
        ],
      );
    });
  }
}
