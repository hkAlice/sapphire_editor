import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';
import 'package:sapphire_editor/models/loottable/loottable_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/loottable/pool_item.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class LootTableTabView extends StatefulWidget {
  final LootTableModel lootTableModel;
  final Function(LootTableModel) onUpdate;

  const LootTableTabView({super.key, required this.lootTableModel, required this.onUpdate});

  @override
  State<LootTableTabView> createState() => _LootTableTabViewState();
}

class _LootTableTabViewState extends State<LootTableTabView> {
  late TextEditingController _nameTextEditingController;

  @override
  void initState() {
    _nameTextEditingController = TextEditingController(text: widget.lootTableModel.lootTable);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SmallHeadingWidget(
              title: "General",
            ),
            SizedBox(height: 10.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 1,
                    minLines: 1,
                    autofocus: false,
                    controller: _nameTextEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Loot Table Name",
                    ),
                    
                    onChanged: (value) {
                      widget.lootTableModel.lootTable = value;
                      widget.onUpdate(widget.lootTableModel);
                    },
                  ),
                ),
                SizedBox(width: 18.0),
                SizedBox(
                  width: 150,
                  child: GenericItemPickerWidget<LootTableType>(
                    label: "Trigger Type",
                    items: LootTableType.values,
                    initialValue: widget.lootTableModel.type,
                    onChanged: (newValue) {
                      widget.lootTableModel.type = newValue;
                      widget.onUpdate(widget.lootTableModel);
                      setState(() {
                        
                      });
                    },
                    propertyBuilder: (e) {
                      return treatEnumName(e);
                    },
                  )
                ),
              ],
            ),
            SizedBox(height: 18.0,),
            SmallHeadingWidget(
              title: "Pools",
              trailing: AddGenericWidget(
                text: "Add pool",
                onTap: () {
                  int poolNumber = widget.lootTableModel.pools.length + 1;
                  var newPool = LootPoolModel(
                    name: "Pool #$poolNumber",
                    pick: LootRangeModel(min: 1, max: 1),
                    items: [LootItemModel(id: 0, weight: 1, isHq: false, quantity: LootRangeModel(min: 1, max: 1))],
                    enabled: true,
                    duplicates: true
                  );
                  widget.lootTableModel.pools.add(newPool);
                  widget.onUpdate(widget.lootTableModel);
                  setState(() {
                    
                  });
                }
              ),
            ),
            SizedBox(height: 10.0,),
            ReorderableListView.builder(
              buildDefaultDragHandles: false,
              onReorder: (int oldindex, int newindex) {
                setState(() {
                  if(newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = widget.lootTableModel.pools.removeAt(oldindex);
                  widget.lootTableModel.pools.insert(newindex, items);
                });
            
                widget.onUpdate(widget.lootTableModel);
              },
              itemCount: widget.lootTableModel.pools.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var pool = widget.lootTableModel.pools[i];
            
                return PoolItem(
                  key: Key("pool_${pool.hashCode}"),
                  index: i,
                  lootTableModel: widget.lootTableModel,
                  lootPoolModel: pool,
                  onUpdate: (lootPoolModel) {
                    widget.lootTableModel.pools[i] = lootPoolModel;
                    widget.onUpdate(widget.lootTableModel);
                  },
                );
              }
            ),
            SizedBox(height: 18.0,),
          ],
        ),
      ),
    );
  }
}