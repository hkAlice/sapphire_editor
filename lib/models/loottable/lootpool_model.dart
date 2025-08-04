import 'package:json_annotation/json_annotation.dart';

part 'lootpool_model.g.dart';

@JsonSerializable()
class LootPoolModel {
  LootPoolModel({
    required this.name,
    required this.pick,
    required this.entries,
  });
  late final String name;
  late final LootPickModel pick;
  late final List<LootEntryModel> entries;

  factory LootPoolModel.fromJson(Map<String, dynamic> json) => _$LootPoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPoolModelToJson(this);
}

class LootPickModel {
  LootPickModel({
    required this.min,
    required this.max,
  });
  late final int min;
  late final int max;

  factory LootPickModel.fromJson(Map<String, dynamic> json) => _$LootPickModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPickModelToJson(this);
}

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
