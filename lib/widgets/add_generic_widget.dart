import 'package:flutter/material.dart';

class AddGenericWidget extends StatelessWidget {
  final Function() onTap;
  final String text;

  const AddGenericWidget({super.key, this.text = "Add", required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded),
          const SizedBox(height: 36.0,),
          Text(text)
        ],
      ),
    );
  }
}