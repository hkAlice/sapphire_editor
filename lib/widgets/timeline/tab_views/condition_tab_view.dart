import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/condition/condition_item.dart';

class ConditionTabView extends StatefulWidget {
  const ConditionTabView({super.key});

  @override
  State<ConditionTabView> createState() => _ConditionTabViewState();
}

class _ConditionTabViewState extends State<ConditionTabView> {
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      if(signals.selectedPhaseId.value == null) {
        return const Center(
            child: Text("Select a phase to view its triggers."));
      }

      final actor = signals.selectedActor.value;
      final phase = signals.selectedPhase.value;
      final triggers = phase.triggers;
      int conditionCount = triggers.length;
      int enabledConditionsCount = triggers.where((e) => e.enabled).length;

      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: phase.id,
                      decoration: const InputDecoration(
                        labelText: "Phase",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                      ),
                      items: actor.phases
                          .map((p) => DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(p.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if(value == null) {
                          return;
                        }

                        signals.selectPhase(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton.outlined(
                    tooltip: "Add phase",
                    onPressed: () {
                      signals.addPhase(actor);
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(width: 4.0),
                  PopupMenuButton<String>(
                    tooltip: "Phase actions",
                    onSelected: (value) {
                      if(value == 'duplicate') {
                        signals.duplicatePhase(phase, actor.id);
                        return;
                      }

                      if(value == 'delete') {
                        signals.removePhase(phase, actor.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicate phase'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        enabled: actor.phases.length > 1,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete phase',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: SmallHeadingWidget(
                title:
                    "$conditionCount trigger(s) ($enabledConditionsCount enabled)",
                trailing: Row(
                  children: [],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  onReorder: (int oldindex, int newindex) {
                    final actorId = signals.selectedActorId.value ?? 0;
                    signals.reorderTriggersInPhase(
                      actorId,
                      phase.id,
                      oldindex,
                      newindex,
                    );
                  },
                  itemCount: triggers.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ConditionItem(
                      key: Key("condition_${triggers[i].id}"),
                      index: i,
                      conditionId: triggers[i].id,
                      signals: signals,
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: AddGenericWidget(
                  text: "New trigger",
                  onTap: () {
                    signals.addCondition(signals.selectedActorId.value ?? 0,
                        signals.selectedPhaseId.value!);
                  }),
            ),
          ],
        ),
      );
    });
  }
}
