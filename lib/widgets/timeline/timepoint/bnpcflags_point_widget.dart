import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class BNpcFlagsPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const BNpcFlagsPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<BNpcFlagsPointWidget> createState() => _BNpcFlagsPointWidgetState();
}

class _BNpcFlagsPointWidgetState extends State<BNpcFlagsPointWidget> {
  late BNpcFlagsPointModel pointData = widget.timepointModel.data as BNpcFlagsPointModel;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.immobile != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.immobile;
                  setState(() {
                    
                  });
              
                  widget.onUpdate();
                },
                toggleText: ("0x01", "0x01"),
                leading: const Text("Immobile"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.turningDisabled != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.turningDisabled;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x02", "0x02"),
                leading: const Text("DisableRot"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.invincible != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.invincible;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x04", "0x04"),
                leading: const Text("Invuln"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.invincibleRefill != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.invincibleRefill;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x08", "0x08"),
                leading: const Text("InvulnRefill"),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.noDeaggro != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.noDeaggro;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x10", "0x10"),
                leading: const Text("NoDeaggro"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.untargetable != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.untargetable;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x20", "0x20"),
                leading: const Text("Untargetable"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.autoAttackDisabled != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.autoAttackDisabled;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x40", "0x40"),
                leading: const Text("NoAutoAttack"),
              ),
              SwitchTextWidget(
                enabled: pointData.flags & BNpcFlags.intermission != 0,
                onPressed: () {
                  pointData.flags = pointData.flags ^= BNpcFlags.intermission;
                  setState(() {
                    
                  });
          
                  widget.onUpdate();
                },
                toggleText: ("0x80", "0x80"),
                leading: const Text("Intermission"),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(pointData.flags.toRadixString(2).padLeft(8, "0"), style: Theme.of(context).textTheme.displaySmall,)
          )
        )
      ],
    );
  }
}