import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorPartsWidget extends StatelessWidget {
  const ActorPartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          children: [
            SmallHeadingWidget(title: "BNpc Parts"),
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