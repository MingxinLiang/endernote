import 'dart:io';

import 'package:xnote/controller/dir_controller.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_themes.dart';

const _dialogBackGroupColor = Colors.black54;
const _dialogTextColor = Colors.white54;

void showContextMenu(BuildContext context, String entityPath, bool isFolder,
    {required Offset position}) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final RelativeRect relatedPosition = RelativeRect.fromLTRB(
    position.dx,
    position.dy,
    overlay.size.width - position.dx,
    overlay.size.height - position.dy,
  );

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
    context: context,
    color: Theme.of(context).extension<XnoteColors>()?.clrBase,
    position: relatedPosition,
    items: menuItems,
  ).then((value) {
    switch (value) {
      case 'rename':
        _renameEntity(entityPath, isFolder);
        break;
      case 'delete':
        _deleteEntity(entityPath, isFolder);
        break;
      case 'new_folder':
        _createNewFolder(entityPath);
        break;
      case 'new_file':
        _createNewFile(entityPath);
        break;
    }
  });
}

void _createNewFolder(String entityPath) {
  void imp(String value) {
    if (value.trim().isNotEmpty) {
      Directory(
        '$entityPath/${value.trim()}', // new folder path
      ).createSync();
      Get.find<DirController>().fetchDirectory(path: entityPath);
    }
  }

  final controller = TextEditingController();
  Get.dialog(
    AlertDialog(
      backgroundColor: _dialogBackGroupColor,
      title: Text(
        'New Folder',
        style: TextStyle(
          color: _dialogTextColor,
        ),
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Folder name',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onSubmitted: (value) {
          imp(value);
          Get.back();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            imp(controller.text);
            Get.back();
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

void _createNewFile(String entityPath) {
  void imp(String name) {
    if (name.trim().isNotEmpty) {
      File(
        '$entityPath/${name.trim()}.md', // new file name
      ).createSync();
      Get.find<DirController>().fetchDirectory(path: entityPath);
    }
  }

  final controller = TextEditingController();
  Get.dialog(
    AlertDialog(
      backgroundColor: _dialogBackGroupColor,
      title: Text(
        'New File',
        style: TextStyle(
          color: _dialogTextColor,
        ),
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'File name',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onSubmitted: (value) {
          imp(value);
          Get.back();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            imp(controller.text);
            Get.back();
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

void _renameEntity(
  String entityPath,
  bool isFolder,
) {
  void imp(String newName) {
    if (newName.trim().isNotEmpty) {
      if (isFolder) {
        Directory(entityPath).renameSync(
          '${Directory(entityPath).parent.path}/${newName.trim()}', // updated folder name
        );
      } else {
        File(entityPath).renameSync(
          '${Directory(entityPath).parent.path}/${newName.trim()}.md', // updated file name
        );
      }
      Get.find<DirController>()
          .fetchDirectory(path: Directory(entityPath).parent.path);
    }
  }

  final controller = TextEditingController();
  // 对话
  Get.dialog(
    AlertDialog(
      backgroundColor: _dialogBackGroupColor,
      title: Text(
        'Rename',
        style: TextStyle(
          color: _dialogTextColor,
        ),
      ),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'New name for ${entityPath.split('/').last}',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        // 回车提交
        onSubmitted: (value) {
          imp(value);
          Get.back();
        },
      ),
      // 按钮操作
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            imp(controller.text);
            Get.back();
          },
          child: const Text('Rename'),
        ),
      ],
    ),
  );
}

void _deleteEntity(String entityPath, bool isFolder) {
  Get.dialog(
    AlertDialog(
      backgroundColor: _dialogBackGroupColor,
      title: Text(
        'Delete',
        style: TextStyle(
          color: _dialogTextColor,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${entityPath.split('/').last}"?',
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (isFolder) {
              Directory(entityPath).deleteSync(recursive: true);
            } else {
              File(entityPath).deleteSync();
            }
            Get.find<DirController>()
                .fetchDirectory(path: Directory(entityPath).parent.path);
            Get.back();
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
