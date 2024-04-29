import 'package:flutter/material.dart';

class PageHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? heading;

  const PageHeaderWidget({super.key, required this.title, this.subtitle, this.heading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          heading == null ? Container() : Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.only(top: 8.0),
            margin: const EdgeInsets.only(right: 18.0),
            child: heading ?? Container()
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall!.apply(color: Colors.white),),
              subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall,) : Container()
            ],
          ),
        ],
      ),
    );
  }
}