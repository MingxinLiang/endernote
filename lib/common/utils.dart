import 'package:endernote/common/logger.dart' show logger;
import 'package:markdown_widget/config/toc.dart' show Toc;
import 'package:markdown/markdown.dart' as md;

List<Toc> getMarkDownToc(String text) {
  final nodes = md.Document(encodeHtml: false).parse(text);
  final listToc = <Toc>[];

  // 遍历Markdown语法树
  for (final node in nodes) {
    logger.d(node);
  }

  return listToc; // 添加返回语句
}
