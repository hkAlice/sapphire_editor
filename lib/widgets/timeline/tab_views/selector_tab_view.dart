import 'package:flutter/material.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';
import 'package:sapphire_editor/widgets/timeline/selector/selector_item.dart';
import 'package:signals/signals_flutter.dart';

class SelectorTabView extends StatefulWidget {
  const SelectorTabView({super.key});

  @override
  State<SelectorTabView> createState() => _SelectorTabViewState();
}

class _SelectorTabViewState extends State<SelectorTabView> {
  @override
  Widget build(BuildContext context) {
    final signals = SignalsProvider.of(context);
    
    return Watch((context) {
      final timeline = signals.timeline.value;
      int selectorCount = timeline.selectors.length;

      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: SmallHeadingWidget(
                title: "$selectorCount selector${selectorCount == 1 ? '' : 's'}",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) {
                  signals.reorderSelector(oldIndex, newIndex);
                },
                itemCount: timeline.selectors.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  var selectorModel = timeline.selectors[i];
                  return SelectorItem(
                    key: Key("selector_${selectorModel.id}"),
                    index: i,
                    selectorId: selectorModel.id,
                  );
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: AddGenericWidget(
                text: "New selector",
                onTap: () {
                  signals.addSelector();
                }
              ),
            ),
          ],
        ),
      );
    });
  }
}
