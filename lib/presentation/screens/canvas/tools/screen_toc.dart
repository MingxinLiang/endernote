import 'package:xnote/common/utils.dart';
import 'package:xnote/controller/markdown_controller.dart';
import 'package:flutter/material.dart';
import "package:get/get.dart";

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

class ToIWidget extends StatelessWidget {
  // preview model 和 edit model 目前用不同的内容建立索引
  // 主要是因为目前edit model 目前只支持单行分析

  /// use [tocTextStyle] to set the style of the toc item
  final TextStyle tocTextStyle = defaultTocTextStyle;
  final TextStyle currentTocTextStyle = defaultCurrentTocTextStyle;

  const ToIWidget({super.key});

  // for edit model
  // ignore: non_constant_identifier_names
  Widget ItemBuilder(ToI toi) {
    // 这里用Box 主要是toi的变化频率会比较搞
    final markdownController = Get.find<MarkDownController>();

    return Obx(() => ListTile(
          title: Container(
            margin: EdgeInsets.only(left: 20.0 * (toi.headLevel - 1)),
            child: Text(toi.text,
                style: toi.widgetIndex == markdownController.curIndex.value
                    ? currentTocTextStyle
                    : tocTextStyle),
          ),
          onTap: () {
            markdownController.curIndex.value = toi.widgetIndex;
            markdownController.jumpScrollToIndex(index: toi.widgetIndex);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 监听 RxList 的变化
    final markdownController = Get.find<MarkDownController>();
    RxList<ToI> listToI = markdownController.editOrPreview.value
        ? markdownController.listToI
        : markdownController.listToC;
    //return Obx(() {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final currentToc = listToI[index];
        return ItemBuilder(currentToc);
      },
      itemCount: listToI.length,
    );
    //});
  }
}
