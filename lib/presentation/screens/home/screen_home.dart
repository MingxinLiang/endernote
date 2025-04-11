import 'dart:io';

import 'package:endernote/controller/directory_controller.dart';
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endernote/common/logger.dart' show logger;

import '../../../bloc/directory/directory_bloc.dart';
import '../../../bloc/directory/directory_events.dart';
import '../../theme/app_themes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_fab.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final directoryController = Get.find<DirectoryController>();
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
    final directoryController = Get.find<DirectoryController>();
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
              onLongPress: () {
                _showContextMenu(context, entityPath, isFolder);
              },
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

  void _showContextMenu(
    BuildContext context,
    String entityPath,
    bool isFolder,
  ) {
    final menuItems = <PopupMenuEntry<String>>[
      const PopupMenuItem(
        value: 'rename',
        child: ListTile(
          leading: Icon(IconsaxOutline.edit_2),
          title: Text('Rename'),
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: ListTile(
          leading: Icon(IconsaxOutline.folder_cross),
          title: Text('Delete'),
        ),
      ),
    ];

    if (isFolder) {
      menuItems.addAll(
        [
          const PopupMenuItem(
            value: 'new_folder',
            child: ListTile(
              leading: Icon(IconsaxOutline.folder_open),
              title: Text('New Folder'),
            ),
          ),
          const PopupMenuItem(
            value: 'new_file',
            child: ListTile(
              leading: Icon(IconsaxOutline.add_square),
              title: Text('New File'),
            ),
          ),
        ],
      );
    }

    showMenu(
      color: Theme.of(context).extension<EndernoteColors>()?.clrBase,
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: menuItems,
    ).then((value) {
      if (value == 'rename') {
        _renameEntity(context, entityPath);
      } else if (value == 'delete') {
        _deleteEntity(context, entityPath, isFolder);
      } else if (value == 'new_folder') {
        _createNewFolder(context, entityPath);
      } else if (value == 'new_file') {
        _createNewFile(context, entityPath);
      }
    });
  }

  void _createNewFolder(BuildContext context, String entityPath) {
    final directoryController = Get.find<DirectoryController>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).extension<EndernoteColors>()?.clrBase,
        title: Text(
          'New Folder',
          style: TextStyle(
            color: Theme.of(context).extension<EndernoteColors>()?.clrText,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newFolderPath = '$entityPath/${controller.text.trim()}';
                Directory(newFolderPath).createSync();
                directoryController.fetchDirectory(entityPath); // 改用GetX
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createNewFile(BuildContext context, String entityPath) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).extension<EndernoteColors>()?.clrBase,
        title: Text(
          'New File',
          style: TextStyle(
            color: Theme.of(context).extension<EndernoteColors>()?.clrText,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'File name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                File('$entityPath/${controller.text.trim()}.md').createSync();
                context.read<DirectoryBloc>().add(FetchDirectory(entityPath));
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _renameEntity(BuildContext context, String entityPath) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).extension<EndernoteColors>()?.clrBase,
        title: Text(
          'Rename',
          style: TextStyle(
            color: Theme.of(context).extension<EndernoteColors>()?.clrText,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'New name for ${entityPath.split('/').last}',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final newPath =
                    '${Directory(entityPath).parent.path}/$newName.md';
                File(entityPath).renameSync(newPath);
                context
                    .read<DirectoryBloc>()
                    .add(FetchDirectory(Directory(entityPath).parent.path));
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteEntity(BuildContext context, String entityPath, bool isFolder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).extension<EndernoteColors>()?.clrBase,
        title: Text(
          'Delete',
          style: TextStyle(
            color: Theme.of(context).extension<EndernoteColors>()?.clrText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${entityPath.split('/').last}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isFolder) {
                Directory(entityPath).deleteSync(recursive: true);
              } else {
                File(entityPath).deleteSync();
              }
              context
                  .read<DirectoryBloc>()
                  .add(FetchDirectory(Directory(entityPath).parent.path));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
