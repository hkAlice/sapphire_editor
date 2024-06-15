import 'package:flutter/material.dart';

typedef PropertyBuilderCallback<T> = String Function(T value);

class GenericItemPickerWidget<T> extends StatefulWidget {
  
  final List<T> items;
  final PropertyBuilderCallback? propertyBuilder;
  final String? label;
  final Function(dynamic) onChanged;
  final T? initialValue;
  
  const GenericItemPickerWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.propertyBuilder,
    this.initialValue,
    this.label
  });

  @override
  State<GenericItemPickerWidget> createState() => _GenericItemPickerWidgetState<T>();
}

class _GenericItemPickerWidgetState<T> extends State<GenericItemPickerWidget> {
  late T _setValue;

  @override
  void initState() {
    if(widget.initialValue != null && widget.items.contains(widget.initialValue)) {
      _setValue = widget.initialValue;
    }
    else {
      _setValue = widget.items.first;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: _setValue,
      elevation: 16,
      isDense: true,
      decoration: InputDecoration(
        filled: true,
        labelText: widget.label,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(10.5)
      ),
      onChanged: (T? value) {
        if(value == null) {
          return;
        }
        
        widget.onChanged(value);

        setState(() {
          _setValue = value;
        });
      },
      items: widget.items.map<DropdownMenuItem<T>>((dynamic value) {
        // todo: seven hells. by hydaelyn. heavens forfend. thal's balls
        String itemName = "";
        if(widget.propertyBuilder != null) {
          itemName = widget.propertyBuilder!(value);
        }
        else {
          var data;
          if(value is String) {
            var data = value;
            itemName = data;
          }
          else {
            var data = value.toJson();
            assert(data.containsKey("name"));
            itemName = data["name"];
          }
        }

        return DropdownMenuItem<T>(
          value: value,
          child: Text(itemName),
        );
      }).toList(),
    );
  }
}