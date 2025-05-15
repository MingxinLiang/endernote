import 'dart:io';

import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/controller/dir_controller.dart';
import 'package:xnote/controller/markdown_controller.dart';
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
        showBackButton: true,
      ),
      body: buildDirectoryList(context, path: rootPath),
      floatingActionButton: CustomFAB(rootPath: rootPath),
    );
  }
}

// TODO: 多级目录优化
Widget buildDirectoryList(BuildContext context, {String? path}) {
  final dirController = Get.find<DirController>();
  return FutureBuilder(
      future: dirController.fetchDirectory(path: path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
        if (path == null) {
          contents =
              dirController.folderContents[dirController.rootPath.value] ?? [];
        } else {
          contents = dirController.folderContents[path] ?? []; // 获取当前路径的内容
        }

        if (contents.isEmpty) {
          return Center(
            child: Text(
              "This folder is feeling lonely.",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .extension<XnoteColors>()
                    ?.clrText
                    .withAlpha(100),
              ),
            ),
          );
        }

        return GetBuilder<DirController>(builder: (dirController) {
          return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final entityPath = contents[index];
                final isFolder = Directory(entityPath).existsSync();
                final isCurPath = dirController.currentPath.value == entityPath;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onLongPressStart: (details) => showContextMenu(
                          context, entityPath, isFolder,
                          position: details.globalPosition),
                      onSecondaryTapDown: (details) => showContextMenu(
                          context, entityPath, isFolder,
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
                        title: Text(entityPath.split('/').last,
                            style: TextStyle(
                              color: isCurPath ? Colors.blue : null,
                            )),
                        onTap: () async {
                          if (isFolder) {
                            dirController.toggleFolder(entityPath);
                            if (!dirController.hasFolder(entityPath)) {
                              dirController.fetchDirectory(path: entityPath);
                            }
                          } else {
                            logger.d("open file: $entityPath");
                            // 通过MarkDownController更新,不更新UI, 只更新内容.
                            Get.find<MarkDownController>()
                                .setCurFilePath(entityPath);
                            await Get.toNamed("/canvas");
                          }
                        },
                      ),
                    ),
                    if (isFolder &&
                        dirController.openFolders
                            .contains(entityPath)) // 改用GetX状态
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: buildDirectoryList(context,
                            path: entityPath), // 移除state参数
                      ),
                  ],
                );
              });
        });
      });
}
