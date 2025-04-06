// DirectoryController 负责管理根目录路径
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryController extends GetxController {
  // 根目录路径
  RxString rootPath = ''.obs;
  // 加载状态
  RxBool isLoading = false.obs;
  // 错误信息
  RxString error = ''.obs;

  Future<void> fetchRootPath() async {
    isLoading.value = true;
    error.value = '';
    try {
      late final String path;
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        final directory = await getApplicationDocumentsDirectory();
        path = '${directory.path}/Endernote';
      } else {
        final directory = await getExternalStorageDirectory();
        path = '${directory!.path}/Endernote';
      }
      final folder = Directory(path);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      rootPath.value = folder.path;
    } catch (e) {
      error.value = 'Error fetching root path: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 新增路径更新方法
  void updateRootPath(String newPath) {
    rootPath.value = newPath;
    // 这里可以添加路径持久化逻辑
    // _saveToPreferences(newPath);
  }

  // Future<void> _saveToPreferences(String path) async {
  //   // 实现本地存储逻辑（如使用 shared_preferences）
  // }

  // Future<void> _loadFromPreferences() async {
  //   // 实现本地加载逻辑
  // }
}
