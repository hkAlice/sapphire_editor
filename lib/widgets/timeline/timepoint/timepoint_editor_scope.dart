import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class TimepointEditorScope extends InheritedWidget {
  final TimelineEditorSignal signals;
  final int actorId;
  final int? phaseId;
  final int scheduleId;
  final int timepointId;

  const TimepointEditorScope({
    super.key,
    required this.signals,
    required this.actorId,
    required this.phaseId,
    required this.scheduleId,
    required this.timepointId,
    required super.child,
  });

  static TimepointEditorScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TimepointEditorScope>();
    assert(scope != null, 'No TimepointEditorScope found in context');
    return scope!;
  }

  static TimepointEditorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TimepointEditorScope>();
  }

  @override
  bool updateShouldNotify(TimepointEditorScope oldWidget) {
    return signals != oldWidget.signals ||
        actorId != oldWidget.actorId ||
        phaseId != oldWidget.phaseId ||
        scheduleId != oldWidget.scheduleId ||
        timepointId != oldWidget.timepointId;
  }
}