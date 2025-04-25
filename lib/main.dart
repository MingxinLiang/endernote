import 'package:endernote/controller/directory_controller.dart';
import 'package:endernote/controller/theme_controller.dart';
import 'package:endernote/presentation/screens/chat2llm/dialog_llm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/about/screen_about.dart';
import 'presentation/screens/canvas/screen_canvas.dart';
import 'presentation/screens/hero/screen_hero.dart';
import 'presentation/screens/home/screen_home.dart';
import 'presentation/screens/search/screen_search.dart';
import 'presentation/screens/settings/screen_settings.dart';
import 'presentation/theme/app_themes.dart';

import '../../../common/logger.dart' show logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 DirectoryController
  final directoryController = Get.put(DirectoryController());
  // 初始化 ThemeController
  // ignore: unused_local_variable
  final themeController = Get.put(ThemeController());
  Get.put(Dialog2LLMController());
  await directoryController.fetchRootPath();
  runApp(MyApp());
}

// 自定义组件，用于包裹页面并添加全局按钮
class RightCenterFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        scaffoldGeometry.minInsets.right;
    final double y = (scaffoldGeometry.scaffoldSize.height -
            scaffoldGeometry.floatingActionButtonSize.height) /
        2;
    return Offset(x, y);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Endernote',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // 使用 GetX 的路由配置方式
      getPages: [
        GetPage(
          name: '/',
          page: () => ScreenHero(
            rootPath: Get.find<DirectoryController>().rootPath.value,
          ),
        ),
        GetPage(
          name: '/canvas',
          page: () => ScreenCanvas(),
        ),
        GetPage(
          name: '/home',
          page: () => ScreenHome(
            rootPath: Get.find<DirectoryController>().rootPath.value,
          ),
        ),
        GetPage(
          name: '/settings',
          page: () => ScreenSettings(),
        ),
        GetPage(
          name: '/about',
          page: () => const ScreenAbout(),
        ),
        GetPage(
          name: '/search',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            if (args != null &&
                args.containsKey('query') &&
                args.containsKey('rootPath')) {
              return ScreenSearch(
                searchQuery: args['query'],
                rootPath: args['rootPath'],
              );
            } else {
              // 处理参数缺失的情况
              logger.w('Missing required arguments for /search route');
              return Container();
            }
          },
        ),
      ],
      // 根据当前主题获取对应的 ThemeData
      theme: appThemeData[Get.find<ThemeController>().currentTheme.value],
      // 使用 builder 参数包裹所有页面
      builder: (context, child) {
        final llmController = Get.find<Dialog2LLMController>();
        return Overlay(initialEntries: [
          OverlayEntry(
              builder: (context) => Scaffold(
                    body: Row(
                      children: [
                        Expanded(child: child!),
                        Obx(() => llmController.isOpen.value
                            ? Dialog2LLM()
                            : SizedBox.shrink()),
                      ],
                    ),
                    floatingActionButtonLocation:
                        RightCenterFloatingActionButtonLocation(),
                    floatingActionButton: FloatingActionButton.large(
                      onPressed: () {
                        try {
                          llmController.toggleSlide();
                          logger.d("控制器实例获取成功");
                        } catch (e) {
                          logger.d('获取控制器实例失败: $e');
                        }
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Obx(() => llmController.isOpen.value
                          ? Image.asset("lib/assets/icons/xiantuan2.png")
                          : Image.asset("lib/assets/icons/xiantuan1.png")),
                    ),
                  ))
        ]);
      },
    );
  }
}
