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
import 'package:endernote/common/logger.dart' show logger;

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
  final RxString last = ''.obs;
  final RxInt index = 0.obs;
  final RxBool isInitialized = false.obs;
  final Rx<RecordState> recordState = RecordState.stop.obs;
  TextEditingController textController;
  StreamingAsrController({required this.textController});

  AudioRecorder audioRecorder = AudioRecorder();
  StreamSubscription<RecordState>? _recordSub;

  sherpa_onnx.OnlineRecognizer? recognizer;
  sherpa_onnx.OnlineStream? stream;
  int sampleRate = 16000;

  void _updateRecordState(RecordState updateRecordState) {
    recordState.value = updateRecordState;
  }

  // 初始化状态
  @override
  void onInit() {
    _recordSub = audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });
    super.onInit();
  }

  // 关闭状态
  @override
  void onClose() {
    _recordSub?.cancel();
    audioRecorder.dispose();
    stream?.free();
    recognizer?.free();
    super.onClose();
  }

  // 以下是原有_start()方法重构后的代码
  Future<void> startRecording() async {
    if (!isInitialized.value) {
      sherpa_onnx.initBindings();
      recognizer = await createOnlineRecognizer();
      stream = recognizer?.createStream();
      isInitialized.value = true;
      logger.i("init streaming asr.");
    }

    try {
      if (await audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.pcm16bits;

        if (!await audioRecorder.isEncoderSupported(encoder)) {
          logger.e('Encoder not supported: $encoder');
          return;
        }

        final devs = await audioRecorder.listInputDevices();
        logger.d(devs.toString());

        const config = RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          numChannels: 1,
        );

        final audioStream = await audioRecorder.startStream(config);

        audioStream.listen((data) {
          final samples = convertBytesToFloat32(Uint8List.fromList(data));

          stream!.acceptWaveform(samples: samples, sampleRate: sampleRate);

          while (recognizer!.isReady(stream!)) {
            recognizer!.decode(stream!);
          }

          final text = recognizer!.getResult(stream!).text;
          logger.i('Recognized text: $text');
          updateTextDisplay(text);
        });
      } else {
        logger.e('Permission not granted.');
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void updateTextDisplay(String newText) {
    String textToDisplay = last.value;
    if (newText.isNotEmpty) {
      textToDisplay = last.value.isEmpty
          ? '${index.value}: $newText'
          : '${index.value}: $newText\n${last.value}';
    }

    if (recognizer?.isEndpoint(stream!) ?? false) {
      recognizer?.reset(stream!);
      if (newText.isNotEmpty) {
        last.value = textToDisplay;
        index.value++;
      }
    }

    textController.text = textToDisplay;
    textController.selection =
        TextSelection.collapsed(offset: textToDisplay.length);
  }

  Future<void> stopRecording() async {
    stream?.free();
    stream = recognizer?.createStream();
    await audioRecorder.stop();
  }
}
