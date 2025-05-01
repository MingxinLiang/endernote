import 'package:endernote/common/logger.dart' show logger;
import 'package:endernote/common/utils.dart';
import 'package:flutter/material.dart';
import "package:get/get.dart";

const defaultTocTextStyle = TextStyle(fontSize: 16);
const defaultCurrentTocTextStyle = TextStyle(fontSize: 16, color: Colors.blue);

class TocWidget extends StatelessWidget {
  final List<ToI> listToI;
  final textEditController;
  final currentIndex = 0.obs;

  /// use [tocTextStyle] to set the style of the toc item
  final TextStyle tocTextStyle = defaultTocTextStyle;
  final TextStyle currentTocTextStyle = defaultCurrentTocTextStyle;

  TocWidget(
      {super.key, required this.listToI, required this.textEditController});

  itermBuilder(ToI toi, isCurrent) {
    final child = ListTile(
      title: Container(
        margin: EdgeInsets.only(left: 20.0 * toi.headLevel),
        child: Text(toi.text,
            style: isCurrent ? currentTocTextStyle : tocTextStyle),
      ),
      onTap: () {
        currentIndex.value = toi.widgetIndex;
        logger.d(toi.text);
      },
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final currentToc = listToI[index];
        bool isCurrentToc = index == currentIndex;
        final itemBuilder = itermBuilder;
        return itemBuilder.call(currentToc, isCurrentToc);
      },
      itemCount: listToI.length,
    );
  }
}
