import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

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
      //shadowColor: Colors.transparent,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ReorderableDragStartListener(
        index: widget.index,
        child: ExpansionTile(
          leading: const Icon(Icons.scatter_plot_outlined),
          title: Text(widget.selectorModel.name),
          subtitle: Text("${filterCount.toString()} filter${filterCount == 1 ? '' : 's'}"),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextModalEditorWidget(
                text: widget.selectorModel.name,
                headerText: "Edit selector name",
                icon: const Icon(Icons.edit_rounded),
                minLines: 1,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    widget.selectorModel.name = value;
                  });
                  widget.onUpdate(widget.selectorModel);
                }
              ),
              SizedBox(
                width: 32.0,
                height: 32.0,
                child: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  splashRadius: 24.0,
                  padding: const EdgeInsets.all(2.0),
                  onPressed: () {
                    widget.timelineModel.selectors.removeAt(widget.index);
                    widget.onUpdate(widget.selectorModel);
                  },
                ),
              ),
            ],
          ),
          children: [
            for(var filter in widget.selectorModel.filters)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(toBeginningOfSentenceCase(filter.type.name)),
                  ),
                ],
              )
          ]
        ),
      ),
    );
  }
}