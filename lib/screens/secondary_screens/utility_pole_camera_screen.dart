import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/camera_angle_service.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/utility_pole_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/camera_angle_indicator.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

class UtilityPoleCameraScreen extends StatefulWidget {
  final ReportCategory? category;

  const UtilityPoleCameraScreen({super.key, this.category});

  @override
  State<UtilityPoleCameraScreen> createState() =>
      _UtilityPoleCameraScreenState();
}

class _UtilityPoleCameraScreenState extends State<UtilityPoleCameraScreen> {
  final UtilityPoleDetectionService _detectionService =
      UtilityPoleDetectionService();
  final CameraAngleService _angleService = CameraAngleService();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  File? _capturedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];
  double? _captureAngle;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _angleService.startListening();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _angleService.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    await _detectionService.loadModel();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final angleValidation = _angleService.validateForPoleDetection();

    if (!angleValidation.isValid) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(angleValidation.message),
          backgroundColor: statusDanger,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    _captureAngle = angleValidation.tiltAngle;

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);

      final decodedImage = await _detectionService.decodeImage(file);

      if (!mounted) return;

      setState(() {
        _capturedImage = file;
        _decodedImage = decodedImage;
        _isProcessing = true;
        _detections.clear();
      });

      LoadingModal.show(
        context,
        title: "Processing Image",
        description: "Detecting utility poles, please wait...",
      );

      final detections = await _detectionService.detectObjects(file);

      if (!mounted) return;

      setState(() {
        _detections = detections;
        _isProcessing = false;
      });

      LoadingModal.hide(context);
    } catch (e) {
      debugPrint('Capture/Detection failed: $e');
      if (!mounted) return;

      setState(() => _isProcessing = false);
      LoadingModal.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: statusDanger),
      );
    }
  }

  Future<void> _confirmReport() async {
    if (!mounted) return;

    if (_detections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No broken poles detected. Please try another image.'),
          backgroundColor: statusDanger,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    CompactLoadingModal.show(context, message: "Preparing report...");

    final processedImagePath = await ImageProcessorService.createProcessedImage(
      _capturedImage!,
      _decodedImage!,
      _detections,
    );

    if (!mounted) return;
    CompactLoadingModal.hide(context);

    final Map<String, int> detectionCounts = {};
    double totalConfidence = 0;

    for (var detection in _detections) {
      detectionCounts[detection.className] =
          (detectionCounts[detection.className] ?? 0) + 1;
      totalConfidence += detection.confidence;
    }

    final avgConfidence = (totalConfidence / _detections.length * 100)
        .toStringAsFixed(1);

    final detectionTags = detectionCounts.keys.map((className) {
      return className == 'Broken_Pole'
          ? 'Broken Utility Pole (Meralco)'
          : className;
    }).toList();

    final descriptionParts = <String>[];
    descriptionParts.add('The Model has detected:');

    for (var entry in detectionCounts.entries) {
      final displayName = entry.key == 'Broken_Pole'
          ? 'Broken Utility Pole (Meralco)'
          : entry.key;
      descriptionParts.add(
        '- ${entry.value} $displayName${entry.value > 1 ? 's' : ''}',
      );
    }

    descriptionParts.add('\nAverage confidence: $avgConfidence%');

    if (_captureAngle != null) {
      descriptionParts.add(
        'Camera angle: ${_captureAngle!.toStringAsFixed(1)}° from vertical',
      );
    }

    final autoDescription = descriptionParts.join('\n');

    if (processedImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReportScreen(
            imagePath: processedImagePath,
            reportType: widget.category?.label ?? 'Utility Pole',
            detections: detectionTags,
            autoDescription: autoDescription,
          ),
        ),
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _decodedImage = null;
      _detections.clear();
      _captureAngle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: _capturedImage == null
            ? _buildCameraView()
            : _buildDetectionView(),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_cameraController!)),

        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: CameraAngleIndicator(angleService: _angleService),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _captureAndDetect,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _angleService.isPhoneStraight()
                      ? Colors.green
                      : Colors.red.withValues(alpha: 0.5),
                  border: Border.all(color: inputFill, width: 4),
                ),
                child: const Icon(Icons.camera_alt, color: inputFill, size: 32),
              ),
            ),
          ),
        ),

        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: secondary.withValues(alpha: 0.7),
            ),
            icon: const Icon(Icons.arrow_back, color: inputFill),
          ),
        ),

        Positioned(
          bottom: 140,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Hold your phone straight and capture the utility pole',
              style: TextStyle(color: inputFill, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionView() {
    return Stack(
      children: [
        if (_capturedImage != null && _decodedImage != null)
          Center(
            child: AspectRatio(
              aspectRatio: _decodedImage!.width / _decodedImage!.height,
              child: Stack(
                children: [
                  Image.file(_capturedImage!, fit: BoxFit.contain),
                  if (!_isProcessing)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BoundingBoxPainter(detections: _detections),
                      ),
                    ),
                ],
              ),
            ),
          ),

        if (!_isProcessing && _capturedImage != null)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: DetectionBottomCard(
              detections: _detections,
              categoryLabel: widget.category?.label ?? 'Utility Pole',
              onConfirm: _confirmReport,
              onCancel: _retakePhoto,
            ),
          ),

        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: secondary.withValues(alpha: 0.7),
            ),
            icon: const Icon(Icons.arrow_back, color: inputFill),
          ),
        ),
      ],
    );
  }
}
