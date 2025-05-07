// ThemeController 负责管理应用主题
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/presentation/theme/app_themes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // 用于持久化存储主题设置
  final storage = const FlutterSecureStorage();
  // 当前主题
  Rx<AppTheme> currentTheme = AppTheme.catppuccinMocha.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // 从存储中加载主题
  Future<void> _loadTheme() async {
    try {
      final themeString = await storage.read(key: 'app_theme');
      if (themeString != null) {
        final theme = AppTheme.values.firstWhere(
          (element) => element.toString() == 'AppTheme.$themeString',
          orElse: () => AppTheme.catppuccinMocha,
        );
        currentTheme.value = theme;
      }
    } catch (e) {
      logger.e('Error loading theme: $e');
    }
  }

  // 更改主题并保存到存储
  Future<void> changeTheme(AppTheme theme) async {
    try {
      currentTheme.value = theme;
      await storage.write(
          key: 'app_theme', value: theme.toString().split('.').last);
      update();
    } catch (e) {
      logger.e("Error changing theme: $e");
    }
  }
}
