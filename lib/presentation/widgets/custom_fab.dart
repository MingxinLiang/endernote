import 'dart:io';
import 'package:endernote/controller/directory_controller.dart';
import 'package:endernote/presentation/screens/canvas/edit_mode/edit_mode.dart';
import "package:get/get.dart";

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:path/path.dart';

import '../../bloc/directory/directory_bloc.dart';
import '../../bloc/directory/directory_events.dart';
import '../theme/app_themes.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    final TextEditingController folderController = TextEditingController();
    final TextEditingController fileController = TextEditingController();
    final directoryController = Get.find<DirectoryController>();

    return SpeedDial(
      openCloseDial: isDialOpen,
      children: [
        _buildDialChild(
          context,
          controller: folderController,
          icon: IconsaxOutline.folder,
          label: "Folder",
          dialogTitle: "New Folder",
          hintText: "Folder name",
          onCreate: () async {
            if (folderController.text.isNotEmpty) {
              final newPath = '$rootPath/${folderController.text}';
              await Directory(newPath).create(recursive: true);
              directoryController.fetchDirectory(rootPath);
            }
          },
        ),
        _buildDialChild(
          context,
          controller: fileController,
          icon: IconsaxOutline.task_square,
          label: "Note",
          dialogTitle: "New File",
          hintText: "File name",
          onCreate: () async {
            if (fileController.text.isNotEmpty) {
              final filePath = '$rootPath/${fileController.text}.md';
              await File(filePath).create(recursive: true);
              directoryController.fetchDirectory(rootPath);
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
    required String dialogTitle,
    required String hintText,
    required Future<void> Function() onCreate,
  }) {
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).extension<EndernoteColors>()?.clrBase,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dialogTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .extension<EndernoteColors>()
                            ?.clrText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          controller.clear();
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text("Create"),
                        onPressed: () async {
                          await onCreate();
                          controller.clear();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
