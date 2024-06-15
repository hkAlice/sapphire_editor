import 'package:flutter/material.dart';

class TextModalEditorWidget extends StatefulWidget {
  final String text;
  final Function(String) onChanged;

  const TextModalEditorWidget({super.key, required this.text, required this.onChanged});

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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: widget.text.isEmpty ? 0.65 : 1.0,
          child: SizedBox(
            width: 320,
            child: Text(
              widget.text,
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            splashRadius: 24.0,
            padding: const EdgeInsets.all(2.0),
            icon: const Icon(Icons.comment_rounded),
            onPressed: () {
              _descriptionTextEditingController.value = TextEditingValue(text: widget.text);

              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Edit description"),
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
                        maxLines: null,
                        minLines: 5,
                        autofocus: true,
                        controller: _descriptionTextEditingController,
                        decoration: const InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                          hintText: "Describe your timepoint (or don't)"
                        ),
                        onChanged: (value) {
                          widget.onChanged(value);
                        },
                      ),
                    )
                  );
                }
              );
            }, 
          ),
        )
      ],
    );
  }
}