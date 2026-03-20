import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/under_construction.dart';

class ActorPartsWidget extends StatelessWidget {
  const ActorPartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          children: [
            SmallHeadingWidget(title: "BNpc Parts"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10.0),
              child: UnderConstruction(height: 20.0, stripeColor: Colors.orangeAccent.withValues(alpha: 0.5)),
            ),
            AddGenericWidget(
              text: "New BNpcPart",
              onTap: null
            )
          ],
        ),
      ),
    );
  }
}