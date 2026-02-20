import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:sapphire_editor/widgets/timeline/timepoint/generic_timepoint_item.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/utils/schedule_duration_cache.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TimelineScheduleItem extends StatelessWidget {
  final int scheduleIndex;
  final int scheduleId;

  const TimelineScheduleItem({
    super.key,
    required this.scheduleIndex,
    required this.scheduleId
  });

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    // Create a computed signal for this specific schedule to avoid rebuilds when other schedules change
    final scheduleSignal = computed(() {
      final actor = signals.selectedActor.value;
      return actor.schedules.firstWhere(
        (s) => s.id == scheduleId,
        orElse: () => actor.schedules.first,
      );
    });

    return Watch((context) {
      final actor = signals.selectedActor.value;
      final schedule = scheduleSignal.value;
      
      final cache = ScheduleDurationCache.calculate(schedule);
      final timepointCountStr = "${schedule.timepoints.length} timepoint${(schedule.timepoints.length != 1 ? 's' : '')}";

      double scheduleLastTimepoint = 0.0;
      if(schedule.timepoints.isNotEmpty) {
        scheduleLastTimepoint = schedule.timepoints.last.startTime / 1000.0;
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        borderOnForeground: false,
        elevation: 1.0,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          initiallyExpanded: true,
          title: ReorderableDragStartListener(index: scheduleIndex, child: Text(schedule.name)),
          subtitle: Text(schedule.description.isNotEmpty ? schedule.description : timepointCountStr),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 54.0,
                child: TextModalEditorWidget(
                  text: schedule.description,
                  headerText: "Edit schedule description",
                  onChanged: (newDescription) {
                    final newSchedule = schedule.copyWith(
                      description: newDescription
                    );

                    signals.updateSchedule(schedule, newSchedule, actor.id);
                  }
                ),
              ),
              const SizedBox(width: 8.0,),
              SizedBox(
                width: 32.0,
                height: 32.0,
                child: TextModalEditorWidget(
                  text: schedule.name,
                  headerText: "Edit schedule name",
                  icon: const Icon(Icons.edit_rounded),
                  minLines: 1,
                  maxLines: 1,
                  onChanged: (newName) {
                    final newSchedule = schedule.copyWith(
                      name: newName
                    );

                    signals.updateSchedule(schedule, newSchedule, actor.id);
                  }
                ),
              ),
              const SizedBox(width: 8.0,),
              SizedBox(
                width: 48.0,
                child: Text(
                  "${scheduleLastTimepoint.toStringAsFixed(1)}s",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.right
                )
              ),
            ],
          ),
          children: [
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                signals.reorderTimepoint(schedule, oldindex, newindex, actor.id);
              },
              itemCount: schedule.timepoints.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var timepointModel = schedule.timepoints[i];

                return GenericTimepointItem(
                  key: ValueKey(timepointModel.id),
                  timepointId: timepointModel.id,
                  scheduleIndex: scheduleIndex,
                  scheduleId: scheduleId,
                  timepointIndex: i,
                  timeElapsedMs: cache.timeElapsedList[i],
                  actorId: actor.id,
                );
              }
            ),
            SmallAddGenericWidget(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  signals.addTimepoint(actor.id, schedule.id, TimepointModel(id: schedule.generateTimepointId(), type: TimepointType.idle));
                });
              },
              text: "Add new timepoint",
            )
          ],
        ),
      );
    });
  }
}
