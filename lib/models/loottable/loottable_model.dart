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
  String type;
  List<LootPoolModel> pools;

  factory LootTableModel.fromJson(Map<String, dynamic> json) => _$LootTableModelFromJson(json);

  Map<String, dynamic> toJson() => _$LootTableModelToJson(this);
}
