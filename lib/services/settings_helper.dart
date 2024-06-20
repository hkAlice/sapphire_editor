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
    EditorSettingsModel settingsModel = EditorSettingsModel();

    // todo: what the fuck happened to flutter local db on web the past few years

    try {
      var objData = await settingsBox.get("ui");

      if(objData == null) {
        await settingsBox.clear();
        await settingsBox.put("ui", settingsModel);
      }

      else {
        settingsModel = objData;
      }
    }
    catch(e) {
      // todo something is screwed
    }

    return settingsModel;
  }

  Future<bool> saveUISettings(EditorSettingsModel settings) async {
    var settingsBox = StorageHelper().getTable(StorageTable.settings);
    await settingsBox.put("ui", settings);

    return true;
  }
}