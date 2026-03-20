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

      final phase = signals.selectedPhase.value;
      final triggers = phase.triggers;
      int conditionCount = triggers.length;
      int enabledConditionsCount = triggers.where((e) => e.enabled).length;

      return SingleChildScrollView(
        child: Column(
          children: [
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
