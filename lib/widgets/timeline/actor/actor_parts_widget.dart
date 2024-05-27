import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorPartsWidget extends StatelessWidget {
  const ActorPartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SmallHeadingWidget(title: "BNpc Parts"),
            AddGenericWidget(
              text: "Add new BNpcParts",
              onTap: () {

              }
            )
          ],
        ),
      ),
    );
  }
}