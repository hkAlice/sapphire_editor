import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_detailed_select.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/actor_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/condition_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/schedule_tab_view.dart';
import 'package:sapphire_editor/widgets/timeline/tab_views/selector_tab_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TimelineList extends StatelessWidget {
  final int actorId;

  const TimelineList({super.key, required this.actorId});

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final actors = signals.timeline.value.actors;
      if(actors.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedActorId = signals.selectedActorId.value;
      final actor = actors.firstWhere(
        (item) => item.id == selectedActorId,
        orElse: () => actors.first,
      );

      final selectedPhaseId = signals.selectedPhaseId.value;
      final hasPhases = actor.phases.isNotEmpty;
      final selectedPhase = hasPhases
          ? actor.phases.firstWhere(
              (phase) => phase.id == selectedPhaseId,
              orElse: () => actor.phases.first,
            )
          : null;

      return DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 8.0),
              child: hasPhases
                  ? Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: ActorDetailedSelect(
                            actors: actors,
                            actorId: actor.id,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const SizedBox(
                          height: 28.0,
                          child: VerticalDivider(),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 14,
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: selectedPhase!.id,
                                  decoration: const InputDecoration(
                                    labelText: "Phase",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 10.0),
                                  ),
                                  items: actor.phases
                                      .map((phase) => DropdownMenuItem<String>(
                                            value: phase.id,
                                            child: Text(phase.name),
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
                                    signals.duplicatePhase(
                                        selectedPhase!, actor.id);
                                    return;
                                  }

                                  if(value == 'delete') {
                                    signals.removePhase(
                                        selectedPhase, actor.id);
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
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ActorDetailedSelect(
                      actors: actors,
                      actorId: actor.id,
                    ),
            ),
            Divider(
              thickness: 0.5,
            ),
            TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).hoverColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
              tabs: const [
                Tab(
                    icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cruelty_free_outlined, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Actor"),
                  ],
                )),
                Tab(
                    icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, size: 28.0),
                    SizedBox(width: 8.0),
                    Text("Trigger"),
                  ],
                )),
                Tab(
                    icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.linear_scale_rounded, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Schedule"),
                  ],
                )),
                Tab(
                    icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.scatter_plot_outlined, size: 22.0),
                    SizedBox(width: 8.0),
                    Text("Selector"),
                  ],
                )),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ActorTabView(),
                  ConditionTabView(),
                  ScheduleTabView(
                    actorId: actorId,
                  ),
                  SelectorTabView(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
