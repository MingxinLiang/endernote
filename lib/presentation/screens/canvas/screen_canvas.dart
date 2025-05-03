import 'package:endernote/common/utils.dart';
import 'package:endernote/controller/markdown_controller.dart';
import 'package:endernote/controller/dir_controller.dart';
import 'package:endernote/presentation/screens/canvas/screen_toc.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_themes.dart';
import 'edit_mode/markdown_editor.dart';
import 'preview_mode/preview_mode.dart';

class ScreenCanvas extends StatelessWidget {
  ScreenCanvas({super.key}) {
    // 注册控制器
    Get.lazyPut(() => MarkDownController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarkDownController>(
      builder: (ctrl) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            title: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: Get.back, // 使用GetX导航
                    icon: const Icon(IconsaxOutline.arrow_left_2),
                  ),
                  Expanded(
                    child: TextField(
                      controller: ctrl.titleController,
                      focusNode: ctrl.titleFocusNode,
                      onSubmitted: (newName) {
                        String? newPath =
                            renameFile(ctrl.curFilePath.value, newName);
                        if (newPath != null) {
                          ctrl.curFilePath.value = newPath;
                          Get.find<DirController>().fetchDirectory(null);
                          ctrl.titleFocusNode.unfocus();
                        }
                      }, // 回车时重命名文件
                      style: TextStyle(
                        fontFamily: 'FiraCode',
                        color: Theme.of(context)
                            .extension<EndernoteColors>()
                            ?.clrText,
                      ),
                      decoration: InputDecoration(
                        hintText: "Note Title",
                        hintStyle: TextStyle(
                          fontFamily: 'FiraCode',
                          color: Theme.of(context)
                              .extension<EndernoteColors>()
                              ?.clrText
                              .withAlpha(100),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Obx(() => IconButton(
                        icon: Icon(ctrl.editOrPreview.value
                            ? IconsaxOutline.book_1
                            : IconsaxOutline.edit_2),
                        tooltip: ctrl.editOrPreview.value ? "Preview" : "Edit",
                        onPressed: ctrl.toggleEditMode,
                      )),
                ],
              ),
            ),
          ),
          body: Obx(() {
            if (ctrl.editOrPreview.value) {
              return Row(children: [
                Expanded(
                  flex: 1,
                  child: ToIWidget(markdownController: ctrl),
                ),
                Expanded(
                  flex: 3,
                  child: MarkdownEditMode(entityPath: ctrl.curFilePath.value),
                )
              ]);
            } else {
              return Row(children: [
                Expanded(
                  flex: 1,
                  //child: TocWidget(controller: ctrl.tocController),
                  child: ToIWidget(markdownController: ctrl),
                ),
                Expanded(
                  flex: 3,
                  child: PreviewMode(
                    entityPath: ctrl.curFilePath.value,
                  ),
                )
              ]);
            }
          })),
    );
  }
}
