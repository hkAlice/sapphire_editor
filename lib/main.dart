import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sapphire_editor/services/storage_helper.dart';
import 'package:sapphire_editor/views/main_view.dart';

void main() async {
  await StorageHelper().init();

  runApp(const TimelineEditorApp());
}

class TimelineEditorApp extends StatelessWidget {
  const TimelineEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sapphire Editor",
      theme: FlexThemeData.light(scheme: FlexScheme.indigoM3).copyWith(),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.indigoM3),
      themeMode: ThemeMode.dark, // todo: toggle instead of system
      home: const MainView(),
    );
  }
}