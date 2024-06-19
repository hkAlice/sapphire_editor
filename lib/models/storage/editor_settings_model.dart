import 'package:hive/hive.dart';
part 'editor_settings_model.g.dart';

@HiveType(typeId: 0)
class EditorSettingsModel extends HiveObject {

  @HiveField(0)
  String theme;

  @HiveField(1)
  String brightness;

  EditorSettingsModel({this.theme = "indigoM3", this.brightness = "dark"});
}