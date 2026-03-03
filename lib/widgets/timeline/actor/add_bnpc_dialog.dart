import 'package:flutter/material.dart';
import 'package:sapphire_editor/repositories/bnpc_layer_repository.dart';
import 'package:sapphire_editor/services/timeline_editor_signal.dart';

class AddBnpcDialog extends StatefulWidget {
  final TimelineEditorSignal signals;

  const AddBnpcDialog({super.key, required this.signals});

  @override
  State<AddBnpcDialog> createState() => _AddBnpcDialogState();
}

class _AddBnpcDialogState extends State<AddBnpcDialog> {
  final BnpcLayerRepository _bnpcRepo = BnpcLayerRepository();
  List<String>? _zones;
  String? _selectedZone;
  bool _loadingZones = true;
  String? _zoneDataError;

  List<BnpcInstance>? _loadedInstances;
  bool _loadingInstances = false;
  
  final Set<BnpcInstance> _selectedInstances = {};

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final zones = await _bnpcRepo.fetchZones();
      setState(() {
        _zones = zones;
        _loadingZones = false;
      });
    } catch (e) {
      setState(() {
        _zoneDataError = "Failed to load zones ($e)";
        _loadingZones = false;
      });
    }
  }

  Future<void> _fetchZoneInstances(String zone) async {
    setState(() {
      _selectedZone = zone;
      _loadingInstances = true;
      _loadedInstances = null;
      _selectedInstances.clear();
      _zoneDataError = null;
    });

    try {
      final data = await _bnpcRepo.fetchZoneData(zone);
      final instances = _bnpcRepo.parseInstancesFromNameAndMap(data);
      
      setState(() {
        _loadedInstances = instances;
        _loadingInstances = false;
      });
    } catch (e) {
      setState(() {
        _zoneDataError = "Failed to load zone data ($e)";
        _loadingInstances = false;
      });
    }
  }

  void _addSelectedActors() {
    for (var instance in _selectedInstances) {
      widget.signals.addActor(
        bnpcName: "BNPC - ${instance.layoutId}",
        layoutId: instance.layoutId,
        hp: 0xFF14, // default placeholder
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add BNPC from Zone"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loadingZones)
              const Center(child: CircularProgressIndicator())
            else if (_zones != null)
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedZone,
                hint: const Text("Select a Zone"),
                items: _zones!.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _fetchZoneInstances(val);
                  }
                },
              )
            else if (_zoneDataError != null)
              Text(_zoneDataError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            
            const SizedBox(height: 16),
            
            if (_loadingInstances)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_loadedInstances != null)
              Expanded(
                child: _loadedInstances!.isEmpty
                  ? const Text("No BNPC data found for this zone.")
                  : ListView.builder(
                      itemCount: _loadedInstances!.length,
                      itemBuilder: (context, index) {
                        final instance = _loadedInstances![index];
                        final isSelected = _selectedInstances.contains(instance);
                        
                        return CheckboxListTile(
                          title: Text("Layout: ${instance.layoutId} (BaseID: ${instance.baseId})"),
                          subtitle: Text("Group: ${instance.groupName} - NameID: ${instance.nameId}"),
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedInstances.add(instance);
                              } else {
                                _selectedInstances.remove(instance);
                              }
                            });
                          },
                        );
                      },
                    ),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _selectedInstances.isEmpty ? null : _addSelectedActors,
          child: Text("Add Selected (${_selectedInstances.length})"),
        )
      ],
    );
  }
}
