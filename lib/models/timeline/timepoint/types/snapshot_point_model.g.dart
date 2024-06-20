// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapshotPointModel _$SnapshotPointModelFromJson(Map<String, dynamic> json) =>
    SnapshotPointModel(
      sourceActor: json['sourceActor'] as String? ?? "<unknown>",
      selectorName: json['selectorName'] as String? ?? "<unknown>",
    );

Map<String, dynamic> _$SnapshotPointModelToJson(SnapshotPointModel instance) =>
    <String, dynamic>{
      'selectorName': instance.selectorName,
      'sourceActor': instance.sourceActor,
    };
