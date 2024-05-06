import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sapphire_editor/widgets/loading_spinner.dart';
import 'package:sapphire_editor/widgets/page_header_widget.dart';
import 'package:sapphire_editor/widgets/small_heading_widget.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Future<dynamic> _fetchGithubInfo() async {
    // todo: fetch this on app init
    final response = await http.get(Uri.parse('https://api.github.com/repos/hkAlice/sapphire_editor/commits?per_page=1'));
    if(response.statusCode == 200)
      return jsonDecode(response.body);
    else
      throw Exception(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          PageHeaderWidget(title: "Settings"),
          const Divider(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
              constraints: const BoxConstraints(maxWidth: 1400.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SmallHeadingWidget(title: "Commit version"),
                  FutureBuilder<dynamic>(
                    future: _fetchGithubInfo(),
                    builder: (context, snapshot) {
                      if(snapshot.hasError)
                        return Icon(Icons.baby_changing_station);
                      if(snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(snapshot.data[0]["sha"]),
                            Text(snapshot.data[0]["commit"]["message"]),
                          ],
                        );
                      }
                  
                      return LoadingSpinner();
                    }
                  ),
                ],
              )
            ),
          ),
          
        ],
      ),
    );
  }
}