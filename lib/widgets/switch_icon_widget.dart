import 'package:flutter/material.dart';

class SwitchIconWidget extends StatefulWidget {
  final bool enabled;
  final Function() onPressed;
  final IconData icon;
  SwitchIconWidget({super.key, required this.enabled, required this.onPressed, required this.icon});

  @override
  State<SwitchIconWidget> createState() => _SwitchIconWidgetState();
}

class _SwitchIconWidgetState extends State<SwitchIconWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () { widget.onPressed(); } ,
      icon: widget.enabled ? Icon(widget.icon, 
              color: const Color(0xFFE1EBD3),
              shadows: const <Shadow>[
                Shadow(
                  offset: Offset(0.0, 00.0),
                  blurRadius: 3.0,
                  color: Colors.orange,
                ),
              ]
            ) : Icon(
                  widget.icon, 
                  color: Colors.grey,
                  shadows: const <Shadow>[
                    Shadow(
                      offset: Offset(0.0, 00.0),
                      blurRadius: 2.0,
                      color: Colors.black26,
                    ),
                  ]
                )
        );
  }
}