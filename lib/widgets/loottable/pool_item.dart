import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';
import 'package:sapphire_editor/models/loottable/loottable_model.dart';
import 'package:sapphire_editor/widgets/add_generic_widget.dart';
import 'package:sapphire_editor/widgets/loottable/entry_item.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class PoolItem extends StatefulWidget {
  final LootTableModel lootTableModel;
  final LootPoolModel lootPoolModel;
  final int index;
  final Function(LootPoolModel) onUpdate;

  const PoolItem({super.key, required this.lootTableModel, required this.lootPoolModel, required this.index, required this.onUpdate});

  @override
  State<PoolItem> createState() => _PoolItemState();
}

class _PoolItemState extends State<PoolItem> {
  int _totalWeight = 0;
  late TextEditingController _weightController;
  late TextEditingController _pickMinController;
  late TextEditingController _pickMaxController;

  int _calculateTotalWeight() {
    return widget.lootPoolModel.items.fold(0, (sum, e) => sum + e.weight);
  }

  @override
  void initState() {
    _totalWeight = _calculateTotalWeight();
    _weightController = TextEditingController(text: _totalWeight.toString());
    _pickMinController = TextEditingController(text: widget.lootPoolModel.pick.min.toString());
    _pickMaxController = TextEditingController(text: widget.lootPoolModel.pick.max.toString());
    super.initState();
  }
  @override
  void dispose() {
    _weightController.dispose();
    _pickMinController.dispose();
    _pickMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _weightController.value = TextEditingValue(text: _calculateTotalWeight().toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.lootPoolModel.name,
          border: OutlineInputBorder(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 18.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: NumberButton(
                        min: 0,
                        max: 999,
                        value: widget.lootPoolModel.pick.min,
                        label: "Min Picks",
                        enabled: true,
                        onChanged: (value) {
                          widget.lootPoolModel.pick.min = value;
                          widget.onUpdate(widget.lootPoolModel);
                        },
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Opacity(opacity: 0.5, child: Icon(Icons.arrow_right_alt_rounded)),
                    SizedBox(width: 8.0),
                    SizedBox(
                      width: 100,
                      child: NumberButton(
                        min: 0,
                        max: 999,
                        value: widget.lootPoolModel.pick.max,
                        label: "Max Picks",
                        enabled: true,
                        onChanged: (value) {
                          widget.lootPoolModel.pick.max = value;
                          widget.onUpdate(widget.lootPoolModel);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: SimpleNumberField(
                        initialValue: _calculateTotalWeight(),
                        controller: _weightController,
                        label: "Total Weight",
                        readOnly: true,
                        onChanged: (value) {

                        },
                      ),
                    ),
                    SizedBox(width: 24.0,),
                    Column(
                      children: [
                        SizedBox(
                          width: 180,
                          child: SwitchTextWidget(
                            enabled: widget.lootPoolModel.enabled,
                            onPressed: () {
                              widget.lootPoolModel.enabled = !widget.lootPoolModel.enabled;
                              widget.onUpdate(widget.lootPoolModel);
                              setState(() {
                                
                              });
                            },
                            toggleText: ("ENABLED", "DISABLED"),
                            leading: const Text("Toggle Pool"),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: SwitchTextWidget(
                            enabled: widget.lootPoolModel.duplicates,
                            onPressed: () {
                              widget.lootPoolModel.duplicates = !widget.lootPoolModel.duplicates;
                              widget.onUpdate(widget.lootPoolModel);
                              setState(() {
                                
                              });
                            },
                            toggleText: ("ENABLED", "DISABLED"),
                            leading: const Text("Duplicates"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.0,),
            Text("Entries", style: Theme.of(context).textTheme.bodyLarge,),
            SizedBox(height: 12.0,),
            ListView.builder(
              itemCount: widget.lootPoolModel.items.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var entry = widget.lootPoolModel.items[i];
            
                return EntryItem(
                  key: Key(entry.hashCode.toString()),
                  lootEntryModel: entry,
                  lootPoolModel: widget.lootPoolModel,
                  onUpdate: (lootEntryModel) {
                    widget.onUpdate(widget.lootPoolModel);
                    setState(() {
                      
                    });
                  },
                );
              }
            ),
            SmallAddGenericWidget(
              onTap: () {
                widget.lootPoolModel.items.add(LootItemModel(id: 0, weight: 1, isHq: false, quantity: LootRangeModel(min: 1, max: 1)));
                widget.onUpdate(widget.lootPoolModel);
                setState(() {
                  
                });
              },
              text: "Add item drop",
            )
          ],
        ),
      ),
    );
  }
}

class PoolItemModern extends StatefulWidget {
  final LootTableModel lootTableModel;
  final LootPoolModel lootPoolModel;
  final int index;
  final Function(LootPoolModel) onUpdate;

  const PoolItemModern({super.key, required this.lootTableModel, required this.lootPoolModel, required this.index, required this.onUpdate});

  @override
  State<PoolItemModern> createState() => _PoolItemModernState();
}

class _PoolItemModernState extends State<PoolItemModern> {
  int _totalWeight = 0;
  late TextEditingController _weightController;
  late TextEditingController _pickMinController;
  late TextEditingController _pickMaxController;

  int _calculateTotalWeight() {
    return widget.lootPoolModel.items.fold(0, (sum, e) => sum + e.weight);
  }

  @override
  void initState() {
    _totalWeight = _calculateTotalWeight();
    _weightController = TextEditingController(text: _totalWeight.toString());
    _pickMinController = TextEditingController(text: widget.lootPoolModel.pick.min.toString());
    _pickMaxController = TextEditingController(text: widget.lootPoolModel.pick.max.toString());
    super.initState();
  }
  @override
  void dispose() {
    _weightController.dispose();
    _pickMinController.dispose();
    _pickMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _weightController.value = TextEditingValue(text: _calculateTotalWeight().toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.lootPoolModel.name,
          border: OutlineInputBorder(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 18.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    
                    SizedBox(
                      width: 100,
                      child: SimpleNumberField(
                        initialValue: _calculateTotalWeight(),
                        controller: _pickMinController,
                        label: "Min Picks",
                        enabled: true,
                        onChanged: (value) {
                          widget.lootPoolModel.pick.min = value;
                          widget.onUpdate(widget.lootPoolModel);
                        },
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Opacity(opacity: 0.5, child: Text("→", style: Theme.of(context).textTheme.headlineSmall)),
                    SizedBox(width: 8.0),
                    SizedBox(
                      width: 100,
                      child: SimpleNumberField(
                        initialValue: _calculateTotalWeight(),
                        controller: _pickMaxController,
                        label: "Max Picks",
                        enabled: true,
                        onChanged: (value) {
                          widget.lootPoolModel.pick.max = value;
                          widget.onUpdate(widget.lootPoolModel);
                        },
                      ),
                    ),
                    SizedBox(width: 83,),
                    SizedBox(
                      width: 100,
                      child: SimpleNumberField(
                        initialValue: _calculateTotalWeight(),
                        controller: _weightController,
                        label: "Total Weight",
                        readOnly: true,
                        onChanged: (value) {

                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 140,
                  child: SwitchTextWidget(
                    enabled: widget.lootPoolModel.enabled,
                    onPressed: () {
                      widget.lootPoolModel.enabled = !widget.lootPoolModel.enabled;
                      widget.onUpdate(widget.lootPoolModel);
                      _totalWeight = _calculateTotalWeight();
                      setState(() {
                        
                      });
                    },
                    toggleText: ("ENABLED", "DISABLED"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0,),
            Text("Entries", style: Theme.of(context).textTheme.bodyLarge,),
            SizedBox(height: 12.0,),
            ListView.builder(
              itemCount: widget.lootPoolModel.items.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var entry = widget.lootPoolModel.items[i];
            
                return EntryItem(
                  key: Key(entry.hashCode.toString()),
                  lootEntryModel: entry,
                  lootPoolModel: widget.lootPoolModel,
                  onUpdate: (lootEntryModel) {
                    widget.onUpdate(widget.lootPoolModel);
                    setState(() {
                      
                    });
                  },
                );
              }
            ),
            SmallAddGenericWidget(
              onTap: () {
                widget.lootPoolModel.items.add(LootItemModel(id: 0, weight: 1, isHq: false, quantity: LootRangeModel(min: 1, max: 1)));
                widget.onUpdate(widget.lootPoolModel);
                setState(() {
                  
                });
              },
              text: "Add item drop",
            )
          ],
        ),
      ),
    );
  }
}