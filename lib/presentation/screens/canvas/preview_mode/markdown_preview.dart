import 'package:xnote/common/utils.dart' show getMarkDownWidgets;
import 'package:xnote/controller/markdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart' show Get, Inst;
import 'package:scroll_to_index/scroll_to_index.dart';

/// 自定义的 Markdown 组件，用于显示解析后的 Markdown 内容
class MarkdownWidget extends StatefulWidget {
  /// 设置 Markdown 列表项的滚动物理效果
  final ScrollPhysics? physics;

  /// 设置是否收缩 [ListView]（仅在 [tocController] 为 null 时可用）
  final bool shrinkWrap;

  /// [ListView] 的内边距
  final EdgeInsetsGeometry? padding;

  /// 设置文本是否可选择
  final bool selectable;

  const MarkdownWidget({
    super.key,
    this.physics,
    this.shrinkWrap = false,
    this.selectable = true,
    this.padding,
  });

  @override
  MarkdownWidgetState createState() => MarkdownWidgetState();
}

/// [MarkdownWidget] 的状态类
class MarkdownWidgetState extends State<MarkdownWidget> {
  /// [AutoScrollController] 提供滚动到指定索引的功能
  final AutoScrollController scrollController = AutoScrollController();

  /// 记录 [ListView] 的滚动方向是否为向前滚动
  bool isForward = true;
  late List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    updateState();
    // 获取 MarkDownController
    var markDownController = Get.find<MarkDownController>();
    markDownController.setScrollController(scrollController);
    markDownController.jumpScrollToIndex();
    _widgets = getMarkDownWidgets(markDownController.curNodes);
  }

  /// 当获取到新数据时，更新状态而不调用 setState() 以避免视图闪烁
  void updateState() {
    var markDownController = Get.find<MarkDownController>();
    _widgets = getMarkDownWidgets(markDownController.curNodes);
  }

  /// 在 [updateState] 或 [dispose] 时调用，清除状态
  void clearState() {
    // 清空 Widget 列表
    _widgets.clear();
  }

  @override
  void dispose() {
    // 清除状态
    clearState();
    // 释放滚动控制器
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildMarkdownWidget();

  /// 构建 Markdown 组件
  Widget buildMarkdownWidget() {
    final markdownWidget = NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        // 获取滚动方向
        final ScrollDirection direction = notification.direction;
        // 更新滚动方向标志
        isForward = direction == ScrollDirection.forward;
        return true;
      },
      child: ListView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        controller: scrollController,
        itemBuilder: (ctx, index) =>
            wrapByAutoScroll(index, _widgets[index], scrollController),
        itemCount: _widgets.length,
        padding: widget.padding,
      ),
    );
    // 根据是否可选择包装组件
    return widget.selectable
        ? SelectionArea(child: markdownWidget)
        : markdownWidget;
  }

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    // 清除旧状态
    clearState();
    // 更新新状态
    updateState();
    super.didUpdateWidget(widget);
  }
}

/// 使用 [AutoScrollTag] 包装 Widget，以便使用 [AutoScrollController] 滚动到指定索引
Widget wrapByAutoScroll(
    int index, Widget child, AutoScrollController controller) {
  return AutoScrollTag(
    key: Key(index.toString()),
    controller: controller,
    index: index,
    highlightColor: Colors.black.withValues(alpha: 10),
    child: child,
  );
}
