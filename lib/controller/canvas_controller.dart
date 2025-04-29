import 'dart:async';
import 'dart:io';
import 'package:endernote/common/logger.dart' show logger;
import 'package:endernote/controller/dir_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 编辑器管理
class CanvasController extends GetxController {
  final RxBool editOrPreview = true.obs;
  final RxString curFilePath = "".obs;
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final TextEditingController contentControllter = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();
  Timer? _autoSaveTimer;

  updateCurFilePath(String path) {
    curFilePath.value = path;
    titleController.text = _getNameWithoutExtension(path);
  }

  updateContentController(TextEditingController controller) {
    contentControllter.text = controller.text;
    contentControllter.selection = controller.selection;
  }

  Future<String> loadFileContent({String? filePath}) async {
    filePath ??= curFilePath.value;
    try {
      logger.d("Loading file: $filePath");
      final curText = await File(filePath).readAsString();
      contentControllter.text = curText;
      return curText;
    } catch (e) {
      logger.d("Error loading file: $e");
      return "";
    }
  }

  Future<void> saveChanges(String content, String path) async {
    try {
      await File(path).writeAsString(content);
    } catch (e) {
      logger.d("Error saving file: $e");
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (curFilePath.value.isNotEmpty && editOrPreview.value) {
        saveChanges(contentControllter.text, curFilePath.value);
      }
    });
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
        Get.find<DirController>().fetchDirectory(parentDir.path);
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
  void onInit() {
    super.onInit();
    // 通过Get参数初始化路径
    final args = Get.arguments;
    if (args is String) {
      updateCurFilePath(args);
    }
    _startAutoSave();
  }

  @override
  void onClose() {
    saveChanges(contentControllter.text, curFilePath.value);
    titleController.dispose();
    titleFocusNode.dispose();
    _autoSaveTimer?.cancel();
    super.onClose();
  }
}
