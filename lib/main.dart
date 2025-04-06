import 'dart:io';

import 'package:endernote/controller/directory_controller.dart';
import 'package:endernote/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/about/screen_about.dart';
import 'presentation/screens/canvas/screen_canvas.dart';
import 'presentation/screens/hero/screen_hero.dart';
import 'presentation/screens/home/screen_home.dart';
import 'presentation/screens/search/screen_search.dart';
import 'presentation/screens/settings/screen_settings.dart';
import 'presentation/theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 DirectoryController
  final directoryController = Get.put(DirectoryController());
  // 初始化 ThemeController
  final themeController = Get.put(ThemeController());
  await directoryController.fetchRootPath();
  runApp(MyApp());
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
              rootPath: Get.find<DirectoryController>().rootPath.value),
        ),
        GetPage(
          name: '/canvas',
          page: () => ScreenCanvas(),
        ),
        GetPage(
          name: '/home',
          page: () => ScreenHome(
              rootPath: Get.find<DirectoryController>().rootPath.value),
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
              print('Missing required arguments for /search route');
              return Container();
            }
          },
        ),
      ],
      // 根据当前主题获取对应的 ThemeData
      theme: appThemeData[Get.find<ThemeController>().currentTheme.value],
    );
  }
}
