import 'package:xnote/controller/streaming_asr_controller.dart'
    show StreamingAsrController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

class StreamingAsrButtom extends StatelessWidget {
  const StreamingAsrButtom({super.key, required this.textEditingController});
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    final asrController =
        StreamingAsrController(textController: textEditingController);
    return _buildRecordStopControl(asrController);
  }

  Widget _buildRecordStopControl(StreamingAsrController controller) {
    return Obx(() {
      final isRecording = controller.recordState.value != RecordState.stop;
      final icon = isRecording
          ? Icon(Icons.stop, color: Colors.red, size: 50)
          : Icon(Icons.mic, color: Colors.lightBlue, size: 30);

      return ClipOval(
        child: Material(
          color: isRecording
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.lightBlue.withValues(alpha: 0.1),
          child: GestureDetector(
            onTap: () => controller.initSherpa(),
            onLongPressStart: (_) => controller.startRecording(),
            onLongPressEnd: (_) => controller.stopRecording(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isRecording ? 86 : 56,
              height: isRecording ? 86 : 56,
              child: icon,
            ),
          ),
        ),
      );
    });
  }
}
