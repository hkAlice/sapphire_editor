import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_detailed_select.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_general_widget.dart';
import 'package:sapphire_editor/widgets/timeline/actor/actor_parts_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ActorTabView extends StatelessWidget {
  const ActorTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);

    return Watch((context) {
      final timelineModel = signals.timeline.value;
      final selectedActor = signals.selectedActor.value;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              ActorDetailedSelect(
                actors: timelineModel.actors,
                actorId: selectedActor.id
              ),
              ActorGeneralWidget(
                actors: timelineModel.actors,
                actorModel: selectedActor,
                actorId: selectedActor.id
              ),
              const ActorPartsWidget()
            ],
          ),
        ),
      );
    });
  }
}
