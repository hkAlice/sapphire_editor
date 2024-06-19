import 'package:sapphire_editor/models/storage/editor_settings_model.dart';
import 'package:sapphire_editor/services/storage_helper.dart';

class SettingsHelper {
  static final SettingsHelper _singleton = SettingsHelper._internal();
  
  factory SettingsHelper() {
    return _singleton;
  }
  
  SettingsHelper._internal();

  Future<EditorSettingsModel> getUISettings() async {
    var settingsBox = StorageHelper().getTable(StorageTable.settings);
    var settingsModel;

    try {
      settingsModel = await settingsBox.get("ui");


      if(settingsModel == null) {
        await settingsBox.put("ui", EditorSettingsModel());
      }
    }
    catch(e) {
      // todo something is screwed
      settingsModel = EditorSettingsModel();
      await settingsBox.put("ui", settingsModel);
    }

    return settingsModel as EditorSettingsModel;
  }

  Future<bool> saveUISettings(EditorSettingsModel settings) async {
    var settingsBox = StorageHelper().getTable(StorageTable.settings);
    await settingsBox.put("ui", settings);

    return true;
  }
}