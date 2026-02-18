// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timepoint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimepointModel _$TimepointModelFromJson(Map<String, dynamic> json) =>
    TimepointModel(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$TimepointTypeEnumMap, json['type']),
      description: json['description'] as String? ?? "",
      startTime: (json['startTime'] as num?)?.toInt() ?? 0,
      data: json['data'],
    );

Map<String, dynamic> _$TimepointModelToJson(TimepointModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TimepointTypeEnumMap[instance.type]!,
      'description': instance.description,
      'startTime': instance.startTime,
      'data': instance.data,
    };

const _$TimepointTypeEnumMap = {
  TimepointType.actionTimeline: 'actionTimeline',
  TimepointType.battleTalk: 'battleTalk',
  TimepointType.bNpcDespawn: 'bNpcDespawn',
  TimepointType.bNpcFlags: 'bNpcFlags',
  TimepointType.bNpcSpawn: 'bNpcSpawn',
  TimepointType.castAction: 'castAction',
  TimepointType.directorFlags: 'directorFlags',
  TimepointType.directorSeq: 'directorSeq',
  TimepointType.directorVar: 'directorVar',
  TimepointType.idle: 'idle',
  TimepointType.logMessage: 'logMessage',
  TimepointType.setBGM: 'setBGM',
  TimepointType.setCondition: 'setCondition',
  TimepointType.setPos: 'setPos',
  TimepointType.snapshot: 'snapshot',
  TimepointType.interruptAction: 'interruptAction',
  TimepointType.rollRNG: 'rollRNG',
};
