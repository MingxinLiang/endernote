import 'package:xnote/presentation/screens/search/screen_search.dart'
    show buildSearchBar;
import 'package:xnote/presentation/theme/app_themes.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String rootPath;
  final bool showBackButton;
  final bool showRightButton;

  const CustomAppBar({
    super.key,
    required this.rootPath,
    this.showBackButton = false,
    this.showRightButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).extension<XnoteColors>()?.clrbackground,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            buildSearchBar(
                rootPath: rootPath,
                showBackButton: showBackButton,
                showRightButton: showRightButton),
            IconButton(
              onPressed: () {
                Get.toNamed("./settings");
              },
              tooltip: 'Settings',
              icon: Icon(
                IconsaxOutline.setting_2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
