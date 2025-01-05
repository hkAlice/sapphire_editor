import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/actor_model.dart';
import 'package:sapphire_editor/widgets/number_button.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class ActorGeneralWidget extends StatefulWidget {
  final int index;
  final ActorModel actorModel;
  final List<ActorModel> actors;
  final Function() onUpdate;

  const ActorGeneralWidget({super.key, required this.actorModel, required this.actors, required this.index, required this.onUpdate});

  @override
  State<ActorGeneralWidget> createState() => _ActorGeneralWidgetState();
}

class _ActorGeneralWidgetState extends State<ActorGeneralWidget> {
  late TextEditingController _localIdEditingController;
  late TextEditingController _layoutIdEditingController;
  late TextEditingController _hpEditingController;

  @override
  void initState() {
    _localIdEditingController = TextEditingController(text: widget.actorModel.id.toString());
    _layoutIdEditingController = TextEditingController(text: widget.actorModel.layoutId.toString());
    _hpEditingController = TextEditingController(text: widget.actorModel.hp.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // todo: fix this state issue in a proper manner
    _localIdEditingController.value = TextEditingValue(text: widget.actorModel.id.toString());
    _layoutIdEditingController.value = TextEditingValue(text: widget.actorModel.layoutId.toString());
    _hpEditingController.value = TextEditingValue(text: widget.actorModel.hp.toString());
    _localIdEditingController.selection = TextSelection.collapsed(offset: _localIdEditingController.text.length);
    _layoutIdEditingController.selection = TextSelection.collapsed(offset: _layoutIdEditingController.text.length);
    _hpEditingController.selection = TextSelection.collapsed(offset: _hpEditingController.text.length);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SmallHeadingWidget(
              title: "General",
              trailing: OutlinedButton(
                onPressed: null,
                child: Row(
                  children: [
                    Icon(Icons.terminal_rounded),
                    SizedBox(width: 8.0,),
                    Text("Load BNPC data"),
                  ],
                )
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: SimpleNumberField(
                    initialValue: widget.actorModel.id,
                    controller: _localIdEditingController,
                    label: "Local ID",
                    enabled: false,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 150,
                  child: SimpleNumberField(
                    initialValue: widget.actorModel.layoutId,
                    controller: _layoutIdEditingController,
                    label: "Layout ID",
                    onChanged: (value) {
                      widget.actorModel.layoutId = value;
                      widget.onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 18.0,),
                SizedBox(
                  width: 110,
                  child: SimpleNumberField(
                    initialValue: widget.actorModel.hp,
                    controller: _hpEditingController,
                    label: "HP",
                    onChanged: (value) {
                      widget.actorModel.hp = value;
                      widget.onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 18.0,),
                NumberButton(
                  min: 0,
                  max: 32,
                  value: widget.actorModel.subactors.length,
                  label: "Subactors",
                  onChanged: (value) {
                    var subactorCount = widget.actorModel.subactors.length;
                    if(value < subactorCount) {
                      widget.actorModel.subactors.removeLast();
                    }
                    else if(value > subactorCount) {
                      widget.actorModel.subactors.add("${widget.actorModel.name} <subactor ${subactorCount + 1}>");
                    }
            
                    widget.onUpdate();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubActorNameEditDialog extends StatefulWidget {
  final ActorModel selectedActor;
  final Function() onChanged;

  const _SubActorNameEditDialog({required this.selectedActor, required this.onChanged});

  @override
  State<_SubActorNameEditDialog> createState() => __SubActorNameEditDialogState();
}

class __SubActorNameEditDialogState extends State<_SubActorNameEditDialog> {
  final List<TextEditingController> _controllers = [];

  List<Widget> _generateFields() {
    List<Widget> fields = [];
    for(var subactor in widget.selectedActor.subactors) {
      var controller = TextEditingController(text: subactor);
      _controllers.add(controller);

      fields.add(TextField(
        maxLines: 1,
        minLines: 1,
        autofocus: false,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          border: InputBorder.none,
          helperText: subactor
        ),
        
        onChanged: (value) {
          var idx = widget.selectedActor.subactors.indexOf(subactor);
          widget.selectedActor.subactors[idx] = value;
          subactor = value;
          widget.onChanged();
        },
      ));
      fields.add(const SizedBox(height: 8.0,));
    }

    if(fields.isEmpty) {
      fields.add(const Center(child: Text("No subactors? Gyatt?"),));
    }

    return fields;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for(var controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Edit subactor names"),
          SizedBox(
            width: 32.0,
            height: 32.0,
            child: IconButton.outlined(
              padding: const EdgeInsets.all(0.0),
              icon: const Icon(Icons.close),
              splashRadius: 28.0,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
      //contentPadding: const EdgeInsets.all(12.0),
      content: Container(
        constraints: const BoxConstraints(minWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _generateFields()
          ),
        ),
      )
    );
  }
}