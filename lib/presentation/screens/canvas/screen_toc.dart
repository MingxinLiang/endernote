import 'package:endernote/common/logger.dart';
import 'package:endernote/common/utils.dart';
import 'package:endernote/controller/markdown_controller.dart';
import 'package:flutter/material.dart';
import "package:get/get.dart";

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

class ToIWidget extends StatelessWidget {
  // preview model 和 edit model 目前用不同的内容建立索引
  // 主要是因为目前edit model 目前只支持单行分析
  final MarkDownController markdownController;

  /// use [tocTextStyle] to set the style of the toc item
  final TextStyle tocTextStyle = defaultTocTextStyle;
  final TextStyle currentTocTextStyle = defaultCurrentTocTextStyle;

  const ToIWidget({super.key, required this.markdownController});

  // for edit model
  // ignore: non_constant_identifier_names
  Widget ItemBuilder(ToI toi) {
    final markdownController = Get.find<MarkDownController>();
    final curIndex = markdownController.curIndex;
    final child = Obx(() => ListTile(
          title: Container(
            margin: EdgeInsets.only(left: 20.0 * toi.headLevel),
            child: Text(toi.text,
                style: curIndex.value == toi.widgetIndex
                    ? currentTocTextStyle
                    : tocTextStyle),
          ),
          onTap: () {
            markdownController.jumpScrollToIndex(index: toi.widgetIndex);
            markdownController.curIndex.value = toi.widgetIndex;
          },
        ));
    return child;
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Obx 监听 RxList 的变化
    return Obx(() {
      RxList<ToI> listToI = markdownController.editOrPreview.value
          ? markdownController.listToI
          : markdownController.listToC;
      return ListView.builder(
        itemBuilder: (ctx, index) {
          final currentToc = listToI[index];
          return ItemBuilder(currentToc);
        },
        itemCount: listToI.length,
      );
    });
  }
}
