import 'package:disable_web_context_menu/disable_web_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
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

  void _showEditDialog(BuildContext context, String headerText, String initialText, {int minLines = 5, int? maxLines, required ValueChanged<String> onChanged}) {
    final controller = TextEditingController(text: initialText);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(headerText),
            SizedBox(
              width: 32.0,
              height: 32.0,
              child: IconButton.outlined(
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(Icons.close),
                splashRadius: 28.0,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(minWidth: 600),
          child: TextField(
            maxLines: maxLines,
            minLines: minLines,
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              border: const OutlineInputBorder(),
              hintText: headerText,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPosition, dynamic signals, dynamic actor, dynamic schedule) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(value: 'edit_name', child: Row(children: [Icon(Icons.edit_rounded, size: 16), SizedBox(width: 8), Text('Edit name')])),
        const PopupMenuItem(value: 'edit_desc', child: Row(children: [Icon(Icons.comment_rounded, size: 16), SizedBox(width: 8), Text('Edit description')])),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'move_up', enabled: scheduleIndex > 0, child: const Row(children: [Icon(Icons.arrow_upward_rounded, size: 16), SizedBox(width: 8), Text('Move up')])),
        PopupMenuItem(value: 'move_down', enabled: scheduleIndex < actor.schedules.length - 1, child: const Row(children: [Icon(Icons.arrow_downward_rounded, size: 16), SizedBox(width: 8), Text('Move down')])),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
      ],
    ).then((value) {
      if(value == null) return;
      switch(value) {
        case 'edit_name':
          _showEditDialog(context, 'Edit schedule name', schedule.name, minLines: 1, maxLines: 1, onChanged: (newName) {
            signals.updateSchedule(schedule, schedule.copyWith(name: newName), actor.id);
          });
          break;
        case 'edit_desc':
          _showEditDialog(context, 'Edit schedule description', schedule.description, onChanged: (newDesc) {
            signals.updateSchedule(schedule, schedule.copyWith(description: newDesc), actor.id);
          });
          break;
        case 'move_up':
          signals.reorderSchedule(actor, scheduleIndex, scheduleIndex - 1);
          break;
        case 'move_down':
          signals.reorderSchedule(actor, scheduleIndex, scheduleIndex + 2);
          break;
        case 'duplicate':
          signals.duplicateSchedule(schedule, actor.id);
          break;
        case 'delete':
          signals.removeSchedule(schedule, actor.id);
          break;
      }
    });
  }

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

      return DisableWebContextMenu(
        child: GestureDetector(
          onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition, signals, actor, schedule),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            borderOnForeground: false,
            elevation: 1.0,
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              initiallyExpanded: true,
              title: Text(schedule.name),
              subtitle: Text(schedule.description.isNotEmpty ? schedule.description : timepointCountStr),
              trailing: SizedBox(
                width: 48.0,
                child: Text(
                  "${scheduleLastTimepoint.toStringAsFixed(1)}s",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.right,
                ),
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
          ),
        ),
      );
    });
  }
}
