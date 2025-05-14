import 'package:shared_preferences/shared_preferences.dart';
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/common/utils.dart';
import 'package:xnote/controller/markdown_controller.dart';
import 'package:xnote/controller/dir_controller.dart';
import 'package:xnote/controller/tools_bar_controller.dart';
import 'package:xnote/presentation/screens/canvas/tools/tools_bar.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_themes.dart';
import 'edit_mode/markdown_editor.dart';
import 'preview_mode/preview_mode.dart';

class ScreenCanvas extends StatelessWidget {
  final String filePath;
  const ScreenCanvas({super.key, required this.filePath});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    Get.put(ToolsBarController(index: prefs.getInt("selectedToolIndex")));
    Get.put(MarkDownController(filePath: filePath));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
              // 标题栏
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                  title: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<xnoteColors>()
                          ?.clrbackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Builder(
                      builder: (context) {
                        final ctrl = Get.find<MarkDownController>();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Get.back(), // 使用GetX导航
                              icon: const Icon(IconsaxOutline.arrow_left_2),
                            ),
                            Expanded(
                              child: TextField(
                                controller: ctrl.titleController,
                                focusNode: ctrl.titleFocusNode,
                                onSubmitted: (newName) {
                                  String? newPath = renameFile(
                                      ctrl.curFilePath.value, newName);
                                  if (newPath != null) {
                                    ctrl.curFilePath.value = newPath;
                                    Get.find<DirController>().fetchDirectory();
                                    ctrl.titleFocusNode.unfocus();
                                  }
                                }, // 回车时重命名文件
                                style: TextStyle(
                                  fontFamily: 'FiraCode',
                                  color: Theme.of(context)
                                      .extension<xnoteColors>()
                                      ?.clrbackText,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Note Title",
                                  hintStyle: TextStyle(
                                    fontFamily: 'FiraCode',
                                    color: Theme.of(context)
                                        .extension<xnoteColors>()
                                        ?.clrText
                                        .withAlpha(100),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            GetBuilder<MarkDownController>(
                                builder: (ctrl) => IconButton(
                                      icon: Icon(ctrl.editOrPreview.value
                                          ? IconsaxOutline.book_1
                                          : IconsaxOutline.edit_2),
                                      tooltip: ctrl.editOrPreview.value
                                          ? "Preview"
                                          : "Edit",
                                      onPressed: ctrl.toggleMode,
                                    )),
                          ],
                        );
                      },
                    ),
                  )),
              // 主体内容
              body: Row(children: [
                SizedBox(
                  height: double.infinity,
                  child: ToolsBar(),
                ),
                Expanded(child: GetBuilder<MarkDownController>(builder: (ctrl) {
                  return ctrl.editOrPreview.value
                      ? MarkdownEditMode()
                      : PreviewMode();
                }))
              ]));
        });
  }
}
