import 'dart:math' show min;
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final bool isUser;
  const MessageTile({super.key, required this.message, required this.isUser});
  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;
    final TextStyle textStyle = TextStyle(
        color: isUser ? Colors.white : Colors.black,
        fontSize: min(maxHeight * 0.03, 20));

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: min(maxWidth * 0.01, 12),
            vertical: min(maxHeight * 0.005, 12)),
        decoration: BoxDecoration(
            color: isUser ? Colors.lightBlue.shade200 : Colors.white60,
            borderRadius: BorderRadius.circular(12)),
        child: SelectableText(
          message,
          style: textStyle,
        ),
      ),
    );
  }
}
