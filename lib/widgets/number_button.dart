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
  late FocusNode _focusNode;

  void _setBoundValue(int value, {bool notify = true, bool forceUpdateText = false}) {
    _numValue = value;
    if(_numValue <= widget.min) {
      _numValue = widget.min;
    }
    if(_numValue >= widget.max) {
      _numValue = widget.max;
    }
    
    if(forceUpdateText || !_focusNode.hasFocus) {
      _controller.text = _numValue.toString();
    }

    if(notify) {
      widget.onChanged(_numValue);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _numValue = widget.value;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if(!_focusNode.hasFocus) {
        _setBoundValue(_numValue);
      } else {
        _controller.text = _numValue.toString();
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });

    _controller = TextEditingController(text: _numValue.toString());
  }

  @override
  void didUpdateWidget(covariant NumberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.value != oldWidget.value && widget.value != _numValue) {
      _numValue = widget.value;
      _controller.text = _numValue.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
            focusNode: _focusNode,
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
              label: widget.label == null && widget.builder == null 
                  ? null 
                  : Text("${widget.label ?? ''} ${widget.builder != null ? "(${widget.builder!(_numValue)})" : ""}".trim()),
            ),
            onChanged: (value) {
              int? newValue = int.tryParse(value);
              if(newValue == null) return;
              
              setState(() {
                _numValue = newValue;
              });
            },
            onSubmitted: (value) {
              _focusNode.unfocus();
              widget.onChanged(_numValue);
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
                        _focusNode.unfocus();
                        _setBoundValue(_numValue - widget.stepCount, forceUpdateText: true);
                      },
                      onLongPressStart: (_) async {
                        _focusNode.unfocus();
                        _holdingStepper = true;
                    
                        do {
                          _setBoundValue(_numValue - widget.stepCount, notify: false, forceUpdateText: true);
                    
                          await Future.delayed(const Duration(milliseconds: 50));
                        } while(_holdingStepper);
                        widget.onChanged(_numValue);
                      },
                      onLongPressEnd: (_) => _holdingStepper = false,
                      onLongPressCancel: () {
                        if(_holdingStepper) {
                          _holdingStepper = false;
                          widget.onChanged(_numValue);
                        }
                      },
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
                        _focusNode.unfocus();
                        _setBoundValue(_numValue + widget.stepCount, forceUpdateText: true);
                      },
                      onLongPressStart: (_) async {
                        _focusNode.unfocus();
                        _holdingStepper = true;
                    
                        do {
                          _setBoundValue(_numValue + widget.stepCount, notify: false, forceUpdateText: true);
                    
                          await Future.delayed(const Duration(milliseconds: 50));
                        } while(_holdingStepper);
                        widget.onChanged(_numValue);
                      },
                      onLongPressEnd: (_) => _holdingStepper = false,
                      onLongPressCancel: () {
                        if(_holdingStepper) {
                          _holdingStepper = false;
                          widget.onChanged(_numValue);
                        }
                      },
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