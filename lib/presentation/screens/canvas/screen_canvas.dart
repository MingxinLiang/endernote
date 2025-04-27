import 'package:endernote/controller/canvas_controller.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import 'edit_mode/edit_mode.dart';
import 'preview_mode/preview_mode.dart';
import 'package:get/get.dart';

class ScreenCanvas extends StatelessWidget {
  ScreenCanvas({super.key}) {
    // 注册控制器
    Get.lazyPut(() => CanvasController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CanvasController>(
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
                    onSubmitted: (newName) => // 回车时重命名文件
                        ctrl.renameFile(ctrl.curFilePath.value, newName),
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
                          ? IconsaxOutline.edit_2
                          : IconsaxOutline.book_1),
                      onPressed: ctrl.toggleEditMode,
                    )),
              ],
            ),
          ),
        ),
        body: Obx(() => ctrl.editOrPreview.value
            ? EditMode(entityPath: ctrl.curFilePath.value)
            : PreviewMode(entityPath: ctrl.curFilePath.value)),
      ),
    );
  }
}
