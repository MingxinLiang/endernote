import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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

List<ToI> getMarkDownToC(List<md.Node> nodes) {
  final listToc = <ToI>[];
  int lastLevel = 1;

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

// 按行解析
ToI? getToIline(String text) {
  var lineSp = text.split(" ");
  var tag = lineSp[0];

  RegExp headRegExp = RegExp(r'^#+$');

  if (headRegExp.hasMatch(tag)) {
    int headLevel = tag.length;
    String content = text.substring(tag.length + 1).trim();
    return ToI(
      headLevel: headLevel,
      text: content,
    );
  }

  return null;
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

// 用于展示
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

Future<String> move2Directory(String sourcePath, String targetDir) async {
  String soureParent = "";
  try {
    final sourceEntity = FileSystemEntity.typeSync(sourcePath);
    final sourceName = sourcePath.split('/').last;
    final targetPath = '$targetDir/$sourceName';

    if (targetPath == sourcePath) {
      return "";
    }

    // 移动文件或文件夹
    if (sourceEntity == FileSystemEntityType.file) {
      // ignore: no_leading_underscores_for_local_identifiers
      final _sourcePath = File(sourcePath);
      await _sourcePath.rename(targetPath);
      soureParent = _sourcePath.parent.path;
    } else if (sourceEntity == FileSystemEntityType.directory) {
      // ignore: no_leading_underscores_for_local_identifiers
      final _sourcePath = Directory(sourcePath);
      await _sourcePath.rename(targetPath);
      soureParent = _sourcePath.parent.path;
    }
  } catch (e) {
    Get.snackbar("ERR", 'Failed to move file/directory: $e');
  }

  return soureParent;
}
