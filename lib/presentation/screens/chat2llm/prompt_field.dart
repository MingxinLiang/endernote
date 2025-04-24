import 'package:endernote/common/logger.dart';
import 'package:flutter/material.dart';

class PromptField extends StatelessWidget {
  final Function()? onSend;
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
      fontSize: maxWidth * 0.04,
    );

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.005),
      child: SizedBox(
        height: maxHeight * 0.12,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: maxHeight * 0.005),
          child: TextField(
            style: txtStyle,
            cursorColor: Colors.lightBlue,
            autofocus: false,
            controller: promptController,
            decoration: InputDecoration(
              // 中间的内容
              contentPadding: EdgeInsets.symmetric(
                  horizontal: maxWidth * 0.03, vertical: maxHeight * 0.01),
              // 发送按钮
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: maxWidth * 0.01, vertical: maxHeight * 0.008),
                child: CircleAvatar(
                    radius: maxWidth * 0.03,
                    backgroundColor: Colors.lightBlue.shade200,
                    child: IconButton(
                        onPressed: onSend,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          size: maxWidth * 0.03,
                          Icons.send,
                          color: Colors.white,
                        ))),
              ),
              hintText: "Write Prompt",
              hintStyle:
                  TextStyle(color: Colors.grey, fontSize: maxWidth * 0.04),
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
