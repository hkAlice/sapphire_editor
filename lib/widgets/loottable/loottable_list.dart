import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/loottable_model.dart';
import 'package:sapphire_editor/widgets/loottable/tab_views/loottable_tab_view.dart';
import 'package:tab_container/tab_container.dart';

class LootTableList extends StatefulWidget {
  final LootTableModel lootTableModel;
  final Function(LootTableModel) onUpdate;
  const LootTableList({super.key, required this.onUpdate, required this.lootTableModel});

  @override
  State<LootTableList> createState() => _LootTableListState();
}

class _LootTableListState extends State<LootTableList> {
  @override
  Widget build(BuildContext context) {
    return TabContainer(
      borderRadius: BorderRadius.circular(16.0),
      tabEdge: TabEdge.top,
      curve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        animation = CurvedAnimation(
          curve: Curves.easeInOutCubic,
          parent: animation
        );
        return SlideTransition(
          position: Tween(
            begin: const Offset(0.2, 0.0),
            end: const Offset(0.0, 0.0),
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      }, 
      selectedTextStyle:  Theme.of(context).textTheme.bodyLarge,
      unselectedTextStyle:  Theme.of(context).textTheme.bodyLarge,
      color: Theme.of(context).hoverColor,
      tabs: const <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_rounded, size: 22.0,),
            SizedBox(width: 8.0,),
            Text("Loot Table")
          ],
        )
      ],
      children: <Widget>[ 
        LootTableTabView(
          lootTableModel: widget.lootTableModel,
          onUpdate: (newModel) {
            widget.onUpdate(newModel);
          }
        )
      ]
    );
  }
}