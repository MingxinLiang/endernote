import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
    const PopupMenuItem(
      value: 'export',
      child: ListTile(
        leading: Icon(IconsaxOutline.export_2),
        title: Text('export'),
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
        renameEntity(entityPath, isFolder);
        break;
      case 'delete':
        deleteEntity(entityPath, isFolder);
        break;
      case 'new_folder':
        createNewFolder(entityPath);
        break;
      case 'new_file':
        createNewFile(entityPath);
        break;
      case 'export':
        exportEntity(entityPath, isFolder);
        break;
    }
  });
}

void createNewFolder(String entityPath) {
  void imp(String value) {
    if (value.trim().isNotEmpty) {
      try {
        Directory(
          '$entityPath/${value.trim()}', // new folder path
        ).createSync();
        Get.find<DirController>().fetchDirectory(path: entityPath);
      } catch (e) {
        Get.snackbar('Error', 'Failed to create folder: $e');
      }
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

void createNewFile(String entityPath) {
  void imp(String name) {
    if (name.trim().isNotEmpty) {
      try {
        File(
          '$entityPath/${name.trim()}.md', // new file name
        ).createSync(recursive: true);
        Get.find<DirController>().fetchDirectory(path: entityPath);
      } catch (e) {
        Get.snackbar('Error', 'Failed to create file: $e');
      }
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

void renameEntity(
  String entityPath,
  bool isFolder,
) {
  void imp(String newName) {
    if (newName.trim().isNotEmpty) {
      try {
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
      } catch (e) {
        Get.snackbar('Error', 'Failed to rename entity: $e');
      }
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

void deleteEntity(String entityPath, bool isFolder) {
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
            try {
              if (isFolder) {
                Directory(entityPath).deleteSync(recursive: true);
              } else {
                File(entityPath).deleteSync();
              }
              Get.find<DirController>()
                  .fetchDirectory(path: Directory(entityPath).parent.path);
              Get.back();
            } catch (e) {
              Get.snackbar('Error', 'Failed to delete entity: $e');
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void exportEntity(String entityPath, bool isFolder) async {
  void imp() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    if (isFolder) {
      _copyDirectory(Directory(entityPath), Directory(selectedDirectory))
          .then((_) => Get.snackbar("Success", "Folder exported successfully!"))
          .catchError((e) => Get.snackbar("Fail", "$e"));
    } else {
      File(entityPath)
          .copy('$selectedDirectory/${entityPath.split('/').last}')
          .then((_) => Get.snackbar("Success", "File exported successfully!"))
          .catchError((e) => Get.snackbar("Fail", "$e"));
    }
  }

  imp();
}

Future<void> _copyDirectory(Directory source, Directory target) async {
  final targetDir = Directory("${target.path}/${source.path.split("/").last}");
  if (!await targetDir.exists()) {
    await targetDir.create();
  }

  final entities = source.listSync();
  for (var entity in entities) {
    if (entity is File) {
      final targetFile =
          File('${targetDir.path}/${entity.path.split('/').last}');
      await entity.copy(targetFile.path);
    } else if (entity is Directory) {
      final newTarget =
          Directory('${targetDir.path}/${entity.path.split('/').last}');
      await _copyDirectory(entity, newTarget);
    }
  }
}
