import 'dart:math' show min;

import 'package:endernote/common/logger.dart';
import 'package:flutter/material.dart';

class PromptField extends StatelessWidget {
  final void Function(String text) onSend;
  final TextEditingController promptController;

  const PromptField(
      {super.key, required this.onSend, required this.promptController});

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;
    logger.d("PromptField build: $maxHeight, $maxWidth");
    final txtStyle = TextStyle(
      color: Colors.black,
      fontSize: min(maxWidth * 0.04, 20),
    );

    final double hight = min(maxHeight * 0.15, 66);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.005),
      child: SizedBox(
        height: hight,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: maxHeight * 0.005),
          child: TextField(
            style: txtStyle,
            cursorColor: Colors.lightBlue,
            autofocus: false,
            textInputAction: TextInputAction.send,
            onSubmitted: (text) {
              onSend(text.trim()); // 发送消息
              promptController.clear(); // 清空输入框
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
                        onPressed: () => {
                              onSend(promptController.text.trim()),
                              promptController.clear()
                            },
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
