import 'dart:convert';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sapphire_editor/models/storage/editor_settings_model.dart';
import 'package:sapphire_editor/services/settings_helper.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/services/theme_service.dart';
import 'package:sapphire_editor/utils/text_utils.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
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
    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  Future<EditorSettingsModel> _fetchSettings() async {
    return SettingsHelper().getUISettings();
  }

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Column(
        children: [
          const PageHeaderWidget(title: "Settings"),
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
                      if(snapshot.hasError) {
                        return const Icon(Icons.baby_changing_station);
                      }
                      if(snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(snapshot.data[0]["sha"]),
                            Text(snapshot.data[0]["commit"]["message"]),
                          ],
                        );
                      }
                  
                      return const LoadingSpinner();
                    },
                  ),
                  const Divider(),
                  const SmallHeadingWidget(title: "Settings"),
                  FutureBuilder<EditorSettingsModel>(
                    future: _fetchSettings(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        var theme = FlexScheme.values.firstWhere((e) => e.name == snapshot.data!.theme, orElse: () => FlexScheme.indigoM3);
                        var brightness = Brightness.values.firstWhere((e) => e.name == snapshot.data!.brightness, orElse: () => Brightness.dark);
                        
                        return Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: GenericItemPickerWidget<FlexScheme>(
                                label: "Theme",
                                initialValue: theme,
                                items: FlexScheme.values,
                                propertyBuilder: (value) => treatEnumName(value),
                                onChanged: (value) {
                                  var scheme = value as FlexScheme;
                                  snapshot.data!.theme = scheme.name;

                                  if(snapshot.data!.brightness == "dark") {
                                    ThemeService().updateThemeData(FlexThemeData.dark(scheme: value));
                                  }
                                  else {
                                    ThemeService().updateThemeData(FlexThemeData.light(scheme: value));
                                  }

                                  SettingsHelper().saveUISettings(snapshot.data!);
                                }
                              ),
                            ),
                            const SizedBox(width: 18.0,),
                            SizedBox(
                              width: 180,
                              child: GenericItemPickerWidget<Brightness>(
                                label: "Brightness",
                                initialValue: brightness,
                                items: Brightness.values,
                                propertyBuilder: (value) => treatEnumName(value),
                                onChanged: (value) {
                                  var theme = FlexScheme.values.firstWhere((e) => e.name == snapshot.data!.theme, orElse: () => FlexScheme.indigoM3);
                                  var brightness = value as Brightness;
                                  snapshot.data!.brightness = brightness.name;

                                  if(snapshot.data!.brightness == "dark") {
                                    ThemeService().updateThemeData(FlexThemeData.dark(scheme: theme));
                                  }
                                  else {
                                    ThemeService().updateThemeData(FlexThemeData.light(scheme: theme));
                                  }
                                  
                                  SettingsHelper().saveUISettings(snapshot.data!);
                                }
                              ),
                            ),
                          ],
                        );
                      }
                      return const LoadingSpinner();
                    }
                  )
                ],
              )
            ),
          ),
          
        ],
      ),
    );
  }
}