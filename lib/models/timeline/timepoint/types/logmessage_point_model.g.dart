// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logmessage_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogMessagePointModel _$LogMessagePointModelFromJson(
        Map<String, dynamic> json) =>
    LogMessagePointModel(
      messageId: (json['messageId'] as num?)?.toInt() ?? 0,
      params: (json['params'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0],
    );

Map<String, dynamic> _$LogMessagePointModelToJson(
        LogMessagePointModel instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'params': instance.params,
    };
