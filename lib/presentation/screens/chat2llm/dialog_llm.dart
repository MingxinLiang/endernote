import 'dart:math' show max;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:endernote/common/logger.dart';
import 'package:endernote/presentation/screens/chat2llm/message_tile.dart';
import 'package:endernote/presentation/screens/chat2llm/prompt_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

// 独立的 SlideController 类
class Dialog2LLMController extends GetxController
    with GetTickerProviderStateMixin {
  // 对话框是否打开
  final RxBool isOpen = false.obs;
  // 是否在等待结果
  final RxBool isTyping = false.obs;

  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final ScrollController scrollController = ScrollController();
  late final promptController = TextEditingController();
  late final RxList data = [].obs;

  //LLM Serve
  final Dio _dio = Dio();
  Animation<Offset> get animation => _offsetAnimation;

  // 滚到最底部
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  final _accessToken = dotenv.env['ACCESS_TOKEN'] ?? '';
  // 获取结果
  // TODO:
  // 1. 增加错误处理
  // 2. 流式接口
  getResponse({required String prompt}) async {
    logger.d('prompt:$prompt, getResponse...');
    isTyping.value = true;
    logger.d(data);
    try {
      final response = await _dio.post('',
          data: {
            "model": "ernie-4.5-turbo-32k",
            "max_completion_tokens": 500,
            "messages": data.toList(),
            "web_search": {
              "enable": false,
              "enable_citation": false,
              "enable_trace": false,
            }
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "appid": "",
              "Authorization": _accessToken,
            },
          ));
      logger.d('response:$response');
      if (response.statusCode != null && response.statusCode! >= 200) {
        // TODO: 多输入检测
        data.add({
          "content": response.data["choices"][0]["message"]["content"],
          "role": "assistant"
        });
      } else {
        logger.e('Request failed with status code: ${response.statusCode}');
        logger.e(response.toString());
      }
    } catch (e) {
      logger.e('Error: $e');
    } finally {
      isTyping.value = false;
    }
  }

  onSend(String text) async {
    scrollToBottom();
    if (text.isNotEmpty) {
      data.add({"content": text, "role": "user"});
      await getResponse(prompt: text);
      scrollToBottom();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _dio.options.baseUrl = "https://qianfan.baidubce.com/v2/chat/completions";
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    data.add({
      "role": "user",
      "content": "#角色任务扮演一个叫线团的全能助手，尽可能简单的回答问题，主要任务助手辅助主人完成他想做的事。",
    });

    // 动画设置
    _controller = AnimationController(
      vsync: this,
      // 将动画时长设置为 500 毫秒
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        logger.d('Animation completed');
      } else if (status == AnimationStatus.dismissed) {
        logger.d('Animation dismissed');
      }
    });
  }

  void toggleSlide() {
    if (_controller.isAnimating) {
      _controller.stop();
      logger.d("Animation stopped, is open: $isOpen");
    }
    if (_controller.isDismissed) {
      _controller.forward();
      isOpen.value = true;
      logger.d('Animation started, is open: $isOpen');
    } else {
      _controller.reverse();
      isOpen.value = false;
      promptController.clear();
      logger.d('Animation reversed, is open: $isOpen');
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}

class Dialog2LLM extends StatelessWidget {
  Dialog2LLM({super.key});
  final controller = Get.find<Dialog2LLMController>();

  @override
  Widget build(BuildContext context) {
    logger.d('Dialog2LLM build');
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;
    logger.d("Dialog2LLM: $maxHeight, $maxWidth");

    return SlideTransition(
        position: controller.animation,
        child: Overlay(initialEntries: [
          OverlayEntry(
              canSizeOverlay: true,
              maintainState: true,
              builder: (context) => Container(
                  width: maxWidth * 0.4,
                  padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.03),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 5),
                    color: Colors.lightBlue.withAlpha(0),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 使用 Expanded 让其在垂直方向填充可用空间
                      Expanded(
                          child: Obx(
                        () => controller.data.length <= 1
                            ? Center(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset("lib/assets/icons/xiantuan1.png",
                                      width: maxWidth * 0.2, fit: BoxFit.fill),
                                  // SizedBox(height: maxHeight * 0.03),
                                  Center(
                                    child: Text(
                                      "你好， 我是线团， 一只集美貌和才华的女子，\n 哦不，狗子 \n 汪汪汪",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: max(maxWidth * 0.03, 20)),
                                    ),
                                  )
                                ],
                              ))
                            : ListView.builder(
                                controller: controller.scrollController,
                                itemCount: controller.data.length,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  if (controller.data.isNotEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: maxHeight * 0.02),
                                      child: MessageTile(
                                        message: controller.data[index]
                                            ["content"],
                                        isUser: controller.data[index]
                                                ["role"] ==
                                            "user",
                                      ),
                                    );
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                      )),
                      Obx(() => controller.isTyping.value
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox.shrink()),
                      PromptField(
                        promptController: controller.promptController,
                        onSend: controller.onSend,
                      ),
                    ],
                  )))
        ]));
  }
}
