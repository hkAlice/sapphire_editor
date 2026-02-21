import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/repositories/local_repository.dart';
import 'package:sapphire_editor/services/settings_helper.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/services/theme_service.dart';
import 'package:sapphire_editor/views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageHelper().init();
  try {
    await LocalRepository().load();
  }
  catch(e) {
    // it is what it is
  }

  var uiSettings = await SettingsHelper().getUISettings();

  var themeService = ThemeService();
  var theme = FlexScheme.values.firstWhere((e) => e.name == uiSettings.theme, orElse: () => FlexScheme.damask);

  themeService.updateThemeData(FlexThemeData.dark(scheme: theme));
  
  runApp(SapphireEditorApp(themeService: themeService,));
}

class SapphireEditorApp extends StatefulWidget {
  final ThemeService themeService;

  const SapphireEditorApp({super.key, required this.themeService});

  @override
  State<SapphireEditorApp> createState() => _SapphireEditorAppState();
}

class _SapphireEditorAppState extends State<SapphireEditorApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.themeService.themeScheme,
      builder: (context, value, child) {
        return MaterialApp(
          title: "Sapphire Editor",
          theme: value,
          darkTheme: value,
          themeMode: ThemeMode.dark,
          home: const MainView(),
        );
      }
    );
  }
}