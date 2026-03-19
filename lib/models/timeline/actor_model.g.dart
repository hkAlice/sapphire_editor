// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActorModel _$ActorModelFromJson(Map<String, dynamic> json) => ActorModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      layoutId: (json['layoutId'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      initialPhaseId: (json['initialPhaseId'] as num?)?.toInt() ?? 1,
    )
      ..phases = (json['phases'] as List<dynamic>)
          .map((e) => TimelinePhaseModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..subactors =
          (json['subactors'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$ActorModelToJson(ActorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'layoutId': instance.layoutId,
      'hp': instance.hp,
      'initialPhaseId': instance.initialPhaseId,
      'phases': instance.phases,
      'subactors': instance.subactors,
    };
