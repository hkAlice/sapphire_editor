import 'package:json_annotation/json_annotation.dart';

part 'lootpool_model.g.dart';

@JsonSerializable()
class LootPoolModel {
  LootPoolModel({
    required this.name,
    required this.pickMin,
    required this.pickMax,
    required this.entries,
    required this.enabled,
    required this.duplicates
  });

  String name;
  int pickMin;
  int pickMax;
  List<LootEntryModel> entries;
  bool enabled;
  bool duplicates;

  factory LootPoolModel.fromJson(Map<String, dynamic> json) => _$LootPoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPoolModelToJson(this);
}

@JsonSerializable()
class LootEntryModel {
  LootEntryModel({
    required this.item,
    required this.weight,
  });

  int item;
  int weight;

  factory LootEntryModel.fromJson(Map<String, dynamic> json) => _$LootEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootEntryModelToJson(this);
}
