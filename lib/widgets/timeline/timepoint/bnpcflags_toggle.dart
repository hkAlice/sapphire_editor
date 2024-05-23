import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class BNpcFlagsToggle extends StatefulWidget {
  final int flags;
  final Function(int) onUpdate;
  final bool isDense;

  BNpcFlagsToggle({super.key, required this.flags, required this.onUpdate, this.isDense = false});

  @override
  State<BNpcFlagsToggle> createState() => _BNpcFlagsToggleState();
}

class _BNpcFlagsToggleState extends State<BNpcFlagsToggle> {
  late int flags = widget.flags;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.isDense ? Container() : Expanded(
          child: Center(
            child: Text(widget.flags.toRadixString(2).padLeft(8, "0"), style: Theme.of(context).textTheme.displaySmall,)
          )
        ),
        SizedBox(
          width: 170,
          child: Column(
            children: [
              SwitchTextWidget(
                enabled: flags & BNpcFlags.immobile != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.immobile;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x01", "0x01"),
                leading: const Text("Immobile"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.turningDisabled != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.turningDisabled;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x02", "0x02"),
                leading: const Text("DisableRot"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.invincible != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.invincible;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x04", "0x04"),
                leading: const Text("Invuln"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.invincibleRefill != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.invincibleRefill;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x08", "0x08"),
                leading: const Text("InvulnRefill"),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 170,
          child: Column(
            children: [
              SwitchTextWidget(
                enabled: flags & BNpcFlags.noDeaggro != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.noDeaggro;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x10", "0x10"),
                leading: const Text("NoDeaggro"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.untargetable != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.untargetable;
          
                  widget.onUpdate(flags);
                },
                toggleText: ("0x20", "0x20"),
                leading: const Text("Untargetable"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.autoAttackDisabled != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.autoAttackDisabled;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x40", "0x40"),
                leading: const Text("NoAutoAttack"),
              ),
              SwitchTextWidget(
                enabled: flags & BNpcFlags.intermission != 0,
                onPressed: () {
                  flags = flags ^= BNpcFlags.intermission;

                  widget.onUpdate(flags);
                },
                toggleText: ("0x80", "0x80"),
                leading: const Text("Intermission"),
              ),
            ],
          ),
        ),
        
      ]
    );
  }
}