import 'dart:io';
import 'dart:math' show max;
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/common/utils.dart' show move2Directory;
import 'package:xnote/controller/dir_controller.dart';
import 'package:xnote/controller/tools_bar_controller.dart';
import 'package:xnote/presentation/screens/canvas/tools/screen_toc.dart'
    show ToIWidget;
import 'package:xnote/presentation/screens/list/screen_note_list.dart';
import 'package:xnote/presentation/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xnote/presentation/widgets/context_menu.dart'
    show showContextMenu;

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
          result =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            buildDirectoryList(context,
                path: Get.find<DirController>().rootPath.value),
            Expanded(
                // TODO: 抽象出拖拽类
                child: GestureDetector(
                    onSecondaryTapDown: (details) => showContextMenu(
                        context, Get.find<DirController>().rootPath.value, true,
                        position: details.globalPosition),
                    child: DragTarget(
                      onWillAcceptWithDetails: (details) {
                        if (details.data != null && details.data is String) {
                          return FileSystemEntity.typeSync(
                                  details.data as String) !=
                              FileSystemEntityType.notFound;
                        }
                        return false;
                      },
                      onAcceptWithDetails: (details) async {
                        final dirController = Get.find<DirController>();
                        final targetDir = dirController.rootPath.value;
                        String soureParent = await move2Directory(
                            details.data as String, targetDir);
                        if (soureParent.isNotEmpty) {
                          dirController.fetchDirectory(path: soureParent);
                          dirController.fetchDirectory(path: targetDir);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        final blackColor = candidateData.isNotEmpty
                            ? Colors.white24
                            : Colors.transparent;
                        return Container(color: blackColor);
                      },
                    ))),
          ]);
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
            width: max(50, Get.width * 0.03),
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
                          .extension<XnoteColors>()
                          ?.clrbackText
                          .withAlpha(50) ??
                      Colors.white.withAlpha(10),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: controller.selectedIndex.value >= 0
                  ? max(200, Get.width * 0.15)
                  : 0,
              height: double.infinity,
              child: getTools(context, controller.selectedIndex.value),
            );
          }),
        ]));
  }
}
