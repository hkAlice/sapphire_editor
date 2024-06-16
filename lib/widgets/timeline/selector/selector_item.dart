import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';

class SelectorItem extends StatefulWidget {
  final TimelineModel timelineModel;
  final SelectorModel selectorModel;
  final int index;
  final Function(SelectorModel) onUpdate;

  const SelectorItem({super.key, required this.timelineModel, required this.selectorModel, required this.index, required this.onUpdate});

  @override
  State<SelectorItem> createState() => _SelectorItemState();
}

class _SelectorItemState extends State<SelectorItem> {
  
  @override
  Widget build(BuildContext context) {
    var filterCount = widget.selectorModel.filters.length;
    return Card(
      borderOnForeground: false,
      shadowColor: Colors.transparent,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ReorderableDragStartListener(
        index: widget.index,
        child: ExpansionTile(
          leading: const Icon(Icons.scatter_plot_outlined),
          title: Text(widget.selectorModel.name),
          subtitle: Text("${filterCount.toString()} filter${filterCount == 1 ? '' : 's'}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextModalEditorWidget(
                text: widget.selectorModel.name,
                minLines: 1,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    widget.selectorModel.name = value;
                  });
                  widget.onUpdate(widget.selectorModel);
                }
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  widget.timelineModel.selectors.removeAt(widget.index);
                  widget.onUpdate(widget.selectorModel);
                },
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                    
                  
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}