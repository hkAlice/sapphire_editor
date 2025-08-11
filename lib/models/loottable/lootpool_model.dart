import 'package:json_annotation/json_annotation.dart';

part 'lootpool_model.g.dart';

@JsonSerializable()
class LootPoolModel {
  LootPoolModel({
    required this.name,
    required this.pick,
    required this.items,
    required this.enabled,
    required this.duplicates
  });

  String name;
  LootRangeModel pick;
  List<LootItemModel> items;
  bool enabled;
  bool duplicates;

  factory LootPoolModel.fromJson(Map<String, dynamic> json) => _$LootPoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootPoolModelToJson(this);
}

@JsonSerializable()
class LootItemModel {
  LootItemModel({
    required this.id,
    required this.weight,
    required this.isHq,
    required this.quantity
  });

  int id;
  int weight;
  bool isHq;
  LootRangeModel quantity;

  factory LootItemModel.fromJson(Map<String, dynamic> json) => _$LootItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootItemModelToJson(this);
}

@JsonSerializable()
class LootRangeModel {
  LootRangeModel({
    required this.min,
    required this.max
  });

  int min;
  int max;

  factory LootRangeModel.fromJson(Map<String, dynamic> json) => _$LootRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootRangeModelToJson(this);
}

