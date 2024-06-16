import 'package:json_annotation/json_annotation.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';

part 'selector_model.g.dart';

@JsonSerializable()
class SelectorModel {
  final int id;

  String name;
  String description;

  bool fillRandomEntries;
  int count;

  List<SelectorFilterModel> filters;

  SelectorModel({
    required this.id,
    this.name = "Selector",
    this.description = "",
    this.fillRandomEntries = false,
    this.count = 1,
    filterList
  }) : filters = filterList ?? [];

  factory SelectorModel.fromJson(Map<String, dynamic> json) => _$SelectorModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectorModelToJson(this);
}