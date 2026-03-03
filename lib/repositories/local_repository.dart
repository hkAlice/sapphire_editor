import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/repository/item_minimal.dart';

class LocalRepository {
  static final LocalRepository _instance = LocalRepository._internal();

  factory LocalRepository() {
    return _instance;
  }

  LocalRepository._internal();

  Map<int, ItemMinimal>? _items;
  List<String>? _bnpcNames;

  Future<void> load() async {
    if(_items != null)
      return;

    final itemJsonString = await rootBundle.loadString("assets/data/ItemMinimal.json");
    final List<dynamic> itemJsonList = json.decode(itemJsonString);

    _items = {};
    for(int i = 0; i < itemJsonList.length; i++) {
      final value = itemJsonList[i];
      if(value is List && value.length >= 3) {
        _items![i] = ItemMinimal(
          id: i,
          name: value[0].toString(),
          icon: value[1] as int,
          iLvl: value[2] as int,
        );
      }
    }

    try {
      final bnpcJsonString = await rootBundle.loadString("assets/data/BNPCNameMinimal.json");
      final List<dynamic> bnpcJsonList = json.decode(bnpcJsonString);
      _bnpcNames = bnpcJsonList.map((e) => e.toString()).toList();
    } catch (_) {
      // in case BNPCNameMinimal.json is missing or fails to load, fail safely
      _bnpcNames = null;
    }
  }

  ItemMinimal? getItemMinimal(int id) {
    return _items?[id];
  }

  List<ItemMinimal> getAllItemMinimal() {
    return _items?.values.toList() ?? [];
  }

  String getBnpcName(int id, {String? fallback}) {
    if(_bnpcNames == null || id < 0 || id >= _bnpcNames!.length) {
      return fallback ?? "Unknown BNPC ($id)";
    }
    
    final name = _bnpcNames![id];
    return name.isEmpty ? (fallback ?? "Unknown BNPC ($id)") : name;
  }

  bool get isLoaded => _items != null;
}
