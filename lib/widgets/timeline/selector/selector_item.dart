import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/switch_icon_widget.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';
import 'package:sapphire_editor/widgets/text_modal_editor_widget.dart';
import 'package:signals/signals_flutter.dart';

class SelectorItem extends StatefulWidget {
  final int selectorId;
  final int index;

  const SelectorItem({super.key, required this.selectorId, required this.index});

  @override
  State<SelectorItem> createState() => _SelectorItemState();
}

class _SelectorItemState extends State<SelectorItem> {
  
@override
Widget build(BuildContext context) {
  final signals = SignalsProvider.of(context);
  
  return Watch((context) {
    final timeline = signals.timeline.value;
    
    // Get the selector reactively from the timeline
    final selectorModel = timeline.selectors.firstWhere(
      (s) => s.id == widget.selectorId,
      orElse: () => SelectorModel(id: 0, name: "Error"),
    );
    
    // If selector not found (deleted), return empty container
    if (selectorModel.id == 0) {
      return const SizedBox.shrink();
    }
    
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
          child: Text(selectorModel.name)
        ),
        subtitle: Text(selectorModel.toString()),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextModalEditorWidget(
              text: selectorModel.name,
              headerText: "Edit selector name",
              icon: const Icon(Icons.edit_rounded),
              minLines: 1,
              maxLines: 1,
              onChanged: (value) {
                signals.updateSelector(widget.selectorId, selectorModel.copyWith(name: value));
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
                  signals.removeSelector(widget.selectorId);
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
                        value: selectorModel.count,
                        onChanged: (value) {
                          signals.updateSelector(widget.selectorId, selectorModel.copyWith(count: value));
                        }
                      ),
                      const SizedBox(height: 8.0,),
                      
                      GenericItemPickerWidget<String>(
                        label: "Exclude selector result",
                        items: timeline.selectors.map((e) => e.name).toList()
                          ..remove(selectorModel.name)
                          ..insert(0, "<none>"),
                        initialValue: selectorModel.excludeSelectorName == "" ? "<none>" : selectorModel.excludeSelectorName,
                        onChanged: (value) {
                          final newValue = value == "<none>" ? "" : value;
                          signals.updateSelector(widget.selectorId, selectorModel.copyWith(excludeSelectorName: newValue));
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
                              enabled: selectorModel.fillRandomEntries,
                              leading: const Text("Fill random entries"),
                              onPressed: () {
                                signals.updateSelector(widget.selectorId, selectorModel.copyWith(fillRandomEntries: !selectorModel.fillRandomEntries));
                              }
                            ),
                          ),
                        ),
        const SizedBox(height: 8.0,),
        for(var filter in selectorModel.filters) ...[
          Column(
            children: [
              Row(
                children: [
                  SmallFilterLogicWidget(
                    first: selectorModel.filters.indexOf(filter) == 0,
                    logic: "And",
                    negate: filter.negate,
                  ),
                  SwitchIconWidget(
                    enabled: filter.negate,
                    icon: Icons.not_interested,
                    onPressed: () {
                      // Create updated filter and update the selector
                      final updatedFilter = filter.copyWith(negate: !filter.negate);
                      final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                      newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                      signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                    },
                  ),
                  SwitchIconWidget(
                    enabled: filter.enforceOnRandom,
                    icon: Icons.gavel_rounded,
                    onPressed: () {
                      // Create updated filter and update the selector
                      final updatedFilter = filter.copyWith(enforceOnRandom: !filter.enforceOnRandom);
                      final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                      newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                      signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
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
                        // Create updated filter and update the selector
                        final updatedFilter = filter.copyWith(type: newValue);
                        final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                        newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                        signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                      },
                    ),
                  ),
                  const SizedBox(width: 9.0,),
                  Flexible(
                    child: SimpleNumberField(
                      label: "Param",
                      initialValue: filter.param == null ? 0 : filter.param as int,
                      onChanged: (value) {
                        // Create updated filter and update the selector
                        final updatedFilter = filter.copyWith(param: value);
                        final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                        newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                        signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
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
                        final newFilters = List<SelectorFilterModel>.from(selectorModel.filters)..remove(filter);
                        signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9.0,),
            ],
          ),
        ],
        AddGenericWidget(
          text: "Add new filter",
          onTap: () {
            final newFilters = List<SelectorFilterModel>.from(selectorModel.filters)..add(SelectorFilterModel());
            signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
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
  });
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
