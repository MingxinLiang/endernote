import 'dart:math' show min;
import 'package:endernote/common/logger.dart';
import 'package:endernote/presentation/screens/chat2llm/dialog_llm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromptField extends StatelessWidget {
  final void Function(String text) onSend;
  final TextEditingController promptController;
  final FocusNode _focusNode = FocusNode();
  final istyping = Get.find<Dialog2LLMController>().isTyping;

  PromptField(
      {super.key, required this.onSend, required this.promptController});

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height;
    final double maxWidth = MediaQuery.of(context).size.width;
    logger.d("PromptField build: $maxHeight, $maxWidth");
    final txtStyle = TextStyle(
      color: Colors.black,
      fontSize: min(maxWidth * 0.04, 20),
    );

    final double hight = min(maxHeight * 0.15, 66);
    // 自动焦点
    _focusNode.requestFocus();

    sendPromt() {
      if (istyping.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            content: SizedBox(
                height: hight,
                child: Align(
                    alignment: Alignment.center,
                    child: Text("正在思考，说话不要太急。休息一下。",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: min(hight * 0.8, 20),
                        )))),
            duration: const Duration(seconds: 3),
          ),
        );
        //   title: "提示",
        //   message: "正在生成中，请稍后再试",
        //   maxWidth: maxWidth * 0.5,
        //   duration: const Duration(seconds: 3),
        //   margin: EdgeInsets.only(left: maxWidth * 0.2),
        // );
      } else {
        onSend(promptController.text.trim()); // 发送消息
        promptController.clear(); // 清空输入框
        _focusNode.requestFocus(); // 保有焦点
      }
    }

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.005),
      child: SizedBox(
        height: hight,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: maxHeight * 0.005),
          child: TextField(
            style: txtStyle,
            focusNode: _focusNode,
            cursorColor: Colors.lightBlue,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) {
              sendPromt();
            },
            maxLines: 1, // 允许多行输入
            controller: promptController,
            decoration: InputDecoration(
              // 中间的内容的padding
              contentPadding: EdgeInsets.symmetric(
                  horizontal: maxWidth * 0.02, vertical: maxHeight * 0.01),
              // 发送按钮
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: min(maxWidth * 0.01, 5),
                    vertical: min(maxHeight * 0.01, 5)),
                child: CircleAvatar(
                    radius: min(maxWidth * 0.03, 40), // 按钮大小
                    backgroundColor: Colors.lightBlue.shade200,
                    child: IconButton(
                        onPressed: sendPromt,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          size: min(maxWidth * 0.03, 30),
                          Icons.send,
                          color: Colors.white,
                        ))),
              ),
              hintText: "Write Prompt",
              hintStyle: TextStyle(
                  color: Colors.grey, fontSize: min(maxWidth * 0.04, 20)),
              filled: true,
              fillColor: Colors.blue.shade50,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(maxWidth * 0.1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(maxWidth * 0.1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(maxWidth * 0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
