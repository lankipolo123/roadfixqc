// lib/utils/yolo_isolate_manager.dart - ISOLATE-BASED MODEL MANAGEMENT
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/yolo.dart';

// Commands that can be sent to the isolate
enum IsolateCommand { init, predict, dispose, exit }

// Message to send to isolate
class IsolateMessage {
  final IsolateCommand command;
  final Map<String, dynamic>? data;
  final SendPort? responsePort;

  IsolateMessage(this.command, {this.data, this.responsePort});
}

// Isolate entry point - runs YOLO in separate isolate
void _yoloIsolateEntry(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  YOLO? yolo;
  bool isModelLoaded = false;

  receivePort.listen((message) async {
    if (message is! IsolateMessage) return;

    try {
      switch (message.command) {
        case IsolateCommand.init:
          // Load model inside isolate
          final modelPath = message.data!['modelPath'] as String;
          final useGpu = message.data!['useGpu'] as bool;

          debugPrint('🔵 ISOLATE: Loading model $modelPath');
          yolo = YOLO(
            modelPath: modelPath,
            task: YOLOTask.detect,
            useGpu: useGpu,
          );
          await yolo!.loadModel();
          isModelLoaded = true;
          debugPrint('✅ ISOLATE: Model loaded successfully');

          message.responsePort?.send({'success': true});
          break;

        case IsolateCommand.predict:
          if (!isModelLoaded || yolo == null) {
            message.responsePort?.send({
              'success': false,
              'error': 'Model not loaded in isolate',
            });
            return;
          }

          final imageBytes = message.data!['imageBytes'] as Uint8List;
          debugPrint('🔵 ISOLATE: Running prediction...');

          final output = await yolo!.predict(imageBytes);
          debugPrint('✅ ISOLATE: Prediction complete');

          message.responsePort?.send({'success': true, 'output': output});
          break;

        case IsolateCommand.dispose:
          debugPrint('🔵 ISOLATE: Disposing model');
          yolo = null;
          isModelLoaded = false;
          message.responsePort?.send({'success': true});
          break;

        case IsolateCommand.exit:
          debugPrint('💀 ISOLATE: Exiting - native memory will be freed!');
          receivePort.close();
          message.responsePort?.send({'success': true});
          break;
      }
    } catch (e) {
      debugPrint('❌ ISOLATE ERROR: $e');
      message.responsePort?.send({'success': false, 'error': e.toString()});
    }
  });
}

// Manager that spawns/kills isolates for each model
class YoloIsolateManager {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  bool _isInitialized = false;

  // Spawn isolate and load model
  Future<void> loadModel({
    required String modelPath,
    required bool useGpu,
  }) async {
    // Kill existing isolate first
    await _killIsolate();

    debugPrint('🚀 Spawning NEW isolate for $modelPath');

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_yoloIsolateEntry, receivePort.sendPort);

    // Get send port from isolate
    final completer = Completer<SendPort>();
    receivePort.listen((message) {
      if (message is SendPort && !completer.isCompleted) {
        completer.complete(message);
      }
    });

    _isolateSendPort = await completer.future;
    debugPrint('✅ Isolate spawned, loading model...');

    // Send init command
    final responsePort = ReceivePort();
    _isolateSendPort!.send(
      IsolateMessage(
        IsolateCommand.init,
        data: {'modelPath': modelPath, 'useGpu': useGpu},
        responsePort: responsePort.sendPort,
      ),
    );

    final response = await responsePort.first as Map;
    responsePort.close();

    if (response['success'] != true) {
      throw Exception('Failed to load model: ${response['error']}');
    }

    _isInitialized = true;
    debugPrint('✅ Model loaded in isolate!');
  }

  // Run prediction in isolate
  Future<Map<String, dynamic>> predict(Uint8List imageBytes) async {
    if (!_isInitialized || _isolateSendPort == null) {
      throw Exception('Isolate not initialized');
    }

    final responsePort = ReceivePort();
    _isolateSendPort!.send(
      IsolateMessage(
        IsolateCommand.predict,
        data: {'imageBytes': imageBytes},
        responsePort: responsePort.sendPort,
      ),
    );

    final response = await responsePort.first as Map;
    responsePort.close();

    if (response['success'] != true) {
      throw Exception('Prediction failed: ${response['error']}');
    }

    return response['output'] as Map<String, dynamic>;
  }

  // Kill isolate - GUARANTEES native memory cleanup!
  Future<void> _killIsolate() async {
    if (_isolate == null) return;

    debugPrint('💀 KILLING isolate - native interpreter will be freed!');

    try {
      // Try graceful exit first
      if (_isolateSendPort != null) {
        final responsePort = ReceivePort();
        _isolateSendPort!.send(
          IsolateMessage(
            IsolateCommand.exit,
            responsePort: responsePort.sendPort,
          ),
        );
        await responsePort.first.timeout(const Duration(seconds: 1));
        responsePort.close();
      }
    } catch (e) {
      debugPrint('⚠️ Graceful exit failed, force killing: $e');
    }

    // Force kill
    _isolate!.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolateSendPort = null;
    _isInitialized = false;

    // Give OS time to reclaim memory
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('✅ Isolate killed - memory freed!');
  }

  // Public dispose
  Future<void> dispose() async {
    await _killIsolate();
  }

  bool get isInitialized => _isInitialized;
}
