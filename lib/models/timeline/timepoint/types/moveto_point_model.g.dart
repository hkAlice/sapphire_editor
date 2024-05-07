// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moveto_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveToPointModel _$MoveToPointModelFromJson(Map<String, dynamic> json) =>
    MoveToPointModel(
      pos: (json['pos'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0, 0.0],
      rot: (json['rot'] as num?)?.toDouble() ?? 0.0,
      pathRequest: json['pathRequest'] as bool? ?? true,
    );

Map<String, dynamic> _$MoveToPointModelToJson(MoveToPointModel instance) =>
    <String, dynamic>{
      'pos': instance.pos,
      'rot': instance.rot,
      'pathRequest': instance.pathRequest,
    };
