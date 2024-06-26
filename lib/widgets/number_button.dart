import 'package:flutter/material.dart';

class NumberButton extends StatefulWidget {
  final int min;
  final int max;
  final int value;
  final Function(int) onChanged;
  final String? label;
  final int stepCount;
  final Widget Function(int)? builder;
  final Widget? action;

  const NumberButton({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    this.stepCount = 1,
    this.builder,
    required this.onChanged,
    this.label,
    this.action
  });

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int _numValue;
  bool _holdingStepper = false;

  void _subtractValue() {
    if(_numValue <= widget.min) {
      return;
    }
    setState(() {
      _numValue = widget.value - widget.stepCount;
      if(_numValue <= widget.min) {
        _numValue = widget.min;
      }
    });
  }

  void _incrementValue() {
    if(_numValue >= widget.max) {
      return;
    }
    setState(() {
      _numValue = widget.value + widget.stepCount;
      if(_numValue >= widget.max) {
        _numValue = widget.max;
      }
    });
  }

  @override
  void initState() {
    _numValue = widget.value;

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 23.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                  child: widget.label == null ? Container() : Text(widget.label!, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        _subtractValue();
                        widget.onChanged(_numValue);
                        setState(() {
                          
                        });
                      },
                      onLongPressStart: (_) async {
                        _holdingStepper = true;
                    
                        do {
                          _subtractValue();
                          widget.onChanged(_numValue);
                          setState(() {
                            
                          });
                    
                          await Future.delayed(const Duration(milliseconds: 20));
                        } while(_holdingStepper);
                      },
                      onLongPressEnd: (_) => setState(() => _holdingStepper = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Transform.translate(
                          offset: const Offset(0.0, -3.0),
                          child: const Icon(Icons.remove_rounded, size: 18.0,)
                        ),
                      )
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0.0, -4.0),
                    child: widget.builder != null ? widget.builder!(widget.value) : SizedBox(
                      width: 24,
                      child: Center(
                        child: Text(widget.value.toString(), style: Theme.of(context).textTheme.bodyLarge, maxLines: 1,),)
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        _incrementValue();
                        widget.onChanged(_numValue);
        
                        setState(() {
                          
                        });
                      },
                      onLongPressStart: (_) async {
                        _holdingStepper = true;
                    
                        do {
                          _incrementValue();
                          widget.onChanged(_numValue);
                          setState(() {
                            
                          });
                    
                          await Future.delayed(const Duration(milliseconds: 20));
                        } while(_holdingStepper);
                      },
                      onLongPressEnd: (_) => setState(() => _holdingStepper = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Transform.translate(
                          offset: const Offset(0.0, -3.0),
                          child: const Icon(Icons.add_rounded, size: 18.0,)
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: widget.action ?? Container()
        )
      ],
    );
  }
}