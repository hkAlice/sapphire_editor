// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timepoint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimepointModel _$TimepointModelFromJson(Map<String, dynamic> json) =>
    TimepointModel(
      type: $enumDecode(_$TimepointTypeEnumMap, json['type']),
      description: json['description'] as String? ?? "",
      duration: (json['duration'] as num?)?.toInt() ?? 5000,
      data: json['data'],
    );

Map<String, dynamic> _$TimepointModelToJson(TimepointModel instance) =>
    <String, dynamic>{
      'type': _$TimepointTypeEnumMap[instance.type]!,
      'description': instance.description,
      'duration': instance.duration,
      'data': instance.data,
    };

const _$TimepointTypeEnumMap = {
  TimepointType.idle: 'idle',
  TimepointType.castAction: 'castAction',
  TimepointType.moveTo: 'moveTo',
  TimepointType.directorFlags: 'directorFlags',
  TimepointType.directorSeq: 'directorSeq',
  TimepointType.directorVar: 'directorVar',
  TimepointType.bNpcFlags: 'bNpcFlags',
  TimepointType.spawnBNpc: 'spawnBNpc',
  TimepointType.logMessage: 'logMessage',
  TimepointType.battleTalk: 'battleTalk',
  TimepointType.setBGM: 'setBGM',
  TimepointType.setCondition: 'setCondition',
};
