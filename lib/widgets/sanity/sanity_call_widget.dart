import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sapphire_editor/utils/timeline_sanity.dart';
import 'package:sapphire_editor/widgets/signals_provider.dart';

class SanityCallWidget extends StatefulWidget {
  const SanityCallWidget({super.key});

  @override
  State<SanityCallWidget> createState() => _SanityCallWidgetState();
}

class _SanityCallWidgetState extends State<SanityCallWidget> {
  Timer _sanityTimer = Timer(const Duration(seconds: 2), () {});
  int timelineHash = 0;
  List<SanityItem> items = [];

  @override
  void initState() {
    super.initState();

    _sanityTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if(mounted) {
        final signals = SignalsProvider.of(context);
        final timelineModel = signals.timeline.value;
        
        items = TimelineSanitySvc.run(timelineModel);
        setState(() {
          timelineHash = timelineModel.hashCode;
        });
      }
    });
  }

  @override
  void dispose() {
    _sanityTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: items.isEmpty ? null : () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _SanityCallDialog(items: items,);
      });
      },
      child: items.isNotEmpty ? _SanityCallErrorWidget(
        errCount: items.where((e) => e.severity == SanitySeverity.error).length,
        warnCount: items.where((e) => e.severity == SanitySeverity.warning).length
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
    bool isError = errCount > 0;
    bool isWarn = warnCount > 0;

    Color callColour = isError ? Colors.red.shade900 : (isWarn ? Colors.orange.shade500 : Colors.purple.shade700);
    IconData callIcon = isError ? Icons.error_rounded : (isWarn ? Icons.warning_rounded : Icons.info_rounded);
    return Row(
      children: [
        Icon(callIcon, color: callColour,),
        const SizedBox(width: 8.0,),
        Text("$errCount error${errCount == 1 ? '' : 's'}, $warnCount warning${warnCount == 1 ? '' : 's'}", style: Theme.of(context).textTheme.labelLarge!.apply(color: callColour),),
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
      bool isWarn = sanityItem.severity == SanitySeverity.warning;
      Color callColour = isError ? Colors.red.shade900 : (isWarn ? Colors.orange.shade500 : Colors.purple.shade700);
      IconData callIcon = isError ? Icons.error_rounded : (isWarn ? Icons.warning_rounded : Icons.info_rounded);

      widgets.add(Card(
        child: ListTile(
          leading: Icon(callIcon, size: 36.0, color: callColour),
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
          constraints: const BoxConstraints(minWidth: 600),
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
