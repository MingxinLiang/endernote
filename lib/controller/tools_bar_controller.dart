import 'package:get/get.dart';

// 状态控制器
class ToolsBarController extends GetxController {
  final selectedIndex = 0.obs;

  ToolsBarController({int? index}) {
    if (index != null) {
      selectedIndex.value = index;
    } else {
      selectedIndex.value = -1;
    }
  }

  void changeSelectedToolIndex(int index) {
    if (index == selectedIndex.value) {
      selectedIndex.value = -1;
    } else {
      selectedIndex.value = index;
    }
    update();
  }
}
