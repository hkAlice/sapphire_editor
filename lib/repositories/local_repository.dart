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

  Future<void> load() async {
    if(_items != null)
      return;

    final jsonString = await rootBundle.loadString("assets/data/ItemMinimal.json");
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _items = jsonMap.map((key, value) => MapEntry(int.parse(key), ItemMinimal.withId(key, value)));
  }

  ItemMinimal? getItemMinimal(int id) {
    return _items?[id];
  }

  List<ItemMinimal> getAllItemMinimal() {
    return _items?.values.toList() ?? [];
  }

  bool get isLoaded => _items != null;
}
