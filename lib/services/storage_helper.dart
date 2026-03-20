import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sapphire_editor/models/storage/editor_settings_model.dart';

class StorageHelper {
  static final StorageHelper _singleton = StorageHelper._internal();
  
  factory StorageHelper() {
    return _singleton;
  }

  bool _isInitialized = false;
  final Map<StorageTable, Box> _tableInstances = {};
  
  StorageHelper._internal();

  Future<bool> init() async {
    // Initialize Hive CE properly with platform specific directory handling
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(EditorSettingsModelAdapter());
    
    // Open boxes for each table in our enum
    for(var table in StorageTable.values) {
      _tableInstances[table] = await Hive.openBox(table.name);
    }

    _isInitialized = true;
    return _isInitialized;
  }

  Box getTable(StorageTable table) {
    if (!_isInitialized) {
      throw Exception("StorageHelper has not been initialized. Call init() first.");
    }
    return _tableInstances[table]!;
  }
}

// add your precious tables here
enum StorageTable {
  autosaveTimeline,
  autosaveLootTable,
  settings
}