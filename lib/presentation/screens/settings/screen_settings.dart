import 'package:endernote/controller/directory_controller.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// 头部添加Get依赖
import 'package:get/get.dart'; // 新增导入
import '../../../controller/theme_controller.dart';
import '../../theme/app_themes.dart';
import '../../widgets/custom_list_tile.dart';
import '../../../common/logger.dart' show logger;

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key}); // 移除构造函数参数

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final dirController = Get.find<DirectoryController>(); // 获取目录控制器

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back, // 简写形式
          icon: const Icon(IconsaxOutline.arrow_left_2),
        ),
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Obx(() => CustomListTile(
                  // 使用响应式监听
                  lead: IconsaxOutline.brush_3,
                  title: 'Theme',
                  subtitle:
                      themeController.currentTheme.toString().split('.').last,
                  onTap: () => _showThemeSelector(context),
                )),
            CustomListTile(
              lead: IconsaxOutline.book,
              title: 'Root Path',
              subtitle: dirController.rootPath.value,
              onTap: () async {
                String? selectedDirectory =
                    await FilePicker.platform.getDirectoryPath();
                logger.i("select path: $selectedDirectory");
                if (selectedDirectory != null) {
                  dirController.updateRootPath(selectedDirectory); // 使用控制器方法
                }
              },
            ), // PathSetting
            CustomListTile(
              lead: IconsaxOutline.book,
              title: 'About',
              subtitle: 'Crafted with care.',
              onTap: () => Get.toNamed('/about'), // 改为GetX导航
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        alignment: Alignment.center,
        child: Obx(() => ListView(
              // 响应式更新选中状态
              children: [
                const SizedBox(height: 20),
                ...AppTheme.values.map((theme) => ListTile(
                      title: Text(theme.toString().split('.').last),
                      trailing: themeController.currentTheme == theme
                          ? const Icon(IconsaxOutline.tick_circle)
                          : null,
                      onTap: () {
                        themeController.changeTheme(theme);
                        Get.back();
                        Get.snackbar(
                          'Theme Changed',
                          'Selected theme: ${theme.toString().split('.').last}',
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          colorText: Theme.of(context).colorScheme.onSurface,
                        );
                      },
                    )),
              ],
            )),
      ),
    );
  }
}
