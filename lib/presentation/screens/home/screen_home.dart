import 'dart:io';

import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/directory/directory_bloc.dart';
import '../../../bloc/directory/directory_events.dart';
import '../../../bloc/directory/directory_states.dart';
import '../../theme/endernote_theme.dart';
import '../../widgets/custom_fab.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DirectoryBloc()..add(FetchDirectory(rootPath)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Endernote")),
        body: BlocBuilder<DirectoryBloc, DirectoryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            return _buildDirectoryList(context, rootPath, state);
          },
        ),
        floatingActionButton: CustomFAB(rootPath: rootPath),
      ),
    );
  }

  Widget _buildDirectoryList(
    BuildContext context,
    String path,
    DirectoryState state,
  ) {
    final contents = state.folderContents[path] ?? [];

    if (contents.isEmpty) {
      return const Center(
        child: Text(
          "This folder is feeling lonely.",
          style: TextStyle(fontSize: 16),
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
                      ? (state.openFolders.contains(entityPath)
                          ? IconsaxOutline.folder_open
                          : IconsaxOutline.folder)
                      : IconsaxOutline.task_square,
                ),
                title: Text(entityPath.split('/').last),
                onTap: () {
                  if (isFolder) {
                    context.read<DirectoryBloc>().add(ToggleFolder(entityPath));
                    if (!state.folderContents.containsKey(entityPath)) {
                      context
                          .read<DirectoryBloc>()
                          .add(FetchDirectory(entityPath));
                    }
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/canvas',
                      arguments: entityPath,
                    );
                  }
                },
              ),
            ),
            if (isFolder && state.openFolders.contains(entityPath))
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildDirectoryList(context, entityPath, state),
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
    showMenu(
      color: clrBase,
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
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
      ],
    ).then((value) {
      if (value == 'rename') {
        _renameEntity(context, entityPath);
      } else if (value == 'delete') {
        _deleteEntity(context, entityPath, isFolder);
      }
    });
  }

  void _renameEntity(BuildContext context, String entityPath) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: clrBase,
        title: const Text('Rename', style: TextStyle(color: clrText)),
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

  void _deleteEntity(
    BuildContext context,
    String entityPath,
    bool isFolder,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: clrBase,
        title: const Text('Delete', style: TextStyle(color: clrText)),
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
