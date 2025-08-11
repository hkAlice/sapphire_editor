import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';
import 'package:sapphire_editor/models/repository/item_minimal.dart';
import 'package:sapphire_editor/repositories/local_repository.dart';
import 'package:sapphire_editor/repositories/xivapi_repository.dart';
import 'package:sapphire_editor/widgets/generic_search_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/switch_icon_widget.dart';

class EntryItem extends StatefulWidget {
  final LootItemModel lootEntryModel;
  final LootPoolModel lootPoolModel;
  final Function(LootItemModel) onUpdate;

  const EntryItem({super.key, required this.lootEntryModel, required this.lootPoolModel, required this.onUpdate});

  @override
  State<EntryItem> createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  late TextEditingController _itemIdController;

  double calculateChance() {
    final totalWeight = widget.lootPoolModel.items.fold(0, (sum, e) => sum + e.weight);

    return (widget.lootEntryModel.weight / totalWeight) * 100;
  }

  @override
  void initState() {
    _itemIdController = TextEditingController(text: widget.lootEntryModel.id.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var itemMinimal = LocalRepository().getItemMinimal(widget.lootEntryModel.id);
    var iconId = itemMinimal?.icon;
    
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
                    child: CachedNetworkImage(imageUrl: XivApiRepository().getItemIconURL(iconId ?? 500))
                  ),
                  VerticalDivider(),
                  SizedBox(
                    width: 300,
                    child: GenericSearchPickerWidget<ItemMinimal>(
                      items: LocalRepository().getAllItemMinimal(),
                      value: itemMinimal,
                      propertyBuilder: (item) => item.name.isEmpty ? "<empty>" : item.name,
                      label: "Item",
                      itemBuilder: (item) => DropdownMenuEntry(
                        value: item,
                        label: item.name,
                      ),
                      onChanged: (item) {
                        widget.lootEntryModel.id = item.id;
                        _itemIdController.text = item.id.toString();
                        widget.onUpdate(widget.lootEntryModel);
                        setState(() {
                          
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 18.0,),
                  SizedBox(
                    width: 100,
                    child: SimpleNumberField(
                      initialValue: widget.lootEntryModel.id,
                      controller: _itemIdController,
                      label: "Item ID",
                      onChanged: (value) {
                        widget.lootEntryModel.id = value;
                        widget.onUpdate(widget.lootEntryModel);
                        setState(() {
                          
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
              SwitchIconWidget(
                    enabled: widget.lootEntryModel.isHq,
                    onPressed: () {
                      widget.lootEntryModel.isHq = !widget.lootEntryModel.isHq;
                      widget.onUpdate(widget.lootEntryModel);
                      setState(() {
                        
                      });
                    },
                    icon: Icons.high_quality_rounded
                  ),
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  widget.lootPoolModel.items.remove(widget.lootEntryModel);
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