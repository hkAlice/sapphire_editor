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
  const _SanityCallDoneWidget();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.done_rounded),
        SizedBox(width: 8.0,),
        Text("No warnings, for now."),
      ]
    );
  }
}


class _SanityCallErrorWidget extends StatelessWidget {
  final int errCount;
  final int warnCount;

  const _SanityCallErrorWidget({required this.errCount, required this.warnCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_rounded),
        const SizedBox(width: 8.0,),
        Text("$errCount errors, $warnCount warnings"),
      ]
    );
  }
}

class _SanityCallDialog extends StatelessWidget {
  final List<SanityItem> items;
  
  const _SanityCallDialog({required this.items});

  List<Widget> _buildWidgetList() {
    List<Widget> widgets = [];

    for(var sanityItem in items) {
      bool isError = sanityItem.severity == SanitySeverity.error;
      
      widgets.add(Card(
        child: ListTile(
          leading: isError ? Icon(Icons.error_rounded, size: 36.0, color: Colors.red.shade900) : Icon(Icons.warning_rounded, size: 36.0, color: Colors.orange.shade500,),
          subtitle: Text(sanityItem.type),
          title: Text(sanityItem.desc),
        ),
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
      content: SingleChildScrollView(
        child: Container(
          color: Colors.black12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildWidgetList()
          ),
        ),
      )
    );
  }
}