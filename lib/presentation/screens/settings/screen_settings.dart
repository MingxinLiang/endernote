import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_events.dart';
import '../../../bloc/theme/theme_states.dart';
import '../../theme/app_themes.dart';
import '../../widgets/custom_list_tile.dart';

var logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);

class ScreenSettings extends StatelessWidget {
  String rootPath;
  ScreenSettings({super.key, required this.rootPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(IconsaxOutline.arrow_left_2),
        ),
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) => CustomListTile(
                lead: IconsaxOutline.brush_3,
                title: 'Theme',
                subtitle: state.theme.toString().split('.').last,
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        ...AppTheme.values.map(
                          (theme) {
                            return ListTile(
                              title: Text(theme.toString().split('.').last),
                              trailing:
                                  context.read<ThemeBloc>().state.theme == theme
                                      ? const Icon(IconsaxOutline.tick_circle)
                                      : null,
                              onTap: () {
                                context
                                    .read<ThemeBloc>()
                                    .add(ChangeThemeEvent(theme));
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    content: Text(
                                      'Selected theme: ${theme.toString().split('.').last}.',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CustomListTile(
              lead: IconsaxOutline.book,
              title: 'Root Path',
              subtitle: rootPath,
              onTap: () async {
                String? selectedDirectory =
                    await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
                  rootPath = selectedDirectory;
                }
              },
            ), // PathSetting
            CustomListTile(
              lead: IconsaxOutline.book,
              title: 'About',
              subtitle: 'Crafted with care.',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }
}
