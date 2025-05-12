import 'dart:io';
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/controller/dir_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:get/get.dart';
import 'package:xnote/presentation/screens/canvas/screen_canvas.dart'
    show ScreenCanvas;
import '../theme/app_themes.dart';

// 右下角悬浮按钮
// 功能：创建文件夹、创建文件
class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key, required this.rootPath});
  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    final TextEditingController folderController = TextEditingController();
    final TextEditingController fileController = TextEditingController();

    final dirController = Get.find<DirController>();

    return SpeedDial(
      openCloseDial: isDialOpen,
      children: [
        _buildDialChild(
          context,
          controller: folderController,
          icon: IconsaxOutline.folder,
          label: "Folder",
          onCreate: () async {
            if (folderController.text.isNotEmpty) {
              await Directory(
                '$rootPath/${folderController.text}',
              ).create(recursive: true);
              dirController.fetchDirectory(path: rootPath);
            }
            Get.back();
            folderController.clear();
          },
        ),
        _buildDialChild(
          context,
          controller: fileController,
          icon: IconsaxOutline.task_square,
          label: "Note",
          onCreate: () async {
            if (fileController.text.isNotEmpty) {
              File newFile = File('$rootPath/${fileController.text}.md');
              newFile.create(recursive: true);
              dirController.fetchDirectory(path: newFile.parent.path);
              fileController.clear();
              Get.back();
              Get.to(() => ScreenCanvas(filePath: newFile.path));
            } else {
              Get.back();
            }
          },
        ),
      ],
      child: const Icon(IconsaxOutline.add),
    );
  }

  SpeedDialChild _buildDialChild(
    BuildContext context, {
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required Future<void> Function() onCreate,
  }) {
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          final textfocus = FocusNode();
          textfocus.requestFocus();
          return AlertDialog(
            backgroundColor:
                Theme.of(context).extension<xnoteColors>()?.clrBase,
            title: Text(
              'New $label',
              style: TextStyle(
                color: Theme.of(context).extension<xnoteColors>()?.clrText,
              ),
            ),
            content: TextField(
              controller: controller,
              focusNode: textfocus,
              decoration: InputDecoration(
                hintText: '$label name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (value) => onCreate(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.clear();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: onCreate,
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
