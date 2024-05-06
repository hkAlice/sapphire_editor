import 'package:flutter/material.dart';
import 'package:sapphire_editor/utils/timeline_sanity.dart';

class SanityCallWidget extends StatefulWidget {
  final List<SanityItem> items;
  const SanityCallWidget({super.key, required this.items});

  @override
  State<SanityCallWidget> createState() => _SanityCallWidgetState();
}

class _SanityCallWidgetState extends State<SanityCallWidget> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.items.isEmpty ? null : () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _SanityCallDialog(items: widget.items,);
      });
      },
      child: widget.items.isNotEmpty ? _SanityCallErrorWidget(
        errCount: widget.items.where((e) => e.severity == SanitySeverity.error).length,
        warnCount: widget.items.where((e) => e.severity == SanitySeverity.warning).length
      ) : const _SanityCallDoneWidget()
    );
  }
}

class _SanityCallDoneWidget extends StatelessWidget {
  const _SanityCallDoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.done),
        SizedBox(width: 8.0,),
        Text("No warnings, for now."),
      ]
    );
  }
}


class _SanityCallErrorWidget extends StatelessWidget {
  final int errCount;
  final int warnCount;

  const _SanityCallErrorWidget({super.key, required this.errCount, required this.warnCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning_rounded),
        SizedBox(width: 8.0,),
        Text("$errCount errors, $warnCount warnings"),
      ]
    );
  }
}

class _SanityCallDialog extends StatelessWidget {
  final List<SanityItem> items;
  
  const _SanityCallDialog({super.key, required this.items});

  List<Widget> _buildWidgetList() {
    List<Widget> widgets = [];

    for(var sanityItem in items) {
      bool isError = sanityItem.severity == SanitySeverity.error;
      
      widgets.add(ListTile(
        tileColor: isError ? Colors.red.shade900 : Colors.orange.shade900,
        trailing: isError ? Icon(Icons.error) : Icon(Icons.warning),
        title: Text(sanityItem.type),
        subtitle: Text(sanityItem.desc),
      ));
    }
    
    return widgets;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 18.0, bottom: 0.0),
      title: const Text("Sanity check"),
      insetPadding: const EdgeInsets.all(50.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildWidgetList()
      )
    );
  }
}