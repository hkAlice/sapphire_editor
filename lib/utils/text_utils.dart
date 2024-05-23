import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

String treatEnumName(Enum type) {
  String typeStr = type.toString().split(".").last;

  return toBeginningOfSentenceCase(typeStr);
}

Future<void> exportStringAsJson(String json, String fileName) async {
  if(!kIsWeb) {
    await FileSaver.instance.saveAs(
      name: fileName,
      ext: ".json",
      mimeType: MimeType.json,
      bytes: Uint8List.fromList(json.codeUnits),
    );

    return;
  }

  await FileSaver.instance.saveFile(
    name: fileName,
    mimeType: MimeType.json,
    bytes: Uint8List.fromList(json.codeUnits),
  );
}