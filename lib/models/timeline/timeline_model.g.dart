// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      name: json['name'] as String,
      version:
          (json['version'] as num?)?.toInt() ?? TimelineModel.VERSION_MODEL,
    )
      ..actors = (json['actors'] as List<dynamic>)
          .map((e) => ActorModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..conditions = (json['conditions'] as List<dynamic>)
          .map((e) => PhaseConditionModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..selectors = (json['selectors'] as List<dynamic>)
          .map((e) => SelectorModel.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'actors': instance.actors,
      'conditions': instance.conditions,
      'selectors': instance.selectors,
    };
