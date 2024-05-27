import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleNumberField extends StatefulWidget {
  final String? label;
  final int? initialValue;
  final bool isHex;
  final TextEditingController? controller;
  final Function(int) onChanged;
  final bool enabled;

  const SimpleNumberField({super.key, required this.onChanged, this.label, this.enabled = true, this.initialValue, this.controller, this.isHex = false});

  @override
  State<SimpleNumberField> createState() => _SimpleNumberFieldState();
}

class _SimpleNumberFieldState extends State<SimpleNumberField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();

    if(widget.controller == null) {
      _controller = TextEditingController(text: (widget.initialValue ?? 0).toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      maxLines: 1,
      keyboardType: widget.isHex ? TextInputType.text : TextInputType.number,
      inputFormatters: widget.isHex ? null : <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: _controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        label: widget.label == null ? null : Text(widget.label!),
      ),
      onChanged: (value) {
        int newValue = 0;
        try {
          newValue = int.tryParse(value, radix: widget.isHex ? 16 : null) ?? 0;
        }
        catch(e) {
          // failed to parse, ignore
          return;
        }

        _controller.text = widget.isHex ? newValue.toRadixString(16) : newValue.toString();
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    
        widget.onChanged(newValue);

        setState(() {
          
        });
      },
    );
  }
}