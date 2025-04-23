import 'package:endernote/common/logger.dart';
import 'package:endernote/presentation/screens/chat2llm/message_tile.dart';
import 'package:endernote/presentation/screens/chat2llm/prompt_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' show Lottie;

// 独立的 SlideController 类
class Dialog2LLMController extends GetxController
    with GetTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final ScrollController scrollController = ScrollController();
  late final promptController = TextEditingController();
  late final RxList data = [].obs;
  late final RxBool isTyping = false.obs;

  Animation<Offset> get animation => _offsetAnimation;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  getResponse({required String prompt}) {
    logger.d('getResponse');
  }

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
  }

  void toggleSlide() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    if (_controller.isDismissed) {
      _controller.forward();
      logger.d('Animation started');
    } else {
      _controller.reverse();
      logger.d('Animation reversed');
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

    return SlideTransition(
        position: controller.animation,
        child: Container(
          width: maxWidth * 0.5,
          padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.03),
          decoration: BoxDecoration(
            // 修复 color 问题
            color: Colors.lightBlue.withAlpha(10),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(42),
              topRight: Radius.circular(42),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 使用 Expanded 让其在垂直方向填充可用空间
              Expanded(
                  child: Obx(
                () => controller.data.isEmpty
                    ? Center(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("lib/assets/icons/xiantuan1.png",
                              width: maxWidth * 0.3, fit: BoxFit.fill),
                          SizedBox(height: maxHeight * 0.03),
                          Center(
                            child: Text(
                              "你好， 我是线团， 一只集美貌和才华的女子，\n 哦不，狗子 \n 汪汪汪",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: maxWidth * 0.03,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ))
                    : ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.data.length,
                        itemBuilder: (context, index) {
                          if (controller.data.isNotEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: maxHeight * 0.02),
                              child: MessageTile(
                                message: controller.data[index]["text"],
                                isUser: controller.data[index]["isUser"],
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                      ),
              )),
              //controller.isTyping.value
              //    ? SizedBox(
              //        width: maxWidth * 0.18,
              //        child: Lottie.asset("assets/animations/typing.json",
              //            fit: BoxFit.fill))
              //    : const SizedBox()
              PromptField(
                promptController: controller.promptController,
                onSend: () async {
                  controller.scrollToBottom();
                  final text =
                      controller.promptController.text.toString().trim();
                  controller.promptController.clear();

                  if (text.isNotEmpty) {
                    controller.data.add({"text": text, "isUser": true});

                    await controller.getResponse(prompt: text);
                    controller.scrollToBottom();
                  }
                },
              ),
            ],
          ),
        ));
  }
}
