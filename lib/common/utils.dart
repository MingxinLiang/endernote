import 'package:endernote/common/logger.dart' show logger;
import 'package:flutter/widgets.dart';
import 'package:markdown_widget/config/toc.dart' show Toc;
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/widget/blocks/leaf/heading.dart'
    show HeadingNode;
import 'package:markdown_widget/widget/widget_visitor.dart';

List<Toc> getMarkDownToc(String text) {
  final nodes = md.Document(encodeHtml: false).parse(text);
  final listToc = <Toc>[];
  final visitor = WidgetVisitor(onNodeAccepted: (node, index) {
    if (node is HeadingNode) {
      final listLength = listToc.length;
      logger.d("indx: $index, selfIndex: $listLength");
      listToc.add(Toc(node: node, widgetIndex: index, selfIndex: listLength));
    }
  });
  visitor.visit(nodes);

  return listToc; // 添加返回语句
}

// 用于文本索引
class ToI {
  ///the HeadingNode
  final int headLevel;
  final String text;
  int lindIndex;
  int widgetIndex;

  ToI(
      {required this.headLevel,
      required this.text,
      this.lindIndex = 0,
      this.widgetIndex = 0});
}

ToI? getToIline(String text) {
  var lineSp = text.split(" ");
  var tag = lineSp[0];
  String content = text.substring(tag.length + 1);

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
  for (var i = 0; i < lines.length; i++) {
    String line = lines[i];
    ToI? toI = getToIline(line);
    if (toI != null) {
      toI.lindIndex = i;
      toI.widgetIndex = listToI.length;
      listToI.add(toI);
    }
  }

  return listToI;
}
