import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/models/timeline/timeline_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_icon_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
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
    return Card(
      borderOnForeground: false,
      //shadowColor: Colors.transparent,
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        leading: const Icon(Icons.scatter_plot_outlined),
        title: ReorderableDragStartListener(
          index: widget.index,
          child: Text(widget.selectorModel.name)
        ),
        subtitle: Text(widget.selectorModel.toString()),
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
                  setState(() {
                    
                  });
                  widget.onUpdate(widget.selectorModel);
                },
              ),
            ),
          ],
        ),
        children: [
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("Result", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.start,),
                      const SizedBox(height: 16.0,),
                      NumberButton(
                        min: 1,
                        max: 32,
                        label: "Count",
                        value: widget.selectorModel.count,
                        onChanged: (value) {
                          setState(() {
                            widget.selectorModel.count = value;
                          });
                          
                          widget.onUpdate(widget.selectorModel);
                        }
                      ),
                      const SizedBox(height: 8.0,),
                      
                      GenericItemPickerWidget<String>(
                        label: "Exclude selector result",
                        items: widget.timelineModel.selectors.map((e) => e.name).toList()
                          ..remove(widget.selectorModel.name)
                          ..insert(0, "<none>"),
                        initialValue: widget.selectorModel.excludeSelectorName == "" ? "<none>" : widget.selectorModel.excludeSelectorName,
                        onChanged: (value) {
                          if(value == "<none>") {
                            value = "";
                          }
      
                          widget.selectorModel.excludeSelectorName = value;
                          widget.onUpdate(widget.selectorModel);
                        },
                      )
                    ],
                  ),
                ),
                const VerticalDivider(),
                Flexible(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: 200,
                          child: SwitchTextWidget(
                            enabled: widget.selectorModel.fillRandomEntries,
                            leading: const Text("Fill random entries"),
                            onPressed: () {
                              setState(() {
                                widget.selectorModel.fillRandomEntries = !widget.selectorModel.fillRandomEntries;
                              });
                              
                              widget.onUpdate(widget.selectorModel);
                            }
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0,),
                        for(var filter in widget.selectorModel.filters)
                          Column(
                            children: [
                              Row(
                                children: [
                                  SmallFilterLogicWidget(
                                    first: widget.selectorModel.filters.indexOf(filter) == 0,
                                    logic: "And",
                                    negate: filter.negate,
                                  ),
                                  SwitchIconWidget(
                                    enabled: filter.negate,
                                    icon: Icons.not_interested,
                                    onPressed: () {
                                      setState(() {
                                        filter.negate = !filter.negate;
                                      });
                                      widget.onUpdate(widget.selectorModel);
                                    },
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: GenericItemPickerWidget<SelectorFilterType>(
                                      label: "Filter",
                                      items: SelectorFilterType.values,
                                      initialValue: filter.type,
                                      propertyBuilder: (value) {
                                        return treatEnumName(value);
                                      },
                                      onChanged: (newValue) {
                                        filter.type = newValue;
                                        widget.onUpdate(widget.selectorModel);
                                        setState(() {
                                          
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 9.0,),
                                  
                                  Flexible(
                                    child: SimpleNumberField(
                                      label: "Param",
                                      initialValue: filter.param == null ? 0 : filter.param as int,
                                      onChanged: (value) {
                                        filter.param = value as dynamic;
                                        widget.onUpdate(widget.selectorModel);
                                      }
                                    ),
                                  ),
                                  const SizedBox(width: 4.0,),
                                  SizedBox(
                                    width: 32.0,
                                    height: 32.0,
                                    child: IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      splashRadius: 24.0,
                                      padding: const EdgeInsets.all(2.0),
                                      onPressed: () {
                                        widget.selectorModel.filters.remove(filter);
                                        widget.onUpdate(widget.selectorModel);
                                        setState(() {
                                          
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9.0,),
                            ],
                          ),
                        AddGenericWidget(
                          text: "Add new filter",
                          onTap: () {
                            widget.selectorModel.filters.add(SelectorFilterModel());
                            setState(() {
                              
                            });
                            widget.onUpdate(widget.selectorModel);
                          }
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          
        ]
      ),
    );
  }
}

class SmallFilterLogicWidget extends StatelessWidget {
  final bool first;
  final String logic;
  final bool negate;

  const SmallFilterLogicWidget({super.key, required this.first, required this.logic, required this.negate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white12
      ),
      width: 84.0,
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          first ? Container() : Icon(Icons.subdirectory_arrow_right_rounded, size: 12.0, color: Theme.of(context).primaryColor,),
          first ? Container() : const SizedBox(width: 4.0,),
          Text(
            (first ? "Where".toUpperCase() : logic.toUpperCase()) + (negate ? " NOT" : ""),
            style: Theme.of(context).textTheme.labelMedium,
          )
        ],
      ),
    );
  }
}