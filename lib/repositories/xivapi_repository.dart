import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sapphire_editor/models/repository/item_minimal.dart';

class XivApiRepository {
  static final XivApiRepository _instance = XivApiRepository._internal();

  factory XivApiRepository() {
    return _instance;
  }

  XivApiRepository._internal();

  static String XIVAPI_URL = "https://v2.xivapi.com/api/";

  String getItemIconURL(int itemId, {bool hd = true}) {
    int num = int.tryParse(itemId.toString()) ?? 0;
    bool extended = num.toString().length >= 6;

    // get asset filename
    String icon = extended
      ? num.toString().padLeft(5, "0")
      : "0" + num.toString().padLeft(5, "0");

    // get path id
    String folderId = extended
      ? "${icon[0]}${icon[1]}${icon[2]}000"
      : "0${icon[1]}${icon[2]}000";

    String fileName = hd ? "${icon}_hr1" : icon;

    return "$XIVAPI_URL/asset?path=ui/icon/$folderId/$fileName.tex&format=png";
  }
}
