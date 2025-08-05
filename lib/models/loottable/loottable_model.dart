import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';

part 'loottable_model.g.dart';

@JsonSerializable()
class LootTableModel {
  LootTableModel({
    required this.lootTable,
    required this.type,
    required this.pools,
  });

  String lootTable;
  LootTableType type;
  List<LootPoolModel> pools;

  factory LootTableModel.fromJson(Map<String, dynamic> json) => _$LootTableModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootTableModelToJson(this);
}

enum LootTableType {
  @JsonValue("bNPC")
  bNPC,
  @JsonValue("chest")
  chest,
  @JsonValue("fishing")
  fishing,
  @JsonValue("instance")
  instance,
  @JsonValue("other")
  other,
}