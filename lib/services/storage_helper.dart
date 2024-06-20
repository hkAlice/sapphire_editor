import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sapphire_editor/models/storage/editor_settings_model.dart';

class StorageHelper {
  static final StorageHelper _singleton = StorageHelper._internal();
  
  factory StorageHelper() {
    return _singleton;
  }

  bool _isInitialized = false;
  final Map<StorageTable, CollectionBox> _tableInstances = {};
  late BoxCollection _dbInstance;
  
  StorageHelper._internal();

  Future<bool> init() async {
    // todo: objectbox works so much better than hive
    // no objBox for web however (isar maybe)
    Hive
      ..init(kIsWeb ? "/storage" : (await getApplicationDocumentsDirectory()).path)
      ..registerAdapter(EditorSettingsModelAdapter());
    
    _dbInstance = await BoxCollection.open(
      "editorDb",
      path: "./storage/",
      StorageTable.values.map((e) => e.name).toSet(),
    );

    for(var table in StorageTable.values) {
      _tableInstances[table] = await _dbInstance.openBox(table.name);
    }

    _isInitialized = true;

    return _isInitialized;
  }

  CollectionBox getTable(StorageTable table) {
    return _tableInstances[table]!;
  }
}

// add your precious tables here
enum StorageTable {
  autosaveTimeline,
  settings
}