import 'package:endernote/common/logger.dart' show logger;
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/widget/blocks/leaf/heading.dart'
    show HeadingNode;
import 'package:markdown_widget/widget/widget_visitor.dart';

///config for toc
class Toc {
  final HeadingNode node;
  final int widgetIndex;
  final int selfIndex;

  Toc({
    required this.node,
    this.widgetIndex = 0,
    this.selfIndex = 0,
  });
}

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
