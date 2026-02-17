import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class SignalsProvider extends InheritedWidget {
  final TimelineEditorSignal signals;

  const SignalsProvider({
    super.key,
    required this.signals,
    required Widget child,
  }) : super(child: child);

  static TimelineEditorSignal of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<SignalsProvider>();
    assert(provider != null, 'No SignalsProvider found in context');
    return provider!.signals;
  }

  @override
  bool updateShouldNotify(SignalsProvider oldWidget) {
    return signals != oldWidget.signals;
  }
}
