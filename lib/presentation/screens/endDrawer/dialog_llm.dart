import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 优化控制器类，添加动画状态监听和更健壮的逻辑
class SlideController extends GetxController with GetTickerProviderStateMixin {
  // 定义动画控制器
  late final AnimationController _controller;
  // 定义偏移动画
  late final Animation<Offset> _offsetAnimation;

  // 提供只读的动画属性
  Animation<Offset> get animation => _offsetAnimation;

  // 初始化方法
  @override
  void onInit() {
    super.onInit();
    // 初始化动画控制器，设置动画时长和 vsync
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener(_handleAnimationStatus); // 添加动画状态监听器

    // 定义偏移动画的起始和结束位置，并应用曲线
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  // 处理动画状态变化的方法
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // 动画完成时的逻辑
      debugPrint('Animation completed');
    } else if (status == AnimationStatus.dismissed) {
      // 动画回到初始状态时的逻辑
      debugPrint('Animation dismissed');
    }
  }

  // 切换动画方向的方法
  void toggleSlide() {
    if (_controller.isAnimating) {
      // 如果动画正在进行，先停止动画
      _controller.stop();
    }
    // 根据当前状态反向播放动画
    _controller.isDismissed ? _controller.forward() : _controller.reverse();
  }

  // 销毁方法，释放动画控制器资源
  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}

// 优化组件类，添加错误处理和更好的用户反馈
class Dialog2LLM extends StatelessWidget {
  const Dialog2LLM({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SlideController>(
      init: SlideController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            try {
              // 尝试调用切换动画方法
              controller.toggleSlide();
            } catch (e) {
              // 捕获异常并输出错误信息
              debugPrint('Error toggling slide animation: $e');
            }
          },
          child: SlideTransition(
            position: controller.animation,
            child: Container(
              color: Colors.blue,
              width: 300,
              child: const Center(
                child: Text(
                  '汪汪汪',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
