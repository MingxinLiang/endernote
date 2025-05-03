import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/config/configs.dart' show MarkdownConfig;
import 'package:markdown_widget/widget/widget_visitor.dart' show WidgetVisitor;

// 用于文本索引
RegExp headRegExp = RegExp(r'^h[1-6]$');

class ToI {
  ///the HeadingNode
  final int headLevel;
  final String text;
  int offSet;
  int lindIndex;
  int widgetIndex;

  ToI(
      {required this.headLevel,
      required this.text,
      this.lindIndex = 0,
      this.widgetIndex = 0,
      this.offSet = 0});
}

List<ToI> getMarkDownToc(List<md.Node> nodes) {
  final listToc = <ToI>[];
  int lastLevel = 1;

  // TODO: 预览模式显示内容
  for (var node in nodes) {
    if (node is md.Element) {
      String tag = node.tag;
      int headLevel = lastLevel;
      if (headRegExp.hasMatch(tag)) {
        headLevel = int.parse(tag.substring(1));
        lastLevel = headLevel;

        String content = node.textContent;
        listToc.add(ToI(
          headLevel: headLevel,
          text: content,
          widgetIndex: listToc.length,
        ));
      }
    }
  }

  return listToc; // 添加返回语句
}

ToI? getToIline(String text) {
  var lineSp = text.split(" ");
  var tag = lineSp[0];
  String content = "";

  if (lineSp.length > 1) {
    content = text.substring(tag.length + 1);
  }

  if (tag == "#") {
    return ToI(
      headLevel: 1,
      text: content,
    );
  } else if (tag == "##") {
    return ToI(
      headLevel: 2,
      text: content,
    );
  } else if (tag == "###") {
    return ToI(
      headLevel: 3,
      text: content,
    );
  } else if (tag == "####") {
    return ToI(
      headLevel: 4,
      text: content,
    );
  } else {
    return null;
  }
}

List<ToI> getMarkDownToI(String text) {
  final listToI = <ToI>[];
  var lines = text.split("\n");
  int curOffSet = 0;
  for (var i = 0; i < lines.length; i++) {
    String line = lines[i];
    ToI? toI = getToIline(line);
    curOffSet += line.length + 1;
    if (toI != null) {
      toI.lindIndex = i;
      toI.widgetIndex = listToI.length;
      toI.offSet = curOffSet - 1;
      listToI.add(toI);
    }
  }

  return listToI;
}

String? renameFile(String oldPath, String newName) {
  final newNameTrimmed = newName.trim();
  if (newNameTrimmed.isEmpty || oldPath.isEmpty) return null;

  final parentDir = Directory(oldPath).parent;
  final newPath = _getAvailablePath(parentDir, newNameTrimmed);

  if (newPath != oldPath) {
    try {
      File(oldPath).renameSync(newPath);
    } catch (e) {
      debugPrint("Error renaming file: $e");
    }
  }

  return newPath;
}

String _getAvailablePath(Directory parent, String name) {
  var basePath = '${parent.path}${Platform.pathSeparator}$name';
  var newPath = '$basePath.md';

  for (var i = 1; File(newPath).existsSync(); i++) {
    newPath = '$basePath ($i).md';
  }
  return newPath;
}

List<Widget> getMarkDownWidgets(markDownNodes) {
  final visitor = WidgetVisitor(
    config: MarkdownConfig.defaultConfig,
    generators: const [],
  );
  final spans = visitor.visit(markDownNodes);

  final List<Widget> widgets = [];
  for (var span in spans) {
    final textSpan = span.build();
    final richText = Text.rich(textSpan);
    widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), child: richText));
  }
  return widgets;
}
