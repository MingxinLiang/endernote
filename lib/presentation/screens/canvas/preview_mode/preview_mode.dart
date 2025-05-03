import 'package:endernote/presentation/screens/canvas/preview_mode/markdown_preview.dart';
import 'package:flutter/material.dart';

class PreviewMode extends StatelessWidget {
  final String data;
  const PreviewMode({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height -
            (kToolbarHeight - MediaQuery.of(context).padding.top),
        child: Expanded(
            child: MarkdownWidget(
          data: data,
        )));
  }
}
