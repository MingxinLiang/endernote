import 'dart:math' show min;
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/controller/tools_bar_controller.dart';
import 'package:xnote/presentation/screens/canvas/tools/screen_toc.dart'
    show ToIWidget;
import 'package:xnote/presentation/screens/list/screen_note_list.dart';
import 'package:xnote/presentation/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 活动栏组件
class ToolsBar extends StatelessWidget {
  const ToolsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final names = ["大纲", "目录"];
    final icons = [Icons.outlined_flag_outlined, Icons.folder];

    Widget getTools(BuildContext context, index) {
      Widget? result;
      switch (index) {
        case 0:
          result = ToIWidget();
          break;
        case 1:
          result = Align(
              alignment: Alignment.topLeft, child: buildDirectoryList(context));
          break;
        default:
          result = SizedBox.shrink();
      }
      logger.d("getTools: $result, index: $index, width: ${Get.width}");

      return result;
    }

    Widget itemBuilder(context, index) {
      return GetBuilder<ToolsBarController>(builder: (controller) {
        return IconButton(
            icon: Icon(
              icons[index],
              color: controller.selectedIndex.value == index
                  ? Colors.white.withAlpha(200)
                  : Colors.white.withAlpha(50),
            ),
            tooltip: names[index],
            onPressed: () => controller.changeSelectedToolIndex(index));
      });
    }

    return Container(
        color: Colors.white.withAlpha(10),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.white.withAlpha(10), width: 3),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: Colors.transparent,
            ),
            width: min(50, Get.width * 0.03),
            height: double.infinity,
            child: ListView.builder(
              itemBuilder: itemBuilder,
              itemCount: icons.length,
            ),
          ),
          GetBuilder<ToolsBarController>(
              builder: (ToolsBarController controller) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                          .extension<xnoteColors>()
                          ?.clrbackText
                          .withAlpha(50) ??
                      Colors.white.withAlpha(10),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: controller.selectedIndex.value >= 0
                  ? min(1000, Get.width * 0.15)
                  : 0,
              height: double.infinity,
              child: getTools(context, controller.selectedIndex.value),
            );
          }),
        ]));
  }
}
