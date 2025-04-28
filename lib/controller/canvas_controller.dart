import 'dart:io';

import 'package:endernote/controller/file_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasController extends GetxController {
  final RxBool editOrPreview = true.obs;
  final RxString curFilePath = "".obs;
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    // 通过Get参数初始化路径
    final args = Get.arguments;
    if (args is String) {
      curFilePath.value = args;
      titleController.text = _getNameWithoutExtension(args);
    }
  }

  String _getNameWithoutExtension(String path) {
    final base = path.split(Platform.pathSeparator).last;
    return base.endsWith('.md') ? base.substring(0, base.length - 3) : base;
  }

  void toggleEditMode() => editOrPreview.toggle();

  void renameFile(String oldPath, String newName) {
    final newNameTrimmed = newName.trim();
    if (newNameTrimmed.isEmpty || oldPath.isEmpty) return;

    final parentDir = Directory(oldPath).parent;
    final newPath = _getAvailablePath(parentDir, newNameTrimmed);

    if (newPath != oldPath) {
      try {
        File(oldPath).renameSync(newPath);
        curFilePath.value = newPath;
        Get.find<FileController>().fetchDirectory(parentDir.path);
      } catch (e) {
        debugPrint("Error renaming file: $e");
      }
    }
  }

  String _getAvailablePath(Directory parent, String name) {
    var basePath = '${parent.path}${Platform.pathSeparator}$name';
    var newPath = '$basePath.md';

    for (var i = 1; File(newPath).existsSync(); i++) {
      newPath = '$basePath ($i).md';
    }
    return newPath;
  }

  @override
  void onClose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.onClose();
  }
}
