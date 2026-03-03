import 'dart:convert';
import 'package:http/http.dart' as http;

class BnpcLayerRepository {
  static const String _githubApiUrl = "https://api.github.com/repos/SapphireServer/Sapphire/contents/data/bnpcs";
  static const String _rawBaseUrl = "https://raw.githubusercontent.com/SapphireServer/Sapphire/refs/heads/master/data/bnpcs";

  List<String>? _cachedZones;

  Future<List<String>> fetchZones() async {
    if (_cachedZones != null) {
      return _cachedZones!;
    }

    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedZones = data
            .where((element) => element['type'] == 'dir')
            .map((element) => element['name'] as String)
            .toList();
        return _cachedZones!;
      } else {
        throw Exception("Failed to load zones: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching zones from GitHub: $e");
    }
  }

  Future<Map<String, dynamic>> fetchZoneData(String zone) async {
    final url = "$_rawBaseUrl/$zone/$zone.json";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to load zone data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching zone data from GitHub: $e");
    }
  }

  /// Extracts instances out of the raw parsed JSON zone map
  List<BnpcInstance> parseInstancesFromNameAndMap(Map<String, dynamic> zoneMap) {
    List<BnpcInstance> instances = [];

    // The root structure has groups like 'LVD_bnpc_01'
    for (var group in zoneMap.values) {
      if (group is Map<String, dynamic> && group.containsKey('bnpcs')) {
        final bnpcs = group['bnpcs'] as Map<String, dynamic>;
        for (var entry in bnpcs.entries) {
          final instanceIdStr = entry.key;
          final value = entry.value as Map<String, dynamic>;
          final baseInfo = value['baseInfo'] as Map<String, dynamic>?;
          
          if (baseInfo != null) {
            final layoutId = baseInfo['instanceId'] as int? ?? int.tryParse(instanceIdStr);
            final nameId = baseInfo['nameId'] as int?;
            final baseId = baseInfo['baseId'] as int?;

            if (layoutId != null) {
              instances.add(BnpcInstance(
                layoutId: layoutId,
                nameId: nameId,
                baseId: baseId,
                groupName: group['groupName'] as String? ?? "Unknown Group",
              ));
            }
          }
        }
      }
    }

    return instances;
  }
}

class BnpcInstance {
  final int layoutId;
  final int? nameId;
  final int? baseId;
  final String groupName;

  BnpcInstance({
    required this.layoutId,
    this.nameId,
    this.baseId,
    required this.groupName,
  });
}
