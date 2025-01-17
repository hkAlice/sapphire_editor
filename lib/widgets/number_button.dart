import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberButton extends StatefulWidget {
  final int min;
  final int max;
  final int value;
  final Function(int) onChanged;
  final String? label;
  final int stepCount;
  final String Function(int)? builder;
  final bool enabled;
  final bool readOnlyField;
  final List<TextInputFormatter>? inputFormatters;

  const NumberButton({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    this.inputFormatters,
    this.enabled = true,
    this.readOnlyField = false,
    this.stepCount = 1,
    this.builder,
    required this.onChanged,
    this.label,
  });

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int _numValue;
  bool _holdingStepper = false;
  late TextEditingController _controller;

  void _setBoundValue(int value) {
    _numValue = value;
    if(_numValue <= widget.min) {
      _numValue = widget.min;
    }
    if(_numValue >= widget.max) {
      _numValue = widget.max;
    }
    
    _controller.text = widget.builder != null ? widget.builder!(_numValue) : _numValue.toString();
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);

    widget.onChanged(_numValue);
  }

  @override
  void initState() {
    super.initState();
    _numValue = widget.value;
    _controller = TextEditingController(text: widget.builder != null ? widget.builder!(_numValue) : _numValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Stack(
        children: [
          TextField(
            enabled: widget.enabled,
            readOnly: widget.readOnlyField,
            maxLines: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: _controller,
            decoration: InputDecoration(
              filled: false,
              border: OutlineInputBorder(),
              label: widget.label == null ? null : Text(widget.label!),
            ),
            onChanged: (value) {
              int newValue = 0;
              try {
                newValue = int.tryParse(value) ?? 0;
              }
              catch(e) {
                // failed to parse, ignore
                return;
              }
              
              _setBoundValue(newValue);
            },
          ),
          Transform.translate(
            offset: const Offset(0.0, 1.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30.0),
                    onTap: () {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        _setBoundValue(_numValue - widget.stepCount);
                      },
                      onLongPressStart: (_) async {
                        _holdingStepper = true;
                    
                        do {
                          _setBoundValue(_numValue - widget.stepCount);
                    
                          await Future.delayed(const Duration(milliseconds: 20));
                        } while(_holdingStepper);
                      },
                      onLongPressEnd: (_) => setState(() => _holdingStepper = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                        child: const Icon(Icons.remove_rounded, size: 16.0,),
                      )
                    ),
                  ),
                  SizedBox(height: 48.0,),
                  InkWell(
                    borderRadius: BorderRadius.circular(30.0),
                    onTap: () {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        _setBoundValue(_numValue + widget.stepCount);
                      },
                      onLongPressStart: (_) async {
                        _holdingStepper = true;
                    
                        do {
                          _setBoundValue(_numValue + widget.stepCount);
                    
                          await Future.delayed(const Duration(milliseconds: 20));
                        } while(_holdingStepper);
                      },
                      onLongPressEnd: (_) => setState(() => _holdingStepper = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                        child: const Icon(Icons.add_rounded, size: 16.0,),
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}