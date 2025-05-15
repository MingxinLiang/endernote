import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xnote/common/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class DialogController extends GetxController {
  // 是否在等待结果
  final RxBool isTyping = false.obs;
  final FocusNode focusNode = FocusNode();

  late final ScrollController scrollController = ScrollController();
  late final promptController = TextEditingController();
  late final RxList data = [].obs;

  final Dio _dio = Dio();
  final _accessToken = dotenv.env['ACCESS_TOKEN'] ?? '';

  // 滚到最底部
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

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
        for (var item in response.data["choices"]) {
          data.add(
              {"content": item["message"]["content"], "role": "assistant"});
          update();
        }
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
      update();
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
    focusNode.requestFocus();
    logger.d('DialogController onInit');
  }
}

// 独立的 SlideController 类
class LLMController extends GetxController with GetTickerProviderStateMixin {
  // 对话框是否打开
  final RxBool isOpen = false.obs;

  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  //LLM Serve
  Animation<Offset> get animation => _offsetAnimation;

  @override
  void onInit() {
    super.onInit();
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

    Get.put(DialogController());
  }

  void toggleSlide() {
    if (_controller.isAnimating) {
      _controller.stop();
      logger.d("Animation stopped, is open: $isOpen");
    }
    if (_controller.isDismissed) {
      _controller.forward();
      isOpen.value = true;
      final focusNode = Get.find<DialogController>().focusNode;
      focusNode.requestFocus();
      logger.d('Animation started, is open: $isOpen');
    } else {
      _controller.reverse();
      isOpen.value = false;
      Get.find<DialogController>().promptController.clear();
      logger.d('Animation reversed, is open: $isOpen');
    }

    update();
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}
