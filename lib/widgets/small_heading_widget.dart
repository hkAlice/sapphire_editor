import 'package:flutter/material.dart';

class SmallHeadingWidget extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SmallHeadingWidget({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall!,),
              trailing ?? Container()
            ],
          ),
        ],
      ),
    );
  }
}