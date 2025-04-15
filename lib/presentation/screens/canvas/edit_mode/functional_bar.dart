import 'package:endernote/common/logger.dart' show logger;
import 'package:endernote/presentation/theme/app_themes.dart';
import 'package:flutter/material.dart';

class FunctionalBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;

  const FunctionalBar({
    super.key,
    required this.textController,
    required this.focusNode,
  });

  // 原有工具按钮方法
  Widget floatingToolbarButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    TextEditingController textController,
    FocusNode focusNode,
    String prefix, [
    String? suffix,
  ]) =>
      IconButton(
        onPressed: () => _insertFormatting(
          textController,
          focusNode,
          prefix,
          suffix ?? '',
        ),
        icon: Icon(
          icon,
          color: Theme.of(context).extension<EndernoteColors>()?.clrText,
        ),
        tooltip: tooltip,
      );

  void _insertFormatting(
      TextEditingController controller, FocusNode focusNode, String prefix,
      [String suffix = '']) {
    final text = controller.text;
    var selection = controller.selection;

    if (selection.start == -1) {
      selection = TextSelection.collapsed(offset: 0);
    }

    // If text is selected, wrap it with formatting
    if (selection.start != selection.end) {
      logger.i(
          "selection.start: ${selection.start}, selection.end: ${selection.end}");
      controller.text = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix${text.substring(selection.start, selection.end)}$suffix',
      );

      // Position cursor after the formatted text
      controller.selection = TextSelection.collapsed(
        offset: selection.end + prefix.length + suffix.length,
      );
    } else {
      logger.i(
          "selection.start: ${selection.start}, selection.end: ${selection.end}");
      // If no text selected, insert the formatting and place cursor between prefix and suffix
      controller.text = text.replaceRange(
        selection.start,
        selection.start,
        '$prefix$suffix',
      );

      // Position cursor between prefix and suffix
      controller.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
    }

    // Save changes to file
    // _saveChanges(controller.text, entityPath);

    // Ensure the text field keeps focus
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          floatingToolbarButton(
            context,
            Icons.format_bold,
            'Bold',
            textController,
            focusNode,
            '**',
            '**',
          ),
          floatingToolbarButton(
            context,
            Icons.format_italic,
            'Italic',
            textController,
            focusNode,
            '*',
            '*',
          ),
          floatingToolbarButton(
            context,
            Icons.format_underline,
            'Underline',
            textController,
            focusNode,
            '__',
            '__',
          ),
          floatingToolbarButton(
            context,
            Icons.strikethrough_s,
            'Strikethrough',
            textController,
            focusNode,
            '~~',
            '~~',
          ),
          floatingToolbarButton(
            context,
            Icons.format_list_bulleted,
            'Bullet List',
            textController,
            focusNode,
            '- ',
          ),
          floatingToolbarButton(
            context,
            Icons.format_list_numbered,
            'Numbered List',
            textController,
            focusNode,
            '1. ',
          ),
          floatingToolbarButton(
            context,
            Icons.code,
            'Code Block',
            textController,
            focusNode,
            '```\n',
            '\n```',
          ),
          floatingToolbarButton(
            context,
            Icons.link,
            'Link',
            textController,
            focusNode,
            '[',
            '](url)',
          ),
          floatingToolbarButton(
            context,
            Icons.image,
            'Image',
            textController,
            focusNode,
            '![alt text](',
            ')',
          ),
          floatingToolbarButton(
            context,
            Icons.format_quote,
            'Quote',
            textController,
            focusNode,
            '> ',
          ),
          floatingToolbarButton(
            context,
            Icons.horizontal_rule,
            'Horizontal Rule',
            textController,
            focusNode,
            '\n---\n',
          ),
        ],
      ),
    );
  }
}
