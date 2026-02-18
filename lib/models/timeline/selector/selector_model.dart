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

  String excludeSelectorName;

  SelectorModel({
    required this.id,
    this.name = "Selector",
    this.description = "",
    this.fillRandomEntries = false,
    this.count = 1,
    this.excludeSelectorName = "",
    filterList
  }) : filters = filterList ?? [];

  factory SelectorModel.fromJson(Map<String, dynamic> json) => _$SelectorModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectorModelToJson(this);

  SelectorModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? fillRandomEntries,
    int? count,
    List<SelectorFilterModel>? filters,
    String? excludeSelectorName,
  }) {
    return SelectorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fillRandomEntries: fillRandomEntries ?? this.fillRandomEntries,
      count: count ?? this.count,
      filterList: filters ?? List.from(this.filters),
      excludeSelectorName: excludeSelectorName ?? this.excludeSelectorName,
    );
  }

  @override
  String toString() {
    var countStr = "Select $count target${count == 1 ? '' : 's'} where ";

    for(int i = 0; i < filters.length; i++) {
      var filter = filters[i];

      if(i > 0) {
        countStr += ", and ";
      }

      if(filter.negate) {
        countStr += "not ";
      }
      
      countStr += filter.type.name;
    }

    if(filters.isEmpty) {
      countStr += "🗿";
    }

    if(fillRandomEntries) {
      countStr += " (fill with random)";
    }

    if(excludeSelectorName.isNotEmpty) {
      countStr += " (exclude $excludeSelectorName)";
    }

    return countStr;
  }
}