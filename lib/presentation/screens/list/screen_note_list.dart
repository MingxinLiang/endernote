import 'dart:io';

import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/controller/dir_controller.dart';
import 'package:xnote/controller/markdown_controller.dart';
import 'package:xnote/presentation/screens/canvas/screen_canvas.dart';
import 'package:xnote/presentation/widgets/context_menu.dart'
    show showContextMenu;
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_fab.dart';

class ScreenNoteList extends StatelessWidget {
  const ScreenNoteList({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
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
      body: buildDirectoryList(context, path: rootPath),
      floatingActionButton: CustomFAB(rootPath: rootPath),
    );
  }
}

// TODO: 多级目录优化
Widget buildDirectoryList(BuildContext context, {String? path}) {
  return GetBuilder<DirController>(builder: (dirController) {
    logger.d("buildDirectoryList: $path");

    if (dirController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dirController.error.value.isNotEmpty) {
      return Center(
        child: Text(
          'Error: ${dirController.error.value}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    late final List<String> contents;
    if (path?.isNotEmpty ?? false) {
      dirController.fetchDirectory(path: path); // 确保目录内容已加载
      contents = dirController.folderContents[path] ?? []; // 获取当前路径的内容
    } else {
      contents = dirController.folderContents[dirController.rootPath.value] ??
          []; // 获取根路径的内容
    }

    if (contents.isEmpty) {
      return Center(
        child: Text(
          "This folder is feeling lonely.",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context)
                .extension<xnoteColors>()
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
                      ? (dirController.openFolders
                              .contains(entityPath) // 改用GetX状态
                          ? IconsaxOutline.folder_open
                          : IconsaxOutline.folder)
                      : IconsaxOutline.task_square,
                ),
                title: Text(entityPath.split('/').last),
                onTap: () async {
                  if (isFolder) {
                    dirController.toggleFolder(entityPath);
                    if (!dirController.hasFolder(entityPath)) {
                      dirController.fetchDirectory(path: entityPath);
                    }
                  } else {
                    logger.d("open file: $entityPath");
                    await Get.to(() => ScreenCanvas(filePath: entityPath));
                    Get.find<MarkDownController>()
                        .updateCurFilePath(entityPath);
                  }
                },
              ),
            ),
            if (isFolder &&
                dirController.openFolders.contains(entityPath)) // 改用GetX状态
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child:
                    buildDirectoryList(context, path: entityPath), // 移除state参数
              ),
          ],
        );
      },
    );
  });
}
