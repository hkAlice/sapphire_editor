// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectorModel _$SelectorModelFromJson(Map<String, dynamic> json) =>
    SelectorModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "Selector",
      description: json['description'] as String? ?? "",
      fillRandomEntries: json['fillRandomEntries'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt() ?? 1,
    )..filters = (json['filters'] as List<dynamic>)
        .map((e) => SelectorFilterModel.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$SelectorModelToJson(SelectorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'fillRandomEntries': instance.fillRandomEntries,
      'count': instance.count,
      'filters': instance.filters,
    };
