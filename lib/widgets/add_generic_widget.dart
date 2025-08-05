import 'package:flutter/material.dart';

class AddGenericWidget extends StatelessWidget {
  final Function()? onTap;
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
          const SizedBox(height: 36.0, width: 4.0,),
          Text(text)
        ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Colors.grey.shade800.withAlpha(150), width: 1.0),
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Center(
                        child: Opacity(
                          opacity: 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 14,),
                              SizedBox(width: 4.0, height: 24.0,),
                              Text(text ?? "Add new", style: Theme.of(context).textTheme.bodySmall,),
                            ],
                          ),
                        )
                      )
                    ),
                    const SizedBox(width: 4.0,),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}