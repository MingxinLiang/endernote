import 'package:endernote/common/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 独立的 SlideController 类
class SlideController extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  Animation<Offset> get animation => _offsetAnimation;

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(
      vsync: this,
      // 将动画时长设置为 500 毫秒
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        logger.d('Animation completed');
      } else if (status == AnimationStatus.dismissed) {
        logger.d('Animation dismissed');
      }
    });
  }

  void toggleSlide() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    if (_controller.isDismissed) {
      _controller.forward();
      logger.d('Animation started');
    } else {
      _controller.reverse();
      logger.d('Animation reversed');
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}

class Dialog2LLM extends StatelessWidget {
  const Dialog2LLM({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('Dialog2LLM build');
    return GetBuilder<SlideController>(
      builder: (controller) {
        return SlideTransition(
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
        );
      },
    );
  }
}
