// ThemeController 负责管理应用主题
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xnote/common/logger.dart' show logger;
import 'package:xnote/presentation/theme/app_themes.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // 用于持久化存储主题设置
  // 当前主题
  Rx<AppTheme> currentTheme = AppTheme.catppuccinMocha.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // 从存储中加载主题
  Future<void> _loadTheme({String? themeString}) async {
    try {
      final perfs = await SharedPreferences.getInstance();
      themeString = perfs.getString("app_theme");

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
  Future<void> updateTheme(AppTheme theme) async {
    if (currentTheme.value == theme) return;
    try {
      currentTheme.value = theme;
      final perfs = await SharedPreferences.getInstance();
      perfs.setString("app_theme", theme.toString().split('.').last);
      await _loadTheme();
      update();
      logger.d("Theme changed to: ${theme.toString().split('.').last}");
    } catch (e) {
      logger.e("Error changing theme: $e");
    }
  }
}
