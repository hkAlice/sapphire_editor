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
  final T? initialValue;
  
  const GenericSearchPickerWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.propertyBuilder,
    this.label,
    required this.itemBuilder,
    this.initialValue,
    this.leading
  });

  @override
  State<GenericSearchPickerWidget> createState() => _GenericSearchPickerWidgetState<T>();
}

class _GenericSearchPickerWidgetState<T> extends State<GenericSearchPickerWidget> {
  late T _setValue;
  int _selectedActorIdx = 0;
  final TextEditingController _dropController = TextEditingController();

  @override
  void initState() {
    if(widget.initialValue != null && widget.items.contains(widget.initialValue)) {
      _setValue = widget.initialValue;
    }
    else {
      _setValue = widget.items.firstOrNull;
    }
    _selectedActorIdx = widget.items.indexOf(_setValue);
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
      initialSelection: widget.items[_selectedActorIdx],
      
      onSelected: (value) {
        if(value == null) {
          return;
        }
    
        setState(() {
          _selectedActorIdx = widget.items.indexOf(value);
          _setValue = value;
        });
        
        widget.onChanged(_setValue);
      },
      leadingIcon: widget.leading ?? const Icon(Icons.search_rounded),
      enableFilter: false,
      enableSearch: true,
      expandedInsets: const EdgeInsets.all(0.0),
      dropdownMenuEntries: widget.items.map<DropdownMenuEntry>((value) {
        return widget.itemBuilder(value as T);
      }).toList(),
    );
  }
}