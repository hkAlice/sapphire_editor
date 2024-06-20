import 'package:flutter/material.dart';

class TextModalEditorWidget extends StatefulWidget {
  final String headerText;
  final String text;
  final int minLines;
  final int? maxLines;
  final Widget? icon;
  final Function(String) onChanged;

  const TextModalEditorWidget({super.key, this.icon, this.headerText = "Edit", required this.text, required this.onChanged, this.minLines = 5, this.maxLines});

  @override
  State<TextModalEditorWidget> createState() => _TextModalEditorWidgetState();
}

class _TextModalEditorWidgetState extends State<TextModalEditorWidget> {
  late TextEditingController _descriptionTextEditingController;
  @override
  void initState() {
    _descriptionTextEditingController = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  void dispose() {
    _descriptionTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        splashRadius: 24.0,
        padding: const EdgeInsets.all(2.0),
        icon: widget.icon ?? const Icon(Icons.comment_rounded),
        onPressed: () {
          _descriptionTextEditingController.text = widget.text;
    
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.headerText),
                    SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: IconButton.outlined(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(Icons.close),
                        splashRadius: 28.0,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
                //contentPadding: const EdgeInsets.all(12.0),
                content: Container(
                  constraints: const BoxConstraints(minWidth: 600),
                  child: TextField(
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    autofocus: true,
                    controller: _descriptionTextEditingController,
                    decoration: InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                      hintText: widget.headerText
                    ),
                    onChanged: (value) {
                      //_descriptionTextEditingController.text = value;
                      widget.onChanged(value);
                    },
                  ),
                )
              );
            }
          );
        }, 
      ),
    );
  }
}