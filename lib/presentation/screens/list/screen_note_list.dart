import 'dart:io';

import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/common/utils.dart';
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
  const ScreenNoteList({super.key, required this.dirPath});

  final String dirPath;

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<bool> hasText = ValueNotifier<bool>(false);

    searchController.addListener(() {
      hasText.value = searchController.text.isNotEmpty;
    });

    return Scaffold(
      appBar: CustomAppBar(
        rootPath: dirPath,
        showBackButton: true,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildDirectoryList(context, path: dirPath),
        Expanded(
            // TODO: 抽象出拖拽类
            child: GestureDetector(
                onSecondaryTapDown: (details) => showContextMenu(
                    context, dirPath, true,
                    position: details.globalPosition),
                child: DragTarget(
                  onWillAcceptWithDetails: (details) {
                    if (details.data != null && details.data is String) {
                      return FileSystemEntity.typeSync(
                              details.data as String) !=
                          FileSystemEntityType.notFound;
                    }
                    return false;
                  },
                  onAcceptWithDetails: (details) async {
                    final dirController = Get.find<DirController>();
                    final targetDir = dirPath;
                    String soureParent =
                        await move2Directory(details.data as String, targetDir);
                    if (soureParent.isNotEmpty) {
                      dirController.fetchDirectory(path: soureParent);
                      dirController.fetchDirectory(path: targetDir);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    final blackColor = candidateData.isNotEmpty
                        ? Colors.white24
                        : Colors.transparent;
                    return Container(color: blackColor);
                  },
                ))),
      ]),
      floatingActionButton: CustomFAB(rootPath: dirPath),
    );
  }
}

Widget buildDirectoryList(BuildContext context, {required String path}) {
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

        return GetBuilder<DirController>(builder: (dirController) {
          final List<String> contents =
              dirController.folderContents[path] ?? []; // 获取当前路径的内容

          if (contents.isEmpty) {
            return GestureDetector(
                onSecondaryTapDown: (details) => showContextMenu(
                    context, path, true,
                    position: details.globalPosition),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
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
                ));
          }

          return Column(children: [
            ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final entityPath = contents[index];
                  final isFolder = FileSystemEntity.typeSync(entityPath) ==
                      FileSystemEntityType.directory;
                  final isCurPath =
                      dirController.currentPath.value == entityPath;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onSecondaryTapDown: (details) => showContextMenu(
                              context, entityPath, isFolder,
                              position: details.globalPosition),
                          child: DragTarget(onWillAcceptWithDetails: (details) {
                            if (details.data != null &&
                                details.data is String) {
                              return FileSystemEntity.typeSync(
                                      details.data as String) !=
                                  FileSystemEntityType.notFound;
                            }
                            return false;
                          }, onAcceptWithDetails: (details) async {
                            String targetDir;
                            if (isFolder) {
                              targetDir = Directory(entityPath).path;
                            } else {
                              targetDir = File(entityPath).parent.path;
                            }
                            String soureParent = await move2Directory(
                                details.data as String, targetDir);
                            if (soureParent.isNotEmpty) {
                              dirController.fetchDirectory(path: soureParent);
                              dirController.fetchDirectory(path: targetDir);
                            }
                          }, builder: (context, candidateData, rejectedData) {
                            final blackColor = candidateData.isNotEmpty
                                ? Colors.white24
                                : Colors.transparent;

                            return LongPressDraggable(
                                data: entityPath,
                                feedback: Container(
                                  color: Colors.white54,
                                  height: 30,
                                  child: Center(child: Text(entityPath)),
                                ),
                                child: ListTile(
                                    leading: Icon(
                                      isFolder
                                          ? (dirController.openFolders.contains(
                                                  entityPath) // 改用GetX状态
                                              ? IconsaxOutline.folder_open
                                              : IconsaxOutline.folder)
                                          : IconsaxOutline.task_square,
                                    ),
                                    tileColor: blackColor,
                                    title: Text(entityPath.split('/').last,
                                        style: TextStyle(
                                          color: isCurPath ? Colors.blue : null,
                                        )),
                                    onTap: () async {
                                      if (isFolder) {
                                        dirController.toggleFolder(entityPath);
                                        if (!dirController
                                            .hasFolder(entityPath)) {
                                          dirController.fetchDirectory(
                                              path: entityPath);
                                        }
                                      } else {
                                        logger.d("open file: $entityPath");
                                        // 通过MarkDownController更新,不更新UI, 只更新内容.
                                        Get.find<MarkDownController>()
                                            .setCurFilePath(entityPath);
                                        await Get.toNamed("/canvas");
                                      }
                                    }));
                          })),
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
                }),
          ]);
        });
      });
}
