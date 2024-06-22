import 'package:json_annotation/json_annotation.dart';

part 'bnpcflags_point_model.g.dart';

@JsonSerializable()
class BNpcFlagsPointModel {
  String targetActor;

  int flags;

  BNpcFlagsPointModel({this.targetActor = "", this.flags = 0});

  factory BNpcFlagsPointModel.fromJson(Map<String, dynamic> json) => _$BNpcFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcFlagsPointModelToJson(this);

  @override
  String toString() {
    var bnpcFlags = "Set ${BNpcFlags.flagsStr(flags)}";

    return bnpcFlags;
  }
}

// TODO: xdd
// enum extensions are "cleaner", but also more than double the verbose + overhead of branching/LUT
class BNpcFlags {
  static const none               = 0x00;
  static const immobile           = 0x01;
  static const turningDisabled    = 0x02;
  static const invincible         = 0x04;
  static const invincibleRefill   = 0x08;
  static const noDeaggro          = 0x10;
  static const untargetable       = 0x20;
  static const autoAttackDisabled = 0x40;
  static const invisible          = 0x80;

  static String flagsStr(int flags) {
    String bnpcFlags = "";

    if(flags & BNpcFlags.immobile == BNpcFlags.immobile) {
      bnpcFlags += " Immobile |";
    }
    if(flags & BNpcFlags.turningDisabled == BNpcFlags.turningDisabled) {
      bnpcFlags += " TurningDisabled |";
    }
    if(flags & BNpcFlags.invincible == BNpcFlags.invincible) {
      bnpcFlags += " Invincible |";
    }
    if(flags & BNpcFlags.invincibleRefill == BNpcFlags.invincibleRefill) {
      bnpcFlags += " InvincibleRefill |";
    }
    if(flags & BNpcFlags.noDeaggro == BNpcFlags.noDeaggro) {
      bnpcFlags += " NoDeaggro |";
    }
    if(flags & BNpcFlags.untargetable == BNpcFlags.untargetable) {
      bnpcFlags += " Untargetable |";
    }
    if(flags & BNpcFlags.autoAttackDisabled == BNpcFlags.autoAttackDisabled) {
      bnpcFlags += " AutoAtkDisabled |";
    }
    if(flags & BNpcFlags.invisible == BNpcFlags.invisible) {
      bnpcFlags += " Invisible |";
    }

    bnpcFlags = bnpcFlags.substring(0, bnpcFlags.length - 1).trim();
    return bnpcFlags;
  }
}