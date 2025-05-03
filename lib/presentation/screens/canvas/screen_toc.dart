import 'package:endernote/common/logger.dart' show logger;
import 'package:endernote/common/utils.dart';
import 'package:endernote/controller/markdown_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/material.dart';
import "package:get/get.dart";

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

class ToIWidget extends StatelessWidget {
  final MarkDownController markdownController;
  final currentIndex = 0.obs;
  late final AutoScrollController? scrollController;

  /// use [tocTextStyle] to set the style of the toc item
  final TextStyle tocTextStyle = defaultTocTextStyle;
  final TextStyle currentTocTextStyle = defaultCurrentTocTextStyle;

  ToIWidget(
      {super.key, required this.markdownController, this.scrollController});

  Widget toiItermBuilder(ToI toi, bool isCurrent) {
    final child = ListTile(
      title: Container(
        margin: EdgeInsets.only(left: 20.0 * toi.headLevel),
        child: Text(toi.text,
            style: isCurrent ? currentTocTextStyle : tocTextStyle),
      ),
      onTap: () {
        currentIndex.value = toi.widgetIndex;
        markdownController.moveCursorToPosition(toi.offSet);
        logger.d("Toi index: $currentIndex, offSet: ${toi.offSet}");
      },
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 监听 RxList 的变化
    return Obx(() {
      RxList<ToI> listToI = markdownController.listToI;
      logger.d(
          "build toc widget, listToI.length: ${listToI.length}, index: $currentIndex");
      return ListView.builder(
        itemBuilder: (ctx, index) {
          final currentToc = listToI[index];
          bool isCurrentToc = index == currentIndex.value;
          return toiItermBuilder(currentToc, isCurrentToc);
        },
        itemCount: listToI.length,
      );
    });
  }
}
