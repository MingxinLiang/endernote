import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/config/toc.dart';

List<Toc> getTocList(String text) {
  final document = md.Document();
  final nodes = document.parse(text);
  List<Toc> tocList = [];

  void traverseNodes(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Header) {
        final headerText = _getHeaderText(node);
        final start = node.sourceSpan.start.offset;
        final end = node.sourceSpan.end.offset;

        tocList.add(Toc(
          level: node.level,
          text: headerText,
          start: start,
          end: end,
        ));
      }
      if (node is md.Element && node.children != null) {
        traverseNodes(node.children!);
      }
    }
  }

  traverseNodes(nodes);
  return tocList;
}

String _getHeaderText(md.Node node) {
  if (node is md.Text) {
    return node.text;
  } else if (node is md.Element) {
    return node.children?.map(_getHeaderText).join() ?? '';
  }
  return '';
}
