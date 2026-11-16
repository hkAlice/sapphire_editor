// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bubbletext_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BubbleTextPointModel _$BubbleTextPointModelFromJson(
        Map<String, dynamic> json) =>
    BubbleTextPointModel(
      talkerActorName: json['talkerActorName'] as String? ?? "<unknown>",
      balloonId: (json['balloonId'] as num?)?.toInt() ?? 0,
    )..params = (json['params'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [0];

Map<String, dynamic> _$BubbleTextPointModelToJson(
        BubbleTextPointModel instance) =>
    <String, dynamic>{
      'talkerActorName': instance.talkerActorName,
      'balloonId': instance.balloonId,
      'params': instance.params,
    };
