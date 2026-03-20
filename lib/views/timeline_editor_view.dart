import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:json_text_field/json_text_field.dart';
import 'package:sapphire_editor/models/timeline/phase_timepoint_hook.dart';
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
    final autosaveKeys = autosave.keys.map((k) => k.toString()).toList();

    TimelineModel? timeline;
    if(autosaveKeys.isNotEmpty) {
      try {
        final json = await autosave.get(autosaveKeys.last);
        timeline = TimelineModel.fromJson(jsonDecode(json));
      }
      catch(_) {}
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("New Timeline"),
                            content: const Text("Are you sure you want to start a new timeline? Unsaved changes will be lost."),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
                              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Confirm")),
                            ],
                          )
                        );
                        if(confirm == true) {
                          _signal?.createNewTimeline();
                        }
                      },
                      icon: const Icon(Icons.file_copy_rounded),
                      label: const Text("New Timeline"),
                    ),
                    const SizedBox(width: 16),
                    const SanityCallWidget(),
                  ],
                ),
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

class _JsonLineRange {
  final int start;
  final int end;

  const _JsonLineRange(this.start, this.end);
}

class _JsonEditorPanel extends StatefulWidget {
  @override
  State<_JsonEditorPanel> createState() => _JsonEditorPanelState();
}

class _JsonEditorPanelState extends State<_JsonEditorPanel> {
  static const double _defaultJsonLineHeight = 25.0;
  static const double _jsonLineHeightStep = 0.05;
  static const double _jsonLineHeightMin = 10.0;
  static const double _jsonLineHeightMax = 60.0;

  final JsonTextFieldController _jsonController = JsonTextFieldController();
  final ScrollController _jsonScrollController = ScrollController();

  double _jsonLineHeight = _defaultJsonLineHeight;

  int? _lastHandledAnchorRevision;
  int? _scheduledAnchorRevision;

  void _adjustJsonLineHeight(double delta) {
    setState(() {
      _jsonLineHeight = (_jsonLineHeight + delta)
          .clamp(_jsonLineHeightMin, _jsonLineHeightMax)
          .toDouble();
    });

    debugPrint(
        'JSON scroll debug line-height: ${_jsonLineHeight.toStringAsFixed(2)}');
  }

  void _resetJsonLineHeight() {
    setState(() {
      _jsonLineHeight = _defaultJsonLineHeight;
    });

    debugPrint(
        'JSON scroll debug line-height reset: ${_jsonLineHeight.toStringAsFixed(2)}');
  }

  @override
  void dispose() {
    _jsonScrollController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  void _scheduleJsonAnchorScrollIfNeeded(
      TimelineEditorSignal signals, TimelineJsonScrollAnchor? anchor) {
    if(anchor == null) {
      return;
    }

    if(anchor.revision == _lastHandledAnchorRevision ||
        anchor.revision == _scheduledAnchorRevision) {
      return;
    }

    _scheduledAnchorRevision = anchor.revision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) {
        return;
      }

      final handled = _scrollToAnchorIfNeeded(anchor);
      if(handled) {
        _lastHandledAnchorRevision = anchor.revision;
        signals.clearPendingJsonScrollAnchor(anchor.revision);
      }

      _scheduledAnchorRevision = null;
    });
  }

  bool _scrollToAnchorIfNeeded(TimelineJsonScrollAnchor anchor) {
    if(!_jsonScrollController.hasClients) {
      return false;
    }

    final line = _resolveAnchorLine(_jsonController.text, anchor);
    if(line == null) {
      return true;
    }

    final position = _jsonScrollController.position;
    final targetOffset = line * _jsonLineHeight;
    final viewportStart = position.pixels;
    final viewportEnd = viewportStart + position.viewportDimension;

    if(targetOffset >= viewportStart && targetOffset <= viewportEnd) {
      return true;
    }

    final centeredOffset =
        (targetOffset - (position.viewportDimension / 2) + (_jsonLineHeight / 2))
        .clamp(0.0, position.maxScrollExtent)
        .toDouble();

    _jsonScrollController.animateTo(
      centeredOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );

    return true;
  }

  int? _resolveAnchorLine(String jsonText, TimelineJsonScrollAnchor anchor) {
    if(jsonText.isEmpty) {
      return null;
    }

    final lines = const LineSplitter().convert(jsonText);
    if(lines.isEmpty) {
      return null;
    }

    return _resolveAnchorObjectStart(lines, anchor);
  }

  int? _resolveAnchorObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    switch(anchor.type) {
      case TimelineJsonAnchorType.actor:
        return _resolveActorObjectStart(lines, anchor);
      case TimelineJsonAnchorType.phase:
        return _resolvePhaseObjectStart(lines, anchor);
      case TimelineJsonAnchorType.schedule:
        return _resolveScheduleObjectStart(lines, anchor);
      case TimelineJsonAnchorType.timepoint:
        return _resolveTimepointObjectStart(lines, anchor);
      case TimelineJsonAnchorType.condition:
        return _resolveConditionObjectStart(lines, anchor);
      case TimelineJsonAnchorType.selector:
        return _resolveSelectorObjectStart(lines, anchor);
    }
  }

  int? _resolveActorObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final actorsRange = _findArrayRange(lines, key: 'actors');
    if(actorsRange == null) {
      return null;
    }

    return _findObjectStartByNumericId(lines, anchor.actorId, actorsRange) ??
        _firstObjectStartInRange(lines, actorsRange);
  }

  int? _resolvePhaseObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final actorStart = _resolveActorObjectStart(lines, anchor);
    if(actorStart == null) {
      return null;
    }

    final actorRange = _findObjectRangeFromStart(lines, actorStart);
    if(actorRange == null) {
      return actorStart;
    }

    final phasesRange = _findArrayRange(lines,
        key: 'phases', within: actorRange);
    if(phasesRange == null) {
      return actorStart;
    }

    return _findObjectStartByNumericId(lines, anchor.phaseId, phasesRange) ??
        actorStart;
  }

  int? _resolveScheduleObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final phaseStart = _resolvePhaseObjectStart(lines, anchor);
    if(phaseStart == null) {
      return null;
    }

    final phaseRange = _findObjectRangeFromStart(lines, phaseStart);
    if(phaseRange == null) {
      return phaseStart;
    }

    final hookKey = _hookArrayKey(anchor.scheduleId);
    if(hookKey != null) {
      final hookRange = _findArrayRange(lines, key: hookKey, within: phaseRange);
      return hookRange?.start ?? phaseStart;
    }

    final schedulesRange =
        _findArrayRange(lines, key: 'schedules', within: phaseRange);
    if(schedulesRange == null) {
      return phaseStart;
    }

    return _findObjectStartByNumericId(
            lines, anchor.scheduleId, schedulesRange) ??
        phaseStart;
  }

  int? _resolveTimepointObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final phaseStart = _resolvePhaseObjectStart(lines, anchor);
    if(phaseStart == null) {
      return null;
    }

    final phaseRange = _findObjectRangeFromStart(lines, phaseStart);
    if(phaseRange == null) {
      return phaseStart;
    }

    final hookKey = _hookArrayKey(anchor.scheduleId);
    if(hookKey != null) {
      final hookRange = _findArrayRange(lines, key: hookKey, within: phaseRange);
      if(hookRange == null) {
        return phaseStart;
      }

      return _findObjectStartByNumericId(
              lines, anchor.timepointId, hookRange) ??
          phaseStart;
    }

    final schedulesRange =
        _findArrayRange(lines, key: 'schedules', within: phaseRange);
    if(schedulesRange == null) {
      return phaseStart;
    }

    final scheduleStart =
        _findObjectStartByNumericId(lines, anchor.scheduleId, schedulesRange);
    if(scheduleStart == null) {
      return phaseStart;
    }

    final scheduleRange = _findObjectRangeFromStart(lines, scheduleStart);
    if(scheduleRange == null) {
      return scheduleStart;
    }

    final timepointsRange =
        _findArrayRange(lines, key: 'timepoints', within: scheduleRange);
    if(timepointsRange == null) {
      return scheduleStart;
    }

    return _findObjectStartByNumericId(
            lines, anchor.timepointId, timepointsRange) ??
        scheduleStart;
  }

  int? _resolveConditionObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final phaseStart = _resolvePhaseObjectStart(lines, anchor);
    if(phaseStart == null) {
      return null;
    }

    final phaseRange = _findObjectRangeFromStart(lines, phaseStart);
    if(phaseRange == null) {
      return phaseStart;
    }

    final triggersRange =
        _findArrayRange(lines, key: 'triggers', within: phaseRange);
    if(triggersRange == null) {
      return phaseStart;
    }

    return _findObjectStartByNumericId(
            lines, anchor.conditionId, triggersRange) ??
        phaseStart;
  }

  int? _resolveSelectorObjectStart(
      List<String> lines, TimelineJsonScrollAnchor anchor) {
    final selectorsRange = _findArrayRange(lines, key: 'selectors');
    if(selectorsRange == null) {
      return null;
    }

    return _findObjectStartByNumericId(
            lines, anchor.selectorId, selectorsRange) ??
        selectorsRange.start;
  }

  String? _hookArrayKey(int? scheduleId) {
    final hook = PhaseHookScheduleIds.hookFromScheduleId(scheduleId);
    return switch(hook) {
      PhaseTimepointHook.onEnter => 'onEnter',
      PhaseTimepointHook.onExit => 'onExit',
      null => null,
    };
  }

  _JsonLineRange? _findArrayRange(List<String> lines,
      {required String key, _JsonLineRange? within}) {
    final start = within?.start ?? 0;
    final end = within?.end ?? (lines.length - 1);
    final keyPattern = RegExp('"${RegExp.escape(key)}"\\s*:\\s*\\[');

    for(var line = start; line <= end; line++) {
      if(!keyPattern.hasMatch(lines[line])) {
        continue;
      }

      final closing =
          _findClosingLine(lines, line, '[', ']', maxLine: end);
      if(closing != null) {
        return _JsonLineRange(line, closing);
      }
    }

    return null;
  }

  _JsonLineRange? _findObjectRangeFromStart(List<String> lines, int startLine,
      {int? maxLine}) {
    final closing = _findClosingLine(lines, startLine, '{', '}',
        maxLine: maxLine);
    if(closing == null) {
      return null;
    }
    return _JsonLineRange(startLine, closing);
  }

  int? _findObjectStartByNumericId(
      List<String> lines, int? id, _JsonLineRange range) {
    if(id == null) {
      return null;
    }

    return _findObjectStartByIdPattern(
      lines,
      RegExp('"id"\\s*:\\s*$id\\b'),
      range,
    );
  }

  int? _findObjectStartByIdPattern(
      List<String> lines, RegExp idPattern, _JsonLineRange range) {
    final objectRanges = _findDirectChildObjectRanges(lines, range);
    for(final objectRange in objectRanges) {
      if(_isTopLevelObjectIdMatch(lines, objectRange, idPattern)) {
        return objectRange.start;
      }
    }

    return null;
  }

  List<_JsonLineRange> _findDirectChildObjectRanges(
      List<String> lines, _JsonLineRange arrayRange) {
    final objectRanges = <_JsonLineRange>[];
    var line = arrayRange.start + 1;

    while(line < arrayRange.end) {
      if(_containsTokenOutsideString(lines[line], '{')) {
        final objectEnd = _findClosingLine(
          lines,
          line,
          '{',
          '}',
          maxLine: arrayRange.end - 1,
        );

        if(objectEnd != null) {
          objectRanges.add(_JsonLineRange(line, objectEnd));
          line = objectEnd + 1;
          continue;
        }
      }

      line += 1;
    }

    return objectRanges;
  }

  bool _isTopLevelObjectIdMatch(
      List<String> lines, _JsonLineRange objectRange, RegExp idPattern) {
    final objectIndent = _leadingWhitespace(lines[objectRange.start]);
    final topLevelIndent = objectIndent + 2;

    for(var line = objectRange.start + 1; line <= objectRange.end; line++) {
      final raw = lines[line];
      final trimmed = raw.trimLeft();
      if(!trimmed.startsWith('"id"')) {
        continue;
      }

      if(_leadingWhitespace(raw) != topLevelIndent) {
        continue;
      }

      return idPattern.hasMatch(raw);
    }

    return false;
  }

  int _firstObjectStartInRange(List<String> lines, _JsonLineRange range) {
    final objectRanges = _findDirectChildObjectRanges(lines, range);
    if(objectRanges.isNotEmpty) {
      return objectRanges.first.start;
    }

    return range.start;
  }

  int _leadingWhitespace(String line) {
    var count = 0;
    while (count < line.length) {
      final code = line.codeUnitAt(count);
      if(code != 32 && code != 9) {
        break;
      }
      count += 1;
    }
    return count;
  }

  int? _findClosingLine(List<String> lines, int startLine, String open,
      String close, {int? maxLine}) {
    final max = maxLine ?? (lines.length - 1);
    final openCode = open.codeUnitAt(0);
    final closeCode = close.codeUnitAt(0);

    var depth = 0;
    var sawOpeningToken = false;

    for(var line = startLine; line <= max; line++) {
      final codeUnits = lines[line].codeUnits;
      var inString = false;
      var escaped = false;

      for(final unit in codeUnits) {
        if(inString) {
          if(escaped) {
            escaped = false;
            continue;
          }

          if(unit == 92) {
            escaped = true;
            continue;
          }

          if(unit == 34) {
            inString = false;
          }

          continue;
        }

        if(unit == 34) {
          inString = true;
          continue;
        }

        if(unit == openCode) {
          depth += 1;
          sawOpeningToken = true;
          continue;
        }

        if(unit == closeCode && sawOpeningToken) {
          depth -= 1;
          if(depth == 0) {
            return line;
          }
        }
      }
    }

    return null;
  }

  bool _containsTokenOutsideString(String line, String token) {
    final tokenCode = token.codeUnitAt(0);
    var inString = false;
    var escaped = false;

    for(final unit in line.codeUnits) {
      if(inString) {
        if(escaped) {
          escaped = false;
          continue;
        }

        if(unit == 92) {
          escaped = true;
          continue;
        }

        if(unit == 34) {
          inString = false;
        }

        continue;
      }

      if(unit == 34) {
        inString = true;
        continue;
      }

      if(unit == tokenCode) {
        return true;
      }
    }

    return false;
  }

  Widget _buildLineHeightDebugPanel(BuildContext context) {
    if(!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 8,
      bottom: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Decrease line height',
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => _adjustJsonLineHeight(-_jsonLineHeightStep),
              ),
              Text(
                'LH ${_jsonLineHeight.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              IconButton(
                tooltip: 'Increase line height',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _adjustJsonLineHeight(_jsonLineHeightStep),
              ),
              IconButton(
                tooltip: 'Reset line height',
                icon: const Icon(Icons.refresh_rounded, size: 16),
                onPressed: _resetJsonLineHeight,
              ),
              IconButton(
                tooltip: 'Copy line height',
                icon: const Icon(Icons.copy_rounded, size: 16),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _jsonLineHeight.toStringAsFixed(2)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final json = signals.jsonOutput.value;
      final pendingAnchor = signals.pendingJsonScrollAnchor.value;
      if(!_jsonController.text.isNotEmpty || _jsonController.text != json) {
        _jsonController.text = json;
        _jsonController.formatJson(sortJson: true);
      }

      _scheduleJsonAnchorScrollIfNeeded(signals, pendingAnchor);

      return Stack(
        children: [
          JsonTextField(
            controller: _jsonController,
            scrollController: _jsonScrollController,
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
            commonTextStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 14.0,
                            ),
                          ),
            keyHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFF7587A6),
                              fontSize: 14.0,
                            ),
                          ),
            stringHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFF8F9D6A),
                              fontSize: 14.0,
                            ),
                          ),
            numberHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFCF6A4C),
                              fontSize: 14.0,
                            ),
                          ),
            boolHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Color(0xFFCF6A4C),
                              fontSize: 14.0,
                            ),
                          ),
            nullHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
            specialCharHighlightStyle: GoogleFonts.lilex(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
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
                    catch(_) {
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

            return Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: signals.canUndo.value ? 0.8 : 0.3,
                    child: IconButton.filled(
                      onPressed: signals.canUndo.value ? () => signals.undo() : null,
                      icon: const Icon(Icons.undo_rounded),
                      tooltip: "Undo",
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Opacity(
                    opacity: signals.canRedo.value ? 0.8 : 0.3,
                    child: IconButton.filled(
                      onPressed: signals.canRedo.value ? () => signals.redo() : null,
                      icon: const Icon(Icons.redo_rounded),
                      tooltip: "Redo",
                    ),
                  ),
                  if(lastSave != null) ...[
                    const SizedBox(width: 8.0),
                    Opacity(
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
                  ],
                ],
              ),
            );
          }),
          _buildLineHeightDebugPanel(context),
        ],
      );
    });
  }
}
