import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_filter_model.dart';
import 'package:sapphire_editor/models/timeline/selector/selector_model.dart';
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
      
      final selectorModel = timeline.selectors.firstWhere(
        (s) => s.id == widget.selectorId,
        orElse: () => SelectorModel(id: 0, name: "Error"),
      );
      
      if(selectorModel.id == 0) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: const Color(0xFF333333), width: 1.0),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            minTileHeight: 40.0,
            leading: const Icon(Icons.scatter_plot_outlined, size: 20.0, color: Colors.grey),
            title: ReorderableDragStartListener(
              index: widget.index,
              child: Text(
                selectorModel.name,
                style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
              )
            ),
            subtitle: Text(
              selectorModel.toString(),
              style: GoogleFonts.lilex(fontSize: 12.0, color: Colors.grey[400]),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextModalEditorWidget(
                  text: selectorModel.name,
                  headerText: "Edit selector name",
                  icon: const Icon(Icons.edit_rounded, size: 16.0),
                  minLines: 1,
                  maxLines: 1,
                  onChanged: (value) {
                    signals.updateSelector(widget.selectorId, selectorModel.copyWith(name: value));
                  }
                ),
                SizedBox(
                  width: 28.0,
                  height: 28.0,
                  child: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16.0),
                    splashRadius: 20.0,
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      signals.removeSelector(widget.selectorId);
                    },
                  ),
                ),
              ],
            ),
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF333333), width: 1.0)),
                  color: Color(0xFF141414),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF333333), width: 1.0),
                          borderRadius: BorderRadius.circular(2.0),
                          color: const Color(0xFF1E1E1E),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Result".toUpperCase(), 
                              style: GoogleFonts.lilex(fontSize: 11.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), 
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 12.0),
                            NumberButton(
                              min: 1,
                              max: 32,
                              label: "Count",
                              value: selectorModel.count,
                              onChanged: (value) {
                                signals.updateSelector(widget.selectorId, selectorModel.copyWith(count: value));
                              }
                            ),
                            const SizedBox(height: 8.0),
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
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      flex: 7,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF333333), width: 1.0),
                          borderRadius: BorderRadius.circular(2.0),
                          color: const Color(0xFF1E1E1E),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Filters".toUpperCase(), 
                                  style: GoogleFonts.lilex(fontSize: 11.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), 
                                ),
                                SwitchTextWidget(
                                  enabled: selectorModel.fillRandomEntries,
                                  leading: const Text("Fill random entries", style: TextStyle(fontSize: 12.0)),
                                  onPressed: () {
                                    signals.updateSelector(widget.selectorId, selectorModel.copyWith(fillRandomEntries: !selectorModel.fillRandomEntries));
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            for(var filter in selectorModel.filters) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 6.0),
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252525),
                                  border: Border.all(color: const Color(0xFF444444), width: 1.0),
                                  borderRadius: BorderRadius.circular(2.0)
                                ),
                                child: Row(
                                  children: [
                                    SmallFilterLogicWidget(
                                      first: selectorModel.filters.indexOf(filter) == 0,
                                      logic: "And",
                                      negate: filter.negate,
                                    ),
                                    const SizedBox(width: 4.0),
                                    SwitchIconWidget(
                                      enabled: filter.negate,
                                      icon: Icons.not_interested,
                                      onPressed: () {
                                        final updatedFilter = filter.copyWith(negate: !filter.negate);
                                        final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                                        newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                                        signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                                      },
                                    ),
                                    const SizedBox(width: 4.0),
                                    SwitchIconWidget(
                                      enabled: filter.enforceOnRandom,
                                      icon: Icons.gavel_rounded,
                                      onPressed: () {
                                        final updatedFilter = filter.copyWith(enforceOnRandom: !filter.enforceOnRandom);
                                        final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                                        newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                                        signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                                      },
                                    ),
                                    const SizedBox(width: 8.0),
                                    SizedBox(
                                      width: 160,
                                      child: GenericItemPickerWidget<SelectorFilterType>(
                                        label: "Filter",
                                        items: SelectorFilterType.values,
                                        initialValue: filter.type,
                                        propertyBuilder: (value) {
                                          return treatEnumName(value);
                                        },
                                        onChanged: (newValue) {
                                          final updatedFilter = filter.copyWith(type: newValue);
                                          final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                                          newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                                          signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Flexible(
                                      child: SimpleNumberField(
                                        label: "Param",
                                        initialValue: filter.param == null ? 0 : filter.param as int,
                                        onChanged: (value) {
                                          final updatedFilter = filter.copyWith(param: value);
                                          final newFilters = List<SelectorFilterModel>.from(selectorModel.filters);
                                          newFilters[selectorModel.filters.indexOf(filter)] = updatedFilter;
                                          signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                                        }
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    SizedBox(
                                      width: 28.0,
                                      height: 28.0,
                                      child: IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 14.0),
                                        splashRadius: 18.0,
                                        padding: const EdgeInsets.all(0.0),
                                        onPressed: () {
                                          final newFilters = List<SelectorFilterModel>.from(selectorModel.filters)..remove(filter);
                                          signals.updateSelector(widget.selectorId, selectorModel.copyWith(filters: newFilters));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 6.0),
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
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: const Color(0xFF444444), width: 1.0),
        borderRadius: BorderRadius.circular(2.0),
      ),
      width: 78.0,
      height: 28.0,
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          first ? Container() : const Icon(Icons.subdirectory_arrow_right_rounded, size: 12.0, color: Colors.orangeAccent),
          first ? Container() : const SizedBox(width: 4.0,),
          Text(
            (first ? "WHERE" : logic.toUpperCase()) + (negate ? " NOT" : ""),
            style: GoogleFonts.lilex(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.grey[300]),
          )
        ],
      ),
    );
  }
}
