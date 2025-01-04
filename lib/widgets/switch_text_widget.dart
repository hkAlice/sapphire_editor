import 'package:flutter/material.dart';

class SwitchTextWidget extends StatefulWidget {
  final bool enabled;
  final Function() onPressed;
  final Widget? leading;
  final (String onStr, String offStr) toggleText;

  const SwitchTextWidget({super.key, required this.enabled, required this.onPressed, this.leading, this.toggleText = ("ON", "OFF")});

  @override
  State<SwitchTextWidget> createState() => _SwitchTextWidgetState();
}

class _SwitchTextWidgetState extends State<SwitchTextWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () { widget.onPressed(); } ,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container( 
            margin: widget.leading == null ? null : const EdgeInsets.only(right: 8.0),
            child: widget.leading,
          ),
          Center(
            child: widget.enabled ? Text(
                widget.toggleText.$1, style: Theme.of(context).textTheme.bodyMedium!.apply(
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
                widget.toggleText.$2, style: Theme.of(context).textTheme.bodyMedium!.apply(
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
          )
          
        ],
      )
    );
  }
}