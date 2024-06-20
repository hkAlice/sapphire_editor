import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sapphire_editor/models/timeline/timepoint/timepoint_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorseq_point_model.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/directorvar_point_model.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/widgets/simple_number_field.dart';

class DirectorSeqPointWidget extends StatefulWidget {
  final TimepointModel timepointModel;
  final Function() onUpdate;

  const DirectorSeqPointWidget({super.key, required this.timepointModel, required this.onUpdate});

  @override
  State<DirectorSeqPointWidget> createState() => _DirectorSeqPointWidgetState();
}

class _DirectorSeqPointWidgetState extends State<DirectorSeqPointWidget> {
  late DirectorSeqPointModel pointData = widget.timepointModel.data as DirectorSeqPointModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 180,
          child: GenericItemPickerWidget<DirectorOpcode>(
            label: "Operation",
            items: DirectorOpcode.values,
            initialValue: pointData.opc,
            propertyBuilder: (value) {
              return treatEnumName(value);
            },
            onChanged: (newValue) {
              pointData.opc = newValue;
              widget.onUpdate();
              setState(() {
                
              });
            },
          ),
        ),
        const SizedBox(width: 18.0),
        SizedBox(
          width: 110,
          child: SimpleNumberField(
            label: "Value",
            initialValue: pointData.val,
            onChanged: (newValue) {
              pointData.val = newValue;
              widget.onUpdate();
            }
          ),
        )
      ],
    );
  }
}