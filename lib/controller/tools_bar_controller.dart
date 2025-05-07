import 'package:get/get.dart';

// 状态控制器
class ToolsBarController extends GetxController {
  final selectedIndex = 0.obs;

  ToolsBarController({index = 0}) {
    selectedIndex.value = index;
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
