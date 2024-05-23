import 'package:json_annotation/json_annotation.dart';

part 'bnpcflags_point_model.g.dart';

@JsonSerializable()
class BNpcFlagsPointModel {
  String targetActor;

  int flags;

  BNpcFlagsPointModel({required this.targetActor, required this.flags});

  factory BNpcFlagsPointModel.fromJson(Map<String, dynamic> json) => _$BNpcFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcFlagsPointModelToJson(this);
}

// TODO: xdd
// enum extensions are "cleaner", but also more than double the verbose + overhead of branching/LUT
class BNpcFlag {
  static const none               = 0x00;
  static const immobile           = 0x01;
  static const turningDisabled    = 0x02;
  static const invincible         = 0x04;
  static const invincibleRefill   = 0x08;
  static const noDeaggro          = 0x10;
  static const untargetable       = 0x20;
  static const autoAttackDisabled = 0x40;
  static const intermission       = 0x80;
}