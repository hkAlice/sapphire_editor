import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/widgets/switch_text_widget.dart';

class SetBgmPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const SetBgmPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<SetBgmPointWidget> createState() => _SetBgmPointWidgetState();
}

class _SetBgmPointWidgetState extends State<SetBgmPointWidget> {
  late TextEditingController _bgmTextEditingController;

  late SetBgmPointModel pointData = widget.timepointModel.data as SetBgmPointModel;

  @override
  void initState() {
    _bgmTextEditingController = TextEditingController(text: pointData.bgmId.toString());

    super.initState();
  }

  @override
  void dispose() {
    _bgmTextEditingController.dispose();

    super.dispose();
  }

  Widget _generateIntInput({required TextEditingController textEditingController, required String label, required Function(String) onChanged}) {
    return Container(
      width: 150,
      child: TextFormField(
        maxLines: 1,
        controller: textEditingController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(label),
        ),
        onChanged: (value) { onChanged(value); }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _generateIntInput(
          textEditingController: _bgmTextEditingController,
          label: "BGM ID",
          onChanged: (value) {
            int newParamValue = 0;
            try {
              newParamValue = int.tryParse(value) ?? 0;
              pointData.bgmId = newParamValue;
              widget.onUpdate();
            }
            catch(e) { }

            setState(() {
              
            });
          }
        ),
      ],
    );
  }
}