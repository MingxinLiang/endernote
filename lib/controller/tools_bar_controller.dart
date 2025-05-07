import 'package:endernote/common/logger.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void changeSelectedToolIndex(int index) async {
    if (index == selectedIndex.value) {
      selectedIndex.value = -1;
    } else {
      selectedIndex.value = index;
    }
    update();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedToolIndex', index);
  }
}
