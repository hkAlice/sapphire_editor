// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moveto_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveToPointModel _$MoveToPointModelFromJson(Map<String, dynamic> json) =>
    MoveToPointModel(
      rot: (json['rot'] as num?)?.toDouble() ?? 0.0,
      pathRequest: json['pathRequest'] as bool? ?? true,
    )..pos = Position3.fromJson(json['pos'] as Map<String, dynamic>);

Map<String, dynamic> _$MoveToPointModelToJson(MoveToPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'rot': instance.rot,
      'pathRequest': instance.pathRequest,
    };
