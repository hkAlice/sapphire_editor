import 'package:flutter/material.dart';

class AddGenericWidget extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const AddGenericWidget({super.key, this.text = "Add", required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF333333), width: 1.0),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap as void Function()?,
          hoverColor: const Color(0xFF3A3A3A),
          splashColor: const Color(0xFF4A4A4A),
          child: Container(
            height: 32.0,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              "+ $text",
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SmallAddGenericWidget extends StatelessWidget {
  final Function()? onTap;
  final String? text;

  const SmallAddGenericWidget({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF333333), width: 1.0),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap as void Function()?,
          hoverColor: const Color(0xFF3A3A3A),
          splashColor: const Color(0xFF4A4A4A),
          child: Container(
            height: 28.0,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              "+ ${text ?? 'Add new'}",
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}