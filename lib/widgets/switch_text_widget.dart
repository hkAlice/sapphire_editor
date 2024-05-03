import 'package:flutter/material.dart';

class SwitchTextWidget extends StatefulWidget {
  final bool enabled;
  final Function() onPressed;
  Widget? leading;
  SwitchTextWidget({super.key, required this.enabled, required this.onPressed, this.leading});

  @override
  State<SwitchTextWidget> createState() => _SwitchTextWidgetState();
}

class _SwitchTextWidgetState extends State<SwitchTextWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () { widget.onPressed(); } ,
      child: Row(
        children: [
          Container( 
            margin: widget.leading == null ? null : const EdgeInsets.only(right: 8.0),
            child: widget.leading,
          ),
          Container(
            width: 28,
            child: Center(
              child: widget.enabled ? Text(
                  "On".toUpperCase(), style: Theme.of(context).textTheme.bodyMedium!.apply(
                    fontWeightDelta: 1,
                    color: const Color(0xFFE1EBD3),
                    shadows: <Shadow>[
                      const Shadow(
                        offset: Offset(0.0, 00.0),
                        blurRadius: 3.0,
                        color: Colors.orange,
                      ),
                    ]
                  )
                )
                : Text(
                  "Off".toUpperCase(), style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Colors.grey,
                    fontWeightDelta: 1,
                    shadows: <Shadow>[
                      const Shadow(
                        offset: Offset(0.0, 00.0),
                        blurRadius: 2.0,
                        color: Colors.black26,
                      ),
                    ]
                  )
                ),
            ),
          )
          
        ],
      )
    );
  }
}