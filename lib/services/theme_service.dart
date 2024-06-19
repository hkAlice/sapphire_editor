import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static final ThemeService _singleton = ThemeService._internal();

  factory ThemeService() {
    return _singleton;
  }

  ThemeService._internal();

  ThemeService._init() {
    themeScheme.value = FlexThemeData.dark(scheme: FlexScheme.indigoM3);
  }

  ValueNotifier<ThemeData> themeScheme = ValueNotifier<ThemeData>(ThemeData.dark());

  void updateThemeData(ThemeData themes) {
    themeScheme.value = themes;
  }
}