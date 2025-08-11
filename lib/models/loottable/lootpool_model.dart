import 'package:json_annotation/json_annotation.dart';

part 'lootpool_model.g.dart';

@JsonSerializable()
class LootPoolModel {
  LootPoolModel({
    required this.name,
    required this.pickMin,
    required this.pickMax,
    required this.items,
    required this.enabled,
    required this.duplicates
  });

  String name;
  int pickMin;
  int pickMax;
  List<LootEntryModel> items;
  bool enabled;
  bool duplicates;

  factory LootPoolModel.fromJson(Map<String, dynamic> json) => _$LootPoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPoolModelToJson(this);
}

@JsonSerializable()
class LootEntryModel {
  LootEntryModel({
    required this.id,
    required this.weight,
    required this.isHq
  });

  int id;
  int weight;
  bool isHq;

  factory LootEntryModel.fromJson(Map<String, dynamic> json) => _$LootEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootEntryModelToJson(this);
}
