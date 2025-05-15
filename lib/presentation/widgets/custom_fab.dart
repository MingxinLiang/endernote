import 'dart:io';
import 'package:xnote/controller/dir_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:get/get.dart';
import 'package:xnote/controller/markdown_controller.dart'
    show MarkDownController;
import 'package:xnote/presentation/widgets/context_menu.dart';
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

    return SpeedDial(
      openCloseDial: isDialOpen,
      children: [
        _buildDialChild(
          context,
          controller: folderController,
          icon: IconsaxOutline.folder,
          label: "Folder",
          onCreate: () => createNewFolder(),
        ),
        _buildDialChild(context,
            controller: fileController,
            icon: IconsaxOutline.task_square,
            label: "Note", onCreate: () async {
          final newFilePath = await createNewFile(dirPath: rootPath);
          Get.find<DirController>().fetchDirectory(path: rootPath);
          Get.find<MarkDownController>().setCurFilePath(newFilePath);
          Get.toNamed("/canvas");
        }),
      ],
      child: const Icon(IconsaxOutline.add),
    );
  }

  SpeedDialChild _buildDialChild(
    BuildContext context, {
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required Function() onCreate,
  }) {
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      onTap: () => onCreate(),
    );
  }
}
