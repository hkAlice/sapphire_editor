import 'package:sapphire_editor/models/timeline/timeline_model.dart';

class TimelineSanitySvc {
  static List<SanityItem> run(TimelineModel timeline) {
    return [];
  }
}

class SanityItem {
  final SanitySeverity severity;
  final String type;
  final String desc;
  const SanityItem(this.severity, this.type, this.desc);
}

enum SanitySeverity { error, warning, info }
