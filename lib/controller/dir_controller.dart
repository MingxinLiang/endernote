// DirectoryController 负责管理根目录路径
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DirController extends GetxController {
  // 根目录路径
  RxString rootPath = ''.obs;
  // 加载状态
  RxBool isLoading = false.obs;
  // 错误信息
  RxString error = ''.obs;

  // 只保留这个Map形式的folderContents
  final RxMap<String, List<String>> folderContents =
      <String, List<String>>{}.obs;
  final RxSet<String> openFolders = <String>{}.obs;

  void toggleFolder(String path) {
    if (openFolders.contains(path)) {
      openFolders.remove(path);
    } else {
      openFolders.add(path);
    }
  }

  bool hasFolder(String path) => folderContents.containsKey(path);

  // 修改后的 fetchDirectory 方法
  void fetchDirectory(String? path) async {
    path ??= rootPath.value;

    try {
      isLoading.value = true;
      final folder = Directory(path);
      if (!await folder.exists()) await folder.create(recursive: true);

      final entities = folder.listSync();
      folderContents[path] = entities.map((e) => e.path).toList();
      error.value = '';
    } catch (e) {
      error.value = 'Directory fetch failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<List<String>> searchDirectory(String query) async {
    if (query.isEmpty) return [];

    final results = <String>[];

    try {
      await for (final entity
          in Directory(rootPath.value).list(recursive: true)) {
        final path = entity.path;

        // Skip hidden files/directories
        if (path.split('/').last.startsWith('.')) continue;

        // Check if file name contains query
        if (path.split('/').last.toLowerCase().contains(query.toLowerCase())) {
          results.add(path);
          continue;
        }

        // If it's a file, also check its content
        if (entity is File && path.endsWith('.md')) {
          try {
            final content = await File(path).readAsString();
            if (content.toLowerCase().contains(query.toLowerCase())) {
              results.add(path);
            }
          } catch (_) {}
        }
      }
      return results;
    } catch (e) {
      throw Exception('Failed to search directory: $e');
    }
  }

  // 新增路径更新方法
  void updateRootPath(String newPath) {
    rootPath.value = newPath;
    // 这里可以添加路径持久化逻辑
    // _saveToPreferences(newPath);
  }
}
