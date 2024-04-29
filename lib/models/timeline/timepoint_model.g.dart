// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timepoint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimepointModel _$TimepointModelFromJson(Map<String, dynamic> json) =>
    TimepointModel(
      type: $enumDecode(_$TimepointTypeEnumMap, json['type']),
      description: json['description'] as String? ?? "",
      data: json['data'],
    );

Map<String, dynamic> _$TimepointModelToJson(TimepointModel instance) =>
    <String, dynamic>{
      'type': _$TimepointTypeEnumMap[instance.type]!,
      'description': instance.description,
      'data': instance.data,
    };

const _$TimepointTypeEnumMap = {
  TimepointType.idle: 'idle',
  TimepointType.castAction: 'castAction',
  TimepointType.moveTo: 'moveTo',
  TimepointType.setDirectorVar: 'setDirectorVar',
  TimepointType.setActorFlags: 'setActorFlags',
  TimepointType.logMessage: 'logMessage',
  TimepointType.battleTalk: 'battleTalk',
};
