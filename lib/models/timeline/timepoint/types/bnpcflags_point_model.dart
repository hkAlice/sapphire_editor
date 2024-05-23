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
  static const None               = 0x00;
  static const Immobile           = 0x01;
  static const TurningDisabled    = 0x02;
  static const Invincible         = 0x04;
  static const InvincibleRefill   = 0x08;
  static const NoDeaggro          = 0x10;
  static const Untargetable       = 0x20;
  static const AutoAttackDisabled = 0x40;
  static const Intermission       = 0x80;
}