import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/actiontimeline_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/battletalk_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcdespawn_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/bnpcflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/castaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorflags_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorseq_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/directorvar_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/idle_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/interruptaction_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/logmessage_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/rollrng_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setbgm_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/settrigger_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/setpos_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/snapshot_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/spawnbnpc_point_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/statuseffect_point_widget.dart';

typedef TimepointEditorBuilder = Widget Function(TimepointEditorContext context);

class TimepointEditorContext {
  final TimepointModel timepointModel;

  const TimepointEditorContext({
    required this.timepointModel,
  });
}

class TimepointEditorRegistry {
  static final Map<TimepointType, TimepointEditorBuilder> _builders = {
    TimepointType.actionTimeline: (context) => ActionTimelinePointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.castAction: (context) => CastActionPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.battleTalk: (context) => BattleTalkPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.bNpcDespawn: (context) => BNpcDespawnPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.bNpcFlags: (context) => BNpcFlagsPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.bNpcSpawn: (context) => BNpcSpawnPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.directorFlags: (context) => DirectorFlagsPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.directorSeq: (context) => DirectorSeqPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.directorVar: (context) => DirectorVarPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.idle: (context) => IdlePointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.logMessage: (context) => LogMessagePointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.setBGM: (context) => SetBgmPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.setTrigger: (context) => SetTriggerPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.setPos: (context) => SetPosPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.snapshot: (context) => SnapshotPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.interruptAction: (context) => InterruptActionPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.rollRNG: (context) => RollRNGPointWidget(
          timepointModel: context.timepointModel,
        ),
    TimepointType.statusEffect: (context) => StatusEffectPointWidget(
          timepointModel: context.timepointModel,
        ),
  };

  static Widget buildEditor(TimepointEditorContext context) {
    final builder = _builders[context.timepointModel.type];
    if(builder == null) {
      return Text(
          'Unimplemented timepoint type ${context.timepointModel.type.name}');
    }
    return builder(context);
  }
}