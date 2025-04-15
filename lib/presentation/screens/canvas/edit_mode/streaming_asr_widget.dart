import 'package:endernote/controller/streaming_asr_controller.dart'
    show StreamingAsrController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamingAsrScreen extends StatelessWidget {
  const StreamingAsrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StreamingAsrController());
    return _buildRecordStopControl(controller);
  }

  Widget _buildRecordStopControl(StreamingAsrController controller) {
    return Obx(() {
      final isRecording = controller.recordState.value != RecordState.stop;
      final icon = isRecording
          ? Icon(Icons.stop, color: Colors.red, size: 30)
          : Icon(Icons.mic, color: Colors.black, size: 30);

      return ClipOval(
        child: Material(
          color: isRecording
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          child: InkWell(
            child: SizedBox(width: 56, height: 56, child: icon),
            onTap: () => isRecording
                ? controller.stopRecording()
                : controller.startRecording(),
          ),
        ),
      );
    });
  }
}
