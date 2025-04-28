import 'dart:io';

import 'package:endernote/controller/file_controller.dart';
import 'package:endernote/presentation/widgets/context_menu.dart'
    show showContextMenu;
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_fab.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final directoryController = Get.find<FileController>();
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<bool> hasText = ValueNotifier<bool>(false);

    searchController.addListener(() {
      hasText.value = searchController.text.isNotEmpty;
    });

    return Scaffold(
      appBar: CustomAppBar(
        rootPath: rootPath,
        controller: searchController,
        showBackButton: true,
        hasText: hasText,
      ),
      body: Obx(() {
        if (directoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (directoryController.error.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${directoryController.error.value}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return _buildDirectoryList(context, rootPath);
      }),
      floatingActionButton: CustomFAB(rootPath: rootPath),
    );
  }

  Widget _buildDirectoryList(BuildContext context, String path) {
    final directoryController = Get.find<FileController>();
    directoryController.fetchDirectory(path); // 确保目录内容已加载
    final contents =
        directoryController.folderContents[path] ?? []; // 获取当前路径的内容

    if (contents.isEmpty) {
      return Center(
        child: Text(
          "This folder is feeling lonely.",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context)
                .extension<EndernoteColors>()
                ?.clrText
                .withAlpha(100),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final entityPath = contents[index];
        final isFolder = Directory(entityPath).existsSync();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPressStart: (details) => showContextMenu(
                  context, entityPath, isFolder, "",
                  position: details.globalPosition),
              onSecondaryTapDown: (details) => showContextMenu(
                  context, entityPath, isFolder, "",
                  position: details.globalPosition),
              child: ListTile(
                leading: Icon(
                  isFolder
                      ? (directoryController.openFolders
                              .contains(entityPath) // 改用GetX状态
                          ? IconsaxOutline.folder_open
                          : IconsaxOutline.folder)
                      : IconsaxOutline.task_square,
                ),
                title: Text(entityPath.split('/').last),
                onTap: () {
                  if (isFolder) {
                    directoryController.toggleFolder(entityPath);
                    if (!directoryController.hasFolder(entityPath)) {
                      directoryController.fetchDirectory(entityPath);
                    }
                  } else {
                    Get.toNamed('/canvas', arguments: entityPath);
                  }
                },
              ),
            ),
            if (isFolder &&
                directoryController.openFolders
                    .contains(entityPath)) // 改用GetX状态
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildDirectoryList(context, entityPath), // 移除state参数
              ),
          ],
        );
      },
    );
  }
}
