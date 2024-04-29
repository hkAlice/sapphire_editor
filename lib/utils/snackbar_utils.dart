import 'package:flutter/material.dart';

void pushSnackbarText(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}