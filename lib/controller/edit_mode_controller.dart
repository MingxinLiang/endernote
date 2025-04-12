import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class EditModeController extends GetxController {
  final String entityPath;
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final _isSaving = false.obs;

  EditModeController(this.entityPath) {
    _initController();
  }

  Future<void> _initController() async {
    try {
      textController.text = await File(entityPath).readAsString();
    } catch (e) {
      Get.snackbar('错误', '文件加载失败: ${e.toString()}');
    }
  }

  void handleFormatting(String prefix, [String suffix = '']) {
    final selection = textController.selection;
    final text = textController.text;

    if (selection.start != selection.end) {
      textController.text = text.replaceRange(selection.start, selection.end,
          '$prefix${text.substring(selection.start, selection.end)}$suffix');
      textController.selection = TextSelection.collapsed(
          offset: selection.end + prefix.length + suffix.length);
    } else {
      textController.text =
          text.replaceRange(selection.start, selection.start, '$prefix$suffix');
      textController.selection =
          TextSelection.collapsed(offset: selection.start + prefix.length);
    }
    _saveChanges();
    focusNode.requestFocus();
  }

  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      // ... 原有的列表处理逻辑迁移到这里 ...
    }
    return false;
  }

  void _saveChanges() {
    if (_isSaving.value) return;
    _isSaving.value = true;

    Debouncer().run(() async {
      try {
        await File(entityPath).writeAsString(textController.text);
      } catch (e) {
        Get.snackbar('错误', '保存失败: ${e.toString()}');
      } finally {
        _isSaving.value = false;
      }
    });
  }
}

class Debouncer {
  final _delay = Duration(milliseconds: 500);
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(_delay, action);
  }
}
