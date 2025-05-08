// DirectoryController 负责管理根目录路径
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xnote/common/logger.dart' show logger;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirController extends GetxController {
  RxString rootPath = ''.obs;
  // 加载状态
  RxBool isLoading = false.obs;
  // 错误信息
  RxString error = ''.obs;

  // 只保留这个Map形式的folderContents
  final RxMap<String, List<String>> folderContents =
      <String, List<String>>{}.obs;
  final RxSet<String> openFolders = <String>{}.obs;

  DirController({String? rootPath}) {
    if (rootPath != null) {
      this.rootPath.value = rootPath;
      fetchDirectory();
    }
  }

  void toggleFolder(String path) {
    if (openFolders.contains(path)) {
      openFolders.remove(path);
    } else {
      openFolders.add(path);
    }
  }

  bool hasFolder(String path) => folderContents.containsKey(path);

  // 修改后的 fetchDirectory 方法
  void fetchDirectory({String? path}) async {
    path ??= rootPath.value;
    isLoading.value = true;
    bool isUpdate = false;

    try {
      final folder = Directory(path);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
        isUpdate = true;
      }

      final entities = folder.listSync();
      final entitiesLst = entities.map((e) => e.path).toList();
      if (!folderContents.containsKey(path) ||
          !listEquals(folderContents[path], entitiesLst)) {
        folderContents[path] = entitiesLst;
        isUpdate = true;
      }
      error.value = '';
    } catch (e) {
      error.value = 'Directory fetch failed: ${e.toString()}';
      logger.e(error.value);
    } finally {
      isLoading.value = false;
      if (isUpdate) {
        update();
      }
    }
  }

  Future<void> fetchRootPath() async {
    error.value = '';
    try {
      late final String path;
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        final directory = await getApplicationDocumentsDirectory();
        path = '${directory.path}/xnote';
      } else {
        final directory = await getExternalStorageDirectory();
        path = '${directory!.path}/xnote';
      }
      final folder = Directory(path);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      rootPath.value = folder.path;
    } catch (e) {
      error.value = 'Error fetching root path: ${e.toString()}';
      logger.e(error.value);
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
          final content = await File(path).readAsString();
          if (content.toLowerCase().contains(query.toLowerCase())) {
            results.add(path);
          }
        }
      }
      return results;
    } catch (e) {
      error.value = 'Error searching directory: ${e.toString()}';
      throw Exception('Failed to search directory: $e');
    }
  }

  // 新增路径更新方法
  Future<void> updateRootPath(String newPath) async {
    if (newPath != rootPath.value) {
      rootPath.value = newPath;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('rootPath', newPath);
      fetchDirectory();
    }
  }
}
