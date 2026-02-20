import 'package:json_annotation/json_annotation.dart';

part 'bnpcflags_point_model.g.dart';

@JsonSerializable()
class BNpcFlagsPointModel {
  String targetActor;

  int flags;
  int? flagsMask;
  int? invulnType;

  BNpcFlagsPointModel(
      {this.targetActor = "", this.flags = 0, this.flagsMask, this.invulnType});

  factory BNpcFlagsPointModel.fromJson(Map<String, dynamic> json) =>
      _$BNpcFlagsPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$BNpcFlagsPointModelToJson(this);

  @override
  String toString() {
    var flagsStr = BNpcFlags.flagsStr(flags);

    if(flagsStr.isEmpty) {
      return "Set and clear all flags";
    } else {
      return "Set $flagsStr";
    }
  }
}

// TODO: xdd
// enum extensions are "cleaner", but also more than double the verbose + overhead of branching/LUT
class BNpcFlags {
  static const none = 0x00;
  static const immobile = 0x01;
  static const turningDisabled = 0x02;
  static const invincible = 0x04;
  static const invincibleRefill = 0x08;
  static const noDeaggro = 0x10;
  static const untargetable = 0x20;
  static const autoAttackDisabled = 0x40;
  static const invisible = 0x80;
  static const noRoam = 0x100;
  static const unused1 = 0x200;
  static const unused2 = 0x400;
  static const unused3 = 0x800;

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
    if(flags & BNpcFlags.noRoam == BNpcFlags.noRoam) {
      bnpcFlags += " NoRoam |";
    }
    if(flags & BNpcFlags.unused1 == BNpcFlags.unused1) {
      bnpcFlags += " unused1 |";
    }
    if(flags & BNpcFlags.unused2 == BNpcFlags.unused2) {
      bnpcFlags += " unused2 |";
    }
    if(flags & BNpcFlags.unused3 == BNpcFlags.unused3) {
      bnpcFlags += " unused3 |";
    }

    if(bnpcFlags.isNotEmpty) {
      bnpcFlags = bnpcFlags.substring(0, bnpcFlags.length - 1).trim();
    }

    return bnpcFlags;
  }
}
