import 'package:endernote/common/logger.dart';
import 'package:endernote/common/utils.dart';
import 'package:endernote/controller/markdown_controller.dart';
import 'package:endernote/controller/dir_controller.dart';
import 'package:endernote/presentation/screens/canvas/screen_toc.dart';
import 'package:endernote/presentation/screens/list/screen_note_list.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_themes.dart';
import 'edit_mode/markdown_editor.dart';
import 'preview_mode/preview_mode.dart';

class ScreenCanvas extends StatelessWidget {
  ScreenCanvas({super.key}) {
    // 注册控制器
    Get.put(MarkDownController());
    curfilePath.value = Get.arguments;
  }
  final curfilePath = "".obs;
  final showToI = true.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarkDownController>(
        builder: (ctrl) => Scaffold(
            // 标题栏
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              title: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<EndernoteColors>()
                      ?.clrbackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
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
                              ?.clrbackText,
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
                          tooltip:
                              ctrl.editOrPreview.value ? "Preview" : "Edit",
                          onPressed: ctrl.toggleEditMode,
                        )),
                  ],
                ),
              ),
            ),
            // 主体内容
            body: Obx(() {
              return Row(children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                    .extension<EndernoteColors>()
                                    ?.clrbackText
                                    .withAlpha(50) ??
                                Colors.white.withAlpha(10),
                            width: 5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() {
                        if (showToI.value && ctrl.listToI.isNotEmpty) {
                          return ToIWidget(markdownController: ctrl);
                        } else {
                          return buildDirectoryList(context);
                        }
                      }),
                    )),
                Expanded(
                  flex: 3,
                  child: ctrl.editOrPreview.value
                      ? MarkdownEditMode(entityPath: ctrl.curFilePath.value)
                      : PreviewMode(
                          filePath: ctrl.curFilePath.value,
                        ),
                )
              ]);
            })));
  }
}
