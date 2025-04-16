import 'dart:io';

import 'package:endernote/presentation/screens/canvas/edit_mode/functional_bar.dart';
import 'package:endernote/presentation/screens/canvas/edit_mode/streaming_asr_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_themes.dart';
import 'package:endernote/common/logger.dart' show logger;

class EditMode extends StatelessWidget {
  const EditMode({super.key, required this.entityPath});

  final String entityPath;

  Future<String> _loadFileContent() async {
    try {
      return await File(entityPath).readAsString();
    } catch (e) {
      return "Error reading file: $e";
    }
  }

  Future<void> _saveChanges(String content, String path) async {
    try {
      await File(path).writeAsString(content);
    } catch (e) {
      debugPrint("Error saving file: $e");
    }
  }

  // Handle key events for auto-continuation of lists.
  // Returns true if it handled the event.
  bool _handleKeyEvent(KeyEvent event, TextEditingController controller) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      final text = controller.text;
      final currentPosition = controller.selection.baseOffset;

      // Find the start of the current line
      int lineStart = text.lastIndexOf('\n', currentPosition - 1) + 1;
      if (lineStart < 0) lineStart = 0;

      // Get the current line up to the cursor
      final currentLine = text.substring(lineStart, currentPosition);

      // Check if line starts with list markers
      final bulletMatch = RegExp(r'^(\s*)- (.*)$').firstMatch(currentLine);
      final numberedMatch =
          RegExp(r'^(\s*)(\d+)\. (.*)$').firstMatch(currentLine);

      // If empty list item, remove marker.
      if (bulletMatch != null && bulletMatch.group(2)?.trim().isEmpty == true) {
        final whitespace = bulletMatch.group(1) ?? '';
        controller.text = text.replaceRange(
          lineStart,
          currentPosition,
          whitespace,
        );
        controller.selection = TextSelection.collapsed(
          offset: lineStart + whitespace.length,
        );
        return true;
      } else if (numberedMatch != null &&
          numberedMatch.group(3)?.trim().isEmpty == true) {
        final whitespace = numberedMatch.group(1) ?? '';
        controller.text = text.replaceRange(
          lineStart,
          currentPosition,
          whitespace,
        );
        controller.selection = TextSelection.collapsed(
          offset: lineStart + whitespace.length,
        );
        return true;
      }

      // Continue list if there's content
      if (bulletMatch != null) {
        _insertText(controller, '\n${bulletMatch.group(1) ?? ''}- ');
        return true;
      } else if (numberedMatch != null) {
        _insertText(
          controller,
          '\n${numberedMatch.group(1) ?? ''}${int.parse(numberedMatch.group(2) ?? '1') + 1}. ',
        );
        return true;
      }
    }
    return false;
  }

  void _insertText(TextEditingController controller, String text) {
    final currentPosition = controller.selection.baseOffset;

    if (currentPosition == -1) return;

    controller.text = controller.text.replaceRange(
      currentPosition,
      currentPosition,
      text,
    );

    // updated to new cursor position.
    controller.selection = TextSelection.collapsed(
      offset: (currentPosition + text.length).clamp(0, controller.text.length),
    );

    _saveChanges(controller.text, entityPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadFileContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final textController = TextEditingController(text: snapshot.data ?? "");
        final focusNode = FocusNode();
        final functionalBar =
            FunctionalBar(textController: textController, focusNode: focusNode);

        final asrButtom = StreamingAsrButtom(textEditingController: textController,);

        textController.addListener(() async {
          await _saveChanges(textController.text, entityPath);
        });

        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: functionalBar),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Focus(
                      autofocus: true,
                      onKeyEvent: (node, event) =>
                          _handleKeyEvent(event, textController)
                              ? KeyEventResult.handled
                              : KeyEventResult.ignored,
                      child: TextField(
                        controller: textController,
                        focusNode: focusNode,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        style: const TextStyle(fontFamily: 'FiraCode'),
                        decoration: InputDecoration(
                          floatingLabelStyle: TextStyle(
                            color: Theme.of(context)
                                .extension<EndernoteColors>()
                                ?.clrText,
                          ),
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .extension<EndernoteColors>()
                                ?.clrText,
                          ),
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                      child: asrButtom,
                    )),
              ],
            );
          },
        );
      },
    );
  }
}
