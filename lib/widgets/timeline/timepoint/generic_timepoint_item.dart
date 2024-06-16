import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_phase_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/battletalk_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/castaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorseq_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorvar_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/idle_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/logmessage_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setpos_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setbgm_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setcondition_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/snapshot_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/spawnbnpc_point_widget.dart';

class GenericTimepointItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final TimelinePhaseModel phaseModel;
  final TimepointModel timepointModel;
  final ActorModel selectedActor;
  final Function(TimepointModel) onUpdate;

  const GenericTimepointItem({
    super.key,
    required this.timelineModel,
    required this.phaseModel,
    required this.timepointModel,
    required this.selectedActor,
    required this.onUpdate
  });

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
    var selectedActor = widget.selectedActor;

    onUpdate() {
      widget.onUpdate(widget.timepointModel);
    }

    switch(widget.timepointModel.type) {
      case TimepointType.idle:
        return const IdlePointWidget();
      case TimepointType.setPos:
        return SetPosPointWidget(timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
      case TimepointType.castAction:
        return CastActionPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
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
      case TimepointType.snapshot:
        return SnapshotPointWidget(timelineModel: timelineModel, timepointModel: timepointModel, selectedActor: selectedActor, onUpdate: onUpdate);
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
        color: Colors.black26,
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
                  width: 180,
                  child: DropdownButtonFormField<TimepointType>(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Point type",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.5)
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
                  child: SizedBox(
                    height: 54.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.timepointModel.description, textAlign: TextAlign.start, overflow: TextOverflow.fade,)
                    )
                  ),
                ),
                SizedBox(
                  height: 54.0,
                  child: TextModalEditorWidget(
                    text: widget.timepointModel.description,
                    headerText: "Edit timepoint description",
                    onChanged: (description) {
                      widget.timepointModel.description = description;
                      widget.onUpdate(widget.timepointModel);
                    }
                  ),
                ),
                const SizedBox(width: 8.0,),
                SizedBox(
                  width: 38.0,
                  height: 54.0,
                  child: IconButton(
                    
                    icon: const Icon(Icons.clear_rounded),
                    splashRadius: 24.0,
                    onPressed: () {
                      widget.phaseModel.timepoints.remove(widget.timepointModel);
                      widget.onUpdate(widget.timepointModel);
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.black12,
            padding: widget.timepointModel.type == TimepointType.idle ? null : const EdgeInsets.all(8.0),
            child: _generateTypedTimepoint(),
          )
        ],
      ),
    );
  }
}