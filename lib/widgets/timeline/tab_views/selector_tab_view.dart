import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/selector/selector_item.dart';

class SelectorTabView extends StatefulWidget {
  final TimelineModel timelineModel;
  final Function() onUpdate;

  const SelectorTabView({super.key, required this.timelineModel, required this.onUpdate});

  @override
  State<SelectorTabView> createState() => _SelectorTabViewState();
}

class _SelectorTabViewState extends State<SelectorTabView> {
  @override
  Widget build(BuildContext context) {
    int selectorCount = widget.timelineModel.selectors.length;
    
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SmallHeadingWidget(
              title: "$selectorCount selector${selectorCount == 1 ? '' : 's'}",
            ),
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                setState(() {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = widget.timelineModel.selectors.removeAt(oldindex);
                  widget.timelineModel.selectors.insert(newindex, items);
                });
                widget.onUpdate();
              },
              itemCount: widget.timelineModel.selectors.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var selectorModel = widget.timelineModel.selectors[i];
                return SelectorItem(
                  key: Key("selector_${selectorModel.id}"),
                  timelineModel: widget.timelineModel,
                  index: i,
                  selectorModel: selectorModel,
                  onUpdate: (selectorModel) {
                    widget.onUpdate();
                  },
                );
              }
            ),
            AddGenericWidget(
              text: "Add new selector",
              onTap: () {
                setState(() {
                  widget.timelineModel.addNewSelector();
                });

                widget.onUpdate();
              }
            ),
          ],
        ),
      ),
    );
  }
}