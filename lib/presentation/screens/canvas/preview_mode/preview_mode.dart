import 'package:xnote/presentation/screens/canvas/preview_mode/markdown_preview.dart';
import 'package:flutter/material.dart';

class PreviewMode extends StatelessWidget {
  const PreviewMode({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height -
            (kToolbarHeight - MediaQuery.of(context).padding.top),
        child: MarkdownWidget());
  }
}
