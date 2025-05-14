import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 创建控制器类，继承 GetxController 并混入 WidgetsBindingObserver
class WindowSizeController extends GetxController with WidgetsBindingObserver {
  // 用于标记窗口尺寸是否变化
  final isWindowSizeChanged = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 注册为观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 窗口尺寸变化时更新状态
    update();
  }
}
