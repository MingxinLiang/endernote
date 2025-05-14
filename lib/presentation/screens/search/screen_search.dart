import 'dart:io';

import 'package:xnote/controller/dir_controller.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_themes.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/custom_app_bar.dart';

class ScreenSearch extends StatelessWidget {
  const ScreenSearch({
    super.key,
    required this.searchQuery,
    required this.rootPath,
  });

  final String searchQuery;
  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final dirController = Get.find<DirController>();
    return Scaffold(
      appBar: CustomAppBar(
        rootPath: rootPath,
        searchQuery: searchQuery,
        showBackButton: true,
      ),
      body: FutureBuilder(
        future: dirController.searchDirectory(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final searchResults = snapshot.data ?? [];

          if (searchResults.isEmpty) {
            return Center(
              child: Text(
                'No results found for "$searchQuery"',
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

          return ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final entityPath = searchResults[index];
              final isFolder = Directory(entityPath).existsSync();

              return Column(
                children: [
                  GestureDetector(
                    onLongPressStart: (details) => showContextMenu(
                      context,
                      entityPath,
                      isFolder,
                      position: details.globalPosition,
                    ),
                    onSecondaryTapDown: (details) => showContextMenu(
                        context, entityPath, isFolder,
                        position: details.globalPosition),
                    child: ListTile(
                      leading: Icon(
                        isFolder
                            ? (dirController.openFolders.contains(entityPath)
                                ? IconsaxOutline.folder_open
                                : IconsaxOutline.folder)
                            : IconsaxOutline.task_square,
                      ),
                      title: Text(entityPath.split('/').last),
                      subtitle: Text(
                        entityPath.replaceFirst(rootPath, ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .extension<XnoteColors>()
                              ?.clrText
                              .withAlpha(150),
                        ),
                      ),
                      onTap: () {
                        if (isFolder) {
                          dirController.toggleFolder(entityPath);
                          if (dirController.folderContents
                              .containsKey(entityPath)) {
                            dirController.fetchDirectory(path: entityPath);
                          }
                        } else {
                          Get.toNamed("/canvas", arguments: entityPath);
                        }
                      },
                    ),
                  ),
                  if (isFolder &&
                      dirController.openFolders.contains(entityPath))
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: _buildDirectoryList(
                          context, entityPath, dirController),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDirectoryList(
    BuildContext context,
    String path,
    DirController controller,
  ) {
    final contents = controller.folderContents[path] ?? [];

    if (path == rootPath && contents.isEmpty) {
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
                  context, entityPath, isFolder,
                  position: details.globalPosition),
              onSecondaryTapDown: (details) => showContextMenu(
                  context, entityPath, isFolder,
                  position: details.globalPosition),
              child: ListTile(
                leading: Icon(
                  isFolder
                      ? (controller.openFolders.contains(entityPath)
                          ? IconsaxOutline.folder_open
                          : IconsaxOutline.folder)
                      : IconsaxOutline.task_square,
                ),
                title: Text(entityPath.split('/').last),
                onTap: () {
                  if (isFolder) {
                    controller.toggleFolder(entityPath);
                    if (!controller.folderContents.containsKey(entityPath)) {
                      controller.fetchDirectory(path: entityPath);
                    }
                  } else {
                    Get.toNamed("/canvas", arguments: entityPath);
                  }
                },
              ),
            ),
            if (isFolder && controller.openFolders.contains(entityPath))
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildDirectoryList(context, entityPath, controller),
              ),
          ],
        );
      },
    );
  }
}
