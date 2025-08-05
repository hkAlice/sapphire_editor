import 'package:flutter/material.dart';

typedef PropertyBuilderCallback<T> = String Function(T value);
typedef DropdownEntryBuilder<T> = DropdownMenuEntry<T> Function(T value);

class GenericSearchPickerWidget<T> extends StatefulWidget {
  final List<T> items;
  final PropertyBuilderCallback<T>? propertyBuilder;
  final String? label;
  final Function(T) onChanged;
  final DropdownEntryBuilder<T> itemBuilder;
  final Widget? leading;
  final T? value;
  final int searchThreshold;

  const GenericSearchPickerWidget({
    super.key,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.propertyBuilder,
    this.label,
    this.value,
    this.leading,
    this.searchThreshold = 100,
  });

  @override
  State<GenericSearchPickerWidget<T>> createState() =>
      _GenericSearchPickerWidgetState<T>();
}

class _GenericSearchPickerWidgetState<T> extends State<GenericSearchPickerWidget<T>> {
  T? get _selectedValue => widget.value ?? (widget.items.isNotEmpty ? widget.items.first : null);

  final TextEditingController _dropController = TextEditingController();

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // big list, delegate search
    if(widget.items.length > widget.searchThreshold) {
      return InkWell(
        onTap: () async {
          final result = await showSearch<T?>(
            context: context,
            delegate: _GenericSearchDelegate<T>(
              items: widget.items,
              propertyBuilder: widget.propertyBuilder,
            ),
          );

          if(result != null) {
            widget.onChanged(result);
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Row(
            children: [
              widget.leading ?? Container(),
              Text(widget.propertyBuilder?.call(_selectedValue!) ?? _selectedValue.toString()),
            ],
          ),
        ),
      ); /*
      return OutlinedButton.icon(
        onPressed: () async {
          final result = await showSearch<T?>(
            context: context,
            delegate: _GenericSearchDelegate<T>(
              items: widget.items,
              propertyBuilder: widget.propertyBuilder,
            ),
          );

          if(result != null) {
            widget.onChanged(result);
          }
        },
        icon: widget.leading ?? const Icon(Icons.search),
        label: Text(widget.propertyBuilder?.call(_selectedValue!) ??
            _selectedValue.toString()),
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0),))
      );*/
    }

    // smoll list, use regular dropdownmenu
    return DropdownMenu<T>(
      controller: _dropController,
      initialSelection: _selectedValue,
      onSelected: (value) {
        if(value != null) {
          widget.onChanged(value);
        }
      },
      leadingIcon: widget.leading ?? const Icon(Icons.search),
      enableSearch: true,
      dropdownMenuEntries: widget.items.map<DropdownMenuEntry<T>>(widget.itemBuilder).toList(),
    );
  }
}

class _GenericSearchDelegate<T> extends SearchDelegate<T?> {
  final List<T> items;
  final PropertyBuilderCallback<T>? propertyBuilder;

  _GenericSearchDelegate({
    required this.items,
    this.propertyBuilder,
  });

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = "",
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final lowerQuery = query.toLowerCase();

    final filtered = items.where((item) {
      final text = propertyBuilder?.call(item) ?? item.toString();
      return text.toLowerCase().contains(lowerQuery);
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, index) {
        final item = filtered[index];
        return ListTile(
          title: Text(propertyBuilder?.call(item) ?? item.toString()),
          onTap: () => close(context, item),
        );
      },
    );
  }
}

class _BigListSearch<T> extends StatefulWidget {
  final List<T> items;
  final PropertyBuilderCallback<T>? propertyBuilder;
  final void Function(T) onSelected;

  const _BigListSearch({
    required this.items,
    required this.onSelected,
    this.propertyBuilder,
  });

  @override
  State<_BigListSearch<T>> createState() => _BigListSearchState<T>();
}

class _BigListSearchState<T> extends State<_BigListSearch<T>> {
  late List<T> _filtered;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.items.where((item) {
        final text = widget.propertyBuilder?.call(item) ?? item.toString();
        return text.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Search...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final item = _filtered[index];
              final label =
                  widget.propertyBuilder?.call(item) ?? item.toString();
              return ListTile(
                title: Text(label),
                onTap: () => widget.onSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
