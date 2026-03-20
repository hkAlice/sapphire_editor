import 'package:hive_ce/hive.dart';
part 'editor_settings_model.g.dart';

@HiveType(typeId: 0)
class EditorSettingsModel extends HiveObject {

  @HiveField(0)
  String theme;

  @HiveField(1)
  String brightness;

  EditorSettingsModel({this.theme = "damask", this.brightness = "dark"});
}