import 'package:flutter/material.dart';

class NumberButton extends StatefulWidget {
  final int min;
  final int max;
  int? initialValue;
  final Function(int) onChanged;
  final String? label;

  NumberButton({super.key, required this.min, required this.max, this.initialValue, required this.onChanged, this.label}) {
    initialValue ??= min;
  }

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int _numValue;

  @override
  void initState() {
    _numValue = widget.initialValue!;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 8.0),
            child: widget.label == null ? Container() : Text(widget.label!, style: Theme.of(context).textTheme.bodySmall),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(4.0),
                  splashRadius: 16.0,
                  onPressed: () {
                    if(_numValue <= widget.min) {
                      return;
                    }
                    setState(() {
                      _numValue--;
                    });
                    widget.onChanged(_numValue);
                  },
                  icon: const Icon(Icons.remove, size: 18.0,)
                ),
              ),
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(_numValue.toString(), style: Theme.of(context).textTheme.bodyLarge,))
              ),
              SizedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(4.0),
                  splashRadius: 16.0,
                  onPressed: () {
                    if(_numValue >= widget.max) {
                      return;
                    }
                    setState(() {
                      _numValue++;
                    });
                    widget.onChanged(_numValue);
                  },
                  icon: const Icon(Icons.add, size: 18.0,)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}