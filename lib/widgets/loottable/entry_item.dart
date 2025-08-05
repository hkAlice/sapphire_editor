import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/loottable/lootpool_model.dart';
import 'package:sapphire_editor/models/repository/item_minimal.dart';
import 'package:sapphire_editor/repositories/local_repository.dart';
import 'package:sapphire_editor/repositories/xivapi_repository.dart';
import 'package:sapphire_editor/widgets/generic_search_picker_widget.dart';
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
    var itemMinimal = LocalRepository().getItemMinimal(widget.lootEntryModel.item);
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
                    height: 50,
                    child: GenericSearchPickerWidget<ItemMinimal>(
                      items: LocalRepository().getAllItemMinimal(),
                      value: itemMinimal,
                      propertyBuilder: (item) => item.name.isEmpty ? "<empty>" : item.name,
                      itemBuilder: (item) => DropdownMenuEntry(
                        value: item,
                        label: item.name,
                      ),
                      onChanged: (item) {
                        widget.lootEntryModel.item = item.id;
                        widget.onUpdate(widget.lootEntryModel);
                        setState(() {
                          
                        });
                      },
                    ),
                  ),

                  /*SizedBox(
                    width: 300,
                    height: 60,
                    child: GenericSearchPickerWidget<ItemMinimal>(
                      initialValue: LocalRepository().getItemMinimal(widget.lootEntryModel.item),
                      items: LocalRepository().getAllItemMinimal(),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.search),
                          ),
                          Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                      onChanged: (value) {
                        if(value == null) {
                          return;
                        }
                    
                        //widget.lootEntryModel.item = value;
                        widget.onUpdate(widget.lootEntryModel);
                      },
                      itemBuilder: (item) {
                        return DropdownMenuEntry<ItemMinimal>(
                          label: item.name,
                          value: item,
                          leadingIcon: Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
                          labelWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name),
                              Text("iLvl ${item.iLvl}")
                            ],
                          )
                        );
                      }
                    ),
                  ),*/
                  SizedBox(
                    width: 100,
                    child: SimpleNumberField(
                      initialValue: widget.lootEntryModel.item,
                      label: "Item ID",
                      onChanged: (value) {
                        widget.lootEntryModel.item = value;
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