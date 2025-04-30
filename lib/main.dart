import 'package:endernote/controller/dir_controller.dart';
import 'package:endernote/controller/theme_controller.dart';
import 'package:endernote/presentation/screens/chat2llm/dialog_llm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:get/get.dart';
import 'presentation/screens/about/screen_about.dart';
import 'presentation/screens/canvas/screen_canvas.dart';
import 'presentation/screens/hello/screen_hello.dart';
import 'presentation/screens/list/screen_note_list.dart';
import 'presentation/screens/search/screen_search.dart';
import 'presentation/screens/settings/screen_settings.dart';
import 'presentation/theme/app_themes.dart';

import '../../../common/logger.dart' show logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 加载环境变量
  await dotenv.load(fileName: "lib/assets/.evn");
  // 根据配置初始化controller
  await Get.put(DirController()).fetchRootPath();
  Get.put(ThemeController());
  Get.put(Dialog2LLMController());
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
          page: () => ScreenHello(
            rootPath: Get.find<DirController>().rootPath.value,
          ),
        ),
        GetPage(
          name: '/canvas',
          page: () => ScreenCanvas(),
        ),
        GetPage(
          name: '/noteList',
          page: () => ScreenNoteList(
            rootPath: Get.find<DirController>().rootPath.value,
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
        return Scaffold(
          drawer: Drawer(
            child: SizedBox(
              width: 100,
            ),
          ),
          body: Obx(() {
            return Row(children: [
              Expanded(child: child!),
              Visibility(
                visible: llmController.isOpen.value,
                child: Dialog2LLM(),
              )
            ]);
          }),
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
        );
      },
    );
  }
}
