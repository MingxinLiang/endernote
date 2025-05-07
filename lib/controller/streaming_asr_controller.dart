import 'dart:async' show StreamSubscription;

import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import "dart:io";
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:flutter/services.dart' show rootBundle;
import 'package:xnote/common/logger.dart' show logger;

Future<String> copyAssetFile(String src, [String? dst]) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  dst ??= basename(src);
  final target = join(directory.path, dst);
  bool exists = await File(target).exists();

  final data = await rootBundle.load(src);

  if (!exists || File(target).lengthSync() != data.lengthInBytes) {
    final List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(target).writeAsBytes(bytes);
  }

  return target;
}

Float32List convertBytesToFloat32(Uint8List bytes, [endian = Endian.little]) {
  final values = Float32List(bytes.length ~/ 2);
  final data = ByteData.view(bytes.buffer);

  for (var i = 0; i < bytes.length; i += 2) {
    int short = data.getInt16(i, endian);
    values[i ~/ 2] = short / 32678.0;
  }

  return values;
}

// 目前就支持一种配置
Future<sherpa_onnx.OnlineModelConfig> getOnlineModelConfig(
    {required int type}) async {
  final modelDir =
      'lib/assets/sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20';
  return sherpa_onnx.OnlineModelConfig(
    transducer: sherpa_onnx.OnlineTransducerModelConfig(
      encoder:
          await copyAssetFile('$modelDir/encoder-epoch-99-avg-1.int8.onnx'),
      decoder: await copyAssetFile('$modelDir/decoder-epoch-99-avg-1.onnx'),
      joiner: await copyAssetFile('$modelDir/joiner-epoch-99-avg-1.onnx'),
    ),
    tokens: await copyAssetFile('$modelDir/tokens.txt'),
    modelType: 'zipformer',
  );
}

Future<sherpa_onnx.OnlineRecognizer> createOnlineRecognizer() async {
  final type = 0;
  final modelConfig = await getOnlineModelConfig(type: type);
  final config = sherpa_onnx.OnlineRecognizerConfig(
    model: modelConfig,
    ruleFsts: '',
  );

  return sherpa_onnx.OnlineRecognizer(config);
}

class StreamingAsrController extends GetxController {
  final RxBool isInitialized = false.obs;
  final RxInt _cursorPosition = 0.obs;
  final Rx<RecordState> recordState = RecordState.stop.obs;
  final _recordTxt = "".obs;
  StreamSubscription<RecordState>? _recordSub;

  // TODO: 跟随光标输入,而不是末尾
  TextEditingController textController;
  StreamingAsrController({required this.textController});

  // 音频录制器
  late final AudioRecorder _audioRecorder;

  // 识别器
  sherpa_onnx.OnlineRecognizer? recognizer;
  sherpa_onnx.OnlineStream? stream;
  int sampleRate = 16000;

  void _updateRecordState(RecordState updateRecordState) {
    recordState.value = updateRecordState;
  }

  // 初始化状态
  @override
  onInit() async {
    _cursorPosition.value = textController.selection.baseOffset >= 0
        ? textController.selection.baseOffset
        : 0;
    super.onInit();
    logger.d('StreamingAsrController init');
  }

  // 关闭状态
  @override
  void onClose() {
    _recordSub?.cancel();
    _audioRecorder.dispose();
    stream?.free();
    recognizer?.free();
    super.onClose();
    logger.d("StreamingAsrController close");
  }

  Future<void> stopRecording() async {
    stream?.free();
    stream = recognizer?.createStream();
    await _audioRecorder.stop();
  }

  // 模型初始化
  initSherpa() async {
    if (isInitialized.value) {
      return;
    }

    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });
    sherpa_onnx.initBindings();
    recognizer = await createOnlineRecognizer();
    stream = recognizer?.createStream();
    isInitialized.value = true;
    logger.i("init recording");
  }

  Future<void> startRecording() async {
    if (!isInitialized.value) {
      await initSherpa();
    }

    // 识别开始时候的原始文本
    _recordTxt.value = textController.text;

    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.pcm16bits;

        if (!await _audioRecorder.isEncoderSupported(encoder)) {
          logger.d('Encoder not supported: $encoder');
          return;
        }

        final devs = await _audioRecorder.listInputDevices();
        if (devs.isEmpty) {
          logger.d('No input devices found');
          return;
        }

        logger.d(devs.toString());

        const config = RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          numChannels: 1,
        );

        final audioStream = await _audioRecorder.startStream(config);

        audioStream.listen((data) {
          final samples = convertBytesToFloat32(Uint8List.fromList(data));
          stream!.acceptWaveform(samples: samples, sampleRate: sampleRate);

          while (recognizer!.isReady(stream!)) {
            recognizer!.decode(stream!);
          }

          final text = recognizer!.getResult(stream!).text;
          updateTextDisplay(text);
        });
      } else {
        logger.e('Permission not granted.');
      }
    } catch (e) {
      logger.e(e);
    } finally {
      textController.text += "\n";
      _recordTxt.value = textController.text;
      _cursorPosition.value = textController.selection.baseOffset;
      recognizer?.reset(stream!);
      textController.selection = TextSelection.collapsed(
          offset: _cursorPosition.value, affinity: TextAffinity.downstream);
    }
  }

  void updateTextDisplay(String newText) {
    // 更新文本
    if (newText.isNotEmpty) {
      textController.text = "${_recordTxt.value}$newText";

      if (recognizer?.isEndpoint(stream!) ?? false) {
        // 结速一段输入,并换行
        textController.text += "\n";
        _recordTxt.value = textController.text;
        _cursorPosition.value = textController.selection.baseOffset;
        recognizer?.reset(stream!);
        textController.selection = TextSelection.collapsed(
            offset: _cursorPosition.value, affinity: TextAffinity.downstream);
      }
    }
  }
}
