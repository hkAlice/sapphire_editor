import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/battletalk_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/castaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorseq_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorvar_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/idle_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/logmessage_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/moveto_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setbgm_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setcondition_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/spawnbnpc_point_widget.dart';

class GenericTimepointItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimelinePhaseModel phaseModel;
  final TimepointModel timepointModel;
  final Function(TimepointModel) onUpdate;

  const GenericTimepointItem({super.key, required this.timelineModel, required this.phaseModel, required this.timepointModel, required this.onUpdate});

  @override
  State<GenericTimepointItem> createState() => _GenericTimepointItemState();
}

class _GenericTimepointItemState extends State<GenericTimepointItem> {
  late TextEditingController _descriptionTextEditingController;
  late TextEditingController _durationTextEditingController;

  Widget _generateTypedTimepoint() {
    // todo: can also use cast type "is".. though slower
    var timepointModel = widget.timepointModel;
    var timelineModel = widget.timelineModel;

    onUpdate() {
      widget.onUpdate(widget.timepointModel);
    }

    switch(widget.timepointModel.type) {
      case TimepointType.idle:
        return const IdlePointWidget();
      case TimepointType.moveTo:
        return MoveToPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.castAction:
        return CastActionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.setBGM:
        return SetBgmPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.logMessage:
        return LogMessagePointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.bNpcFlags:
        return BNpcFlagsPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.battleTalk:
        return BattleTalkPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.spawnBNpc:
        return SpawnBNpcPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorFlags:
        return DirectorFlagsPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorSeq:
        return DirectorSeqPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.directorVar:
        return DirectorVarPointWidget(timepointModel: timepointModel, onUpdate: onUpdate);
      case TimepointType.setCondition:
        return SetConditionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, onUpdate: onUpdate);
      default:
        return Text("Unimplemented timepoint type ${widget.timepointModel.type}");
    }
  }

  @override
  void initState() {
    _descriptionTextEditingController = TextEditingController(text: widget.timepointModel.description);
    _durationTextEditingController = TextEditingController(text: widget.timepointModel.duration.toString());

    super.initState();
  }

  @override
  void dispose() {
    _descriptionTextEditingController.dispose();
    _durationTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.timepointModel.getColorForTimepointType(), width: 5.0),
          top: BorderSide(color: Colors.grey.shade800, width: 1.0)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<TimepointType>(
                    decoration: const InputDecoration(
                      filled: true,
                      //labelText: "Point type",
                      border: null
                    ),
                    value: widget.timepointModel.type,
                    isDense: true,
                    onChanged: (TimepointType? value) {
                      if(value == null) { return; }
            
                      widget.timepointModel.changeType(value);
                      
                      setState(() {
                        
                      });
                      widget.onUpdate(widget.timepointModel);
                    },
                    items: TimepointType.values.map((TimepointType type) {
                      return DropdownMenuItem<TimepointType>(
                        value: type,
                        child: Text(treatEnumName(type)));
                    }).toList()
                  ),
                ),
                const SizedBox(width: 18.0,),
                NumberButton(
                  min: 0,
                  max: 50000,
                  value: widget.timepointModel.duration,
                  label: "Duration",
                  builder: (value) {
                    var seconds = value / 1000;
                    return SizedBox(
                      width: 42,
                      child: Column(
                        children: [
                          Text("${seconds.toStringAsFixed(2)}s"),
                          //Text("${value}ms", style: Theme.of(context).textTheme.bodySmall,)
                        ],
                      ),
                    );
                  },
                  stepCount: 100,
                  onChanged: (value) {
                    widget.timepointModel.duration = value;
                    setState(() {
                      
                    });
                    widget.onUpdate(widget.timepointModel);
                  }
                ),
                const SizedBox(width: 18.0,),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _descriptionTextEditingController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Description (optional)",
                    ),
                    onChanged: (value) {
                      widget.timepointModel.description = value;
                      widget.onUpdate(widget.timepointModel);
                    },
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      widget.phaseModel.timepoints.remove(widget.timepointModel);
                      widget.onUpdate(widget.timepointModel);
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1.0,),
          Container(
            color: Theme.of(context).canvasColor,
            padding: widget.timepointModel.type == TimepointType.idle ? null : const EdgeInsets.all(8.0),
            child: _generateTypedTimepoint(),
          )
        ],
      ),
    );
  }
}