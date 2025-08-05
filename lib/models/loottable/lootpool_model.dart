import 'package:json_annotation/json_annotation.dart';

part 'lootpool_model.g.dart';

@JsonSerializable()
class LootPoolModel {
  LootPoolModel({
    required this.name,
    required this.pick,
    required this.entries,
    required this.enabled,
    required this.duplicates
  });

  String name;
  LootPickModel pick;
  List<LootEntryModel> entries;
  bool enabled;
  bool duplicates;

  factory LootPoolModel.fromJson(Map<String, dynamic> json) => _$LootPoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPoolModelToJson(this);
}

@JsonSerializable()
class LootPickModel {
  LootPickModel({
    required this.min,
    required this.max,
  });

  int min;
  int max;

  factory LootPickModel.fromJson(Map<String, dynamic> json) => _$LootPickModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPickModelToJson(this);
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
