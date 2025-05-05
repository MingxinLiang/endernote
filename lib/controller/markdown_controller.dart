import 'dart:async';
import 'dart:io';
import 'package:endernote/common/logger.dart' show logger;
import 'package:endernote/common/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:scroll_to_index/scroll_to_index.dart';

// 编辑器管理
class MarkDownController extends GetxController {
  final RxBool editOrPreview = true.obs;
  final RxString curFilePath = "".obs;
  final RxInt curOffset = 0.obs;
  final RxList<md.Node> curNodes = <md.Node>[].obs;

  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final TextEditingController contentControllter = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();

  // 这两边的索引是不一样的，因为编辑模式是逐行分析，而预览模式是逐模块生成
  final listToI = <ToI>[].obs;
  final listToC = <ToI>[].obs;
  late final AutoScrollController? autoScrollController;

  late final Timer? _autoSaveTimer;

  setScrollController(AutoScrollController controller) {
    autoScrollController = controller;
  }

  updateCurFilePath(String path) {
    if (path != curFilePath.value) {
      curFilePath.value = path;
      titleController.text = _getNameWithoutExtension(path);
      loadFileContent(filePath: path);
    }
  }

  updateContentController(TextEditingController controller) {
    contentControllter.text = controller.text;
    contentControllter.selection = controller.selection;
  }

  void jumpScrollToIndex(int index) {
    logger.d("jumpScrollToIndex: $index");
    if (editOrPreview.value) {
      contentControllter.selection =
          TextSelection.collapsed(offset: listToI[index].offSet);
      contentFocusNode.requestFocus();
    } else {
      autoScrollController!.scrollToIndex(
        listToC[index].widgetIndex,
        preferPosition: AutoScrollPosition.begin,
      );
    }
  }

  Future<String> loadFileContent({String? filePath}) async {
    filePath ??= curFilePath.value;
    try {
      logger.d("Loading file: $filePath");
      final curText = await File(filePath).readAsString();
      curNodes.value = md.Document(encodeHtml: false).parse(curText);
      listToC.value = getMarkDownToc(curNodes);
      listToI.value = getMarkDownToI(curText);
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
      curNodes.value = md.Document(encodeHtml: false).parse(content);
      listToC.value = getMarkDownToc(curNodes);
      listToI.value = getMarkDownToI(content);
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
