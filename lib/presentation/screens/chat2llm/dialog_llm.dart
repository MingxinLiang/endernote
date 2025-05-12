import 'dart:math' show max;
import 'package:xnote/common/logger.dart';
import 'package:xnote/controller/llm_controller.dart';
import 'package:xnote/presentation/screens/chat2llm/message_tile.dart';
import 'package:xnote/presentation/screens/chat2llm/prompt_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialog2LLM extends StatelessWidget {
  const Dialog2LLM({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Dialog2LLM build');
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;
    logger.d("Dialog2LLM: $maxHeight, $maxWidth");
    final controller = Get.find<LLMController>();

    return SlideTransition(
        position: controller.animation,
        child: Overlay(initialEntries: [
          OverlayEntry(
              canSizeOverlay: true,
              maintainState: true,
              builder: (context) {
                logger.d("rebuild Dialog2LLM");
                return GetBuilder<DialogController>(
                    builder: (digController) => Container(
                        width: maxWidth * 0.4,
                        padding:
                            EdgeInsets.symmetric(horizontal: maxWidth * 0.03),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withAlpha(50), width: 5),
                          color: Colors.white.withAlpha(10),
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
                              child: digController.data.length <= 1
                                  ? Center(
                                      child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                            "lib/assets/icons/xiantuan1.png",
                                            width: maxWidth * 0.2,
                                            fit: BoxFit.fill),
                                        // SizedBox(height: maxHeight * 0.03),
                                        Center(
                                          child: Text(
                                            "你好， 我是线团， 一只集美貌和才华的女子，\n 哦不，狗子 \n 汪汪汪",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    max(maxWidth * 0.03, 20)),
                                          ),
                                        )
                                      ],
                                    ))
                                  : ListView.builder(
                                      controller:
                                          digController.scrollController,
                                      itemCount: digController.data.length,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return const SizedBox.shrink();
                                        }
                                        if (digController.data.isNotEmpty) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: maxHeight * 0.02),
                                            child: MessageTile(
                                              message: digController.data[index]
                                                  ["content"],
                                              isUser: digController.data[index]
                                                      ["role"] ==
                                                  "user",
                                            ),
                                          );
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                            ),
                            digController.isTyping.value
                                ? const Align(
                                    alignment: Alignment.centerLeft,
                                    child: CircularProgressIndicator(),
                                  )
                                : const SizedBox.shrink(),
                            PromptField(
                              promptController: digController.promptController,
                              onSend: digController.onSend,
                            ),
                          ],
                        )));
              })
        ]));
  }
}
