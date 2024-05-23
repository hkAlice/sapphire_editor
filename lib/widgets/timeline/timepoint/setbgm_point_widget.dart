import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/setbgm_point_model.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150,
          child: SimpleNumberField(
            label: "BGM ID",
            initialValue: pointData.bgmId,
            onChanged: (value) {
              pointData.bgmId = value;
              widget.onUpdate();
            }
          ),
        ),
      ],
    );
  }
}