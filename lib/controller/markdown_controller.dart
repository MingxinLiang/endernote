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
  final RxInt curIndex = 0.obs;
  final RxList<md.Node> curNodes = <md.Node>[].obs;

  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final TextEditingController contentControllter = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();

  // 这两边的索引是不一样的，因为编辑模式是逐行分析，而预览模式是逐模块生成
  final listToI = <ToI>[].obs;
  final listToC = <ToI>[].obs;
  AutoScrollController? autoScrollController;

  late final Timer? _autoSaveTimer;

  setScrollController(AutoScrollController controller) {
    autoScrollController = controller;
  }

  updateCurFilePath(String path) {
    if (path != curFilePath.value) {
      curFilePath.value = path;
      titleController.text = _getFileName(path);
      loadFileContent(filePath: path);
    }
  }

  updateContentController(TextEditingController controller) {
    contentControllter.text = controller.text;
    contentControllter.selection = controller.selection;
  }

  void jumpScrollToIndex({int? index}) {
    if (index == null) {
      index = curIndex.value;
    } else {
      curIndex.value = index;
    }

    if (index >= 0 && index < listToI.length) {
      if (editOrPreview.value) {
        contentControllter.selection =
            TextSelection.collapsed(offset: listToI[index].offSet);
        contentFocusNode.requestFocus();
        logger.d("jumpScrollToIndex: $index, offset ${listToI[index].offSet}");
      } else {
        autoScrollController!.scrollToIndex(
          listToC[index].widgetIndex,
          preferPosition: AutoScrollPosition.begin,
        );
        logger.d(
            "jumpScrollToIndex: $index, widgetIndex ${listToI[index].widgetIndex}");
      }
    }
  }

  Future<String> loadFileContent({String? filePath}) async {
    filePath ??= curFilePath.value;

    try {
      logger.d("Loading file: $filePath");
      final curText = await File(filePath).readAsString();
      curNodes.value = md.Document(encodeHtml: false).parse(curText);
      listToI.value = getMarkDownToI(curText);
      contentControllter.text = curText;
      return curText;
    } catch (e) {
      logger.e("Error loading file: $e");
      return "";
    }
  }

  List<md.Node> getNodes({String? text}) {
    if (text == null) {
      if (curNodes.isNotEmpty) {
        return curNodes;
      }
      text = contentControllter.text;
    }
    final nodes = md.Document(encodeHtml: false).parse(text);
    listToC.value = getMarkDownToC(nodes);
    return nodes;
  }

  // nodes 和list toc 同步设置
  void setNodes(List<md.Node> nodes) {
    curNodes.value = nodes;
    listToC.value = getMarkDownToC(nodes);
  }

  Future<void> saveChanges(String content, String path) async {
    try {
      await File(path).writeAsString(content);
      // 随着文本自动更新
      listToI.value = getMarkDownToI(content);
    } catch (e) {
      logger.d("Error saving file: $e");
    }
  }

  void _startAutoTask() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (curFilePath.value.isNotEmpty && editOrPreview.value) {
        saveChanges(contentControllter.text, curFilePath.value);
      }
    });
  }

  String _getFileName(String path) {
    final base = path.split(Platform.pathSeparator).last;
    return base;
  }

  Future<void> toggleEditMode() async {
    if (editOrPreview.value) {
      logger.d("save sachanges");
      await saveChanges(contentControllter.text, curFilePath.value);
    } else {}
    getNodes(text: contentControllter.text);
    logger.d(
        "nodes ${curNodes.length}, content ${contentControllter.text.length}");
    editOrPreview.toggle();
  }

  @override
  void onInit() {
    super.onInit();
    // 通过Get参数初始化路径
    final args = Get.arguments;
    if (args is String) {
      updateCurFilePath(args);
    }
    // 不同模式的初始化工作
    if (editOrPreview.value) {
      contentFocusNode.requestFocus();
    } else {
      getNodes();
    }
    _startAutoTask();
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
