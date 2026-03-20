import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class ConditionEditorScope extends InheritedWidget {
  final TimelineEditorSignal signals;
  final int actorId;
  final int phaseId;
  final int conditionId;

  const ConditionEditorScope({
    super.key,
    required this.signals,
    required this.actorId,
    required this.phaseId,
    required this.conditionId,
    required super.child,
  });

  static ConditionEditorScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ConditionEditorScope>();
    assert(scope != null, 'No ConditionEditorScope found in context');
    return scope!;
  }

  static ConditionEditorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ConditionEditorScope>();
  }

  @override
  bool updateShouldNotify(ConditionEditorScope oldWidget) {
    return signals != oldWidget.signals ||
        actorId != oldWidget.actorId ||
        phaseId != oldWidget.phaseId ||
        conditionId != oldWidget.conditionId;
  }
}
