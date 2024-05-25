import 'package:flutter/material.dart';

typedef PropertyBuilderCallback<T> = String Function(T value);
typedef DropdownEntryBuilder<T> = DropdownMenuEntry Function(T value);

class GenericSearchPickerWidget<T> extends StatefulWidget {
  final List<T> items;
  final PropertyBuilderCallback? propertyBuilder;
  final String? label;
  final Function(dynamic) onChanged;
  final DropdownEntryBuilder itemBuilder;
  final Widget? leading;
  
  const GenericSearchPickerWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.propertyBuilder,
    this.label,
    required this.itemBuilder,
    this.leading
  });

  @override
  State<GenericSearchPickerWidget> createState() => _GenericSearchPickerWidgetState<T>();
}

class _GenericSearchPickerWidgetState<T> extends State<GenericSearchPickerWidget> {
  late T _setValue;
  final TextEditingController _dropController = TextEditingController();

  @override
  void initState() {
    _setValue = widget.items.first;
    super.initState();
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _dropController,
      initialSelection: widget.items.firstOrNull,
      
      onSelected: (value) {
        if(value == null) {
          return;
        }
    
        setState(() {
          _setValue = value;
        });
        
        widget.onChanged(_setValue);
      },
      leadingIcon: widget.leading ?? const Icon(Icons.search),
      enableFilter: true,
      enableSearch: true,
      expandedInsets: const EdgeInsets.all(0.0),
      dropdownMenuEntries: widget.items.map<DropdownMenuEntry>((value) {
        return widget.itemBuilder(value as T);
      }).toList(),
    );
  }
}