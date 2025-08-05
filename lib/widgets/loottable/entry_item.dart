import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class EntryItem extends StatefulWidget {
  final LootEntryModel lootEntryModel;
  final LootPoolModel lootPoolModel;
  final Function(LootEntryModel) onUpdate;

  const EntryItem({super.key, required this.lootEntryModel, required this.lootPoolModel, required this.onUpdate});

  @override
  State<EntryItem> createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  double calculateChance() {
    final totalWeight = widget.lootPoolModel.entries.fold(0, (sum, e) => sum + e.weight);

    return (widget.lootEntryModel.weight / totalWeight) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Placeholder(),
                  ),
                  VerticalDivider(),
                  SizedBox(
                    width: 300,
                    child: SimpleNumberField(
                      initialValue: widget.lootEntryModel.item,
                      label: "Item ID",
                      onChanged: (value) {
                        setState(() {
                          widget.lootEntryModel.item = value;
                        });
                      }
                    ),
                  ),
                  SizedBox(width: 18.0,),
                  SizedBox(
                    width: 100,
                    child: SimpleNumberField(
                      initialValue: widget.lootEntryModel.weight,
                      label: "Weight",
                      onChanged: (value) {
                        widget.onUpdate(widget.lootEntryModel);
                        setState(() {
                          widget.lootEntryModel.weight = value;
                        });
                      }
                    ),
                  ),
                  SizedBox(width: 8.0,),
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("~${calculateChance().toStringAsFixed(2)}%", style: Theme.of(context).textTheme.bodySmall,),
                    )
                  )
                ],
              ),
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  widget.lootPoolModel.entries.remove(widget.lootEntryModel);
                  widget.onUpdate(widget.lootEntryModel);
                },
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}