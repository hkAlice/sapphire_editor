import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

String treatEnumName(Enum type) {
  String typeStr = type.toString().split(".").last;

  return toBeginningOfSentenceCase(typeStr);
}