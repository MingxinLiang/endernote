import 'dart:io';
import 'package:endernote/common/logger.dart' show logger;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';

class PreviewMode extends StatelessWidget {
  final String entityPath;
  final TocController tocController;
  const PreviewMode(
      {super.key, required this.entityPath, required this.tocController});

  Future<String> _loadFileContent() async {
    try {
      return await File(entityPath).readAsString();
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          (kToolbarHeight - MediaQuery.of(context).padding.top),
      child: FutureBuilder(
        future: _loadFileContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 等待加载
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            logger.e("Error loading file: ${snapshot.error}");
            return Center(
              child: Text("Error loading file: ${snapshot.error}"),
            );
          } else {
            return Expanded(
                child: MarkdownWidget(
              data: snapshot.data!,
              tocController: tocController,
            ));
          }
        },
      ),
    );
  }
}
