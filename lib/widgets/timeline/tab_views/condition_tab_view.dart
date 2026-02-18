import 'package:flutter/material.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
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
      final timeline = signals.timeline.value;
      int conditionCount = timeline.conditions.length;
      int enabledConditionsCount = timeline.conditions.where((e) => e.enabled).toList().length;

      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: SmallHeadingWidget(
                title: "$conditionCount condition${conditionCount == 1 ? '' : 's'} ($enabledConditionsCount enabled)",
                trailing: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        for(var condition in timeline.conditions) {
                          condition.enabled = true;
                          signals.updateCondition(condition.id, condition);
                        }
                      },
                      child: const Text("Enable all")
                    ),
                    const SizedBox(width: 8.0,),
                    OutlinedButton(
                      onPressed: () {
                        for(var condition in timeline.conditions) {
                          condition.enabled = false;
                          signals.updateCondition(condition.id, condition);
                        }
                      },
                      child: const Text("Disable all")
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorder: (int oldindex, int newindex) {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = timeline.conditions.removeAt(oldindex);
                  timeline.conditions.insert(newindex, items);
                  signals.timeline.value = signals.timeline.value;
                },
                itemCount: timeline.conditions.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return ConditionItem(
                    key: Key("condition_${timeline.conditions[i].id}"),
                    index: i,
                    conditionId: timeline.conditions[i].id,
                  );
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: AddGenericWidget(
                text: "New condition",
                onTap: () { 
                  signals.timeline.value.addNewCondition();
                }
              ),
            ),
          ],
        ),
      );
    });
  }
}
