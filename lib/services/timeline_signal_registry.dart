import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class TimelineSignalRegistry {
  TimelineSignalRegistry._();

  static final TimelineSignalRegistry instance = TimelineSignalRegistry._();

  TimelineEditorSignal? _signal;

  TimelineEditorSignal? get signal => _signal;

  void attach(TimelineEditorSignal signal) {
    _signal = signal;
  }
}
