import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/camera_angle_service.dart'; // ✅ NEW
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/utils/detection_service_manager.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/camera_angle_indicator.dart';
import 'package:roadfix/widgets/detection_widgets/crop_overlay_area.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/utils/image_cropping_utility.dart';
import 'package:roadfix/utils/detection_merger_utility.dart';

enum DetectionType { pothole, roadblock, utilityPole }

/// ✅ RENAMED: This is specifically for DISTANCE detection (hybrid zoom detection)
/// Used for: Pothole distance detection with zoom/crop hybrid approach
class DistanceDetectionCameraScreen extends StatefulWidget {
  final ReportCategory? category;
  final DetectionType detectionType;

  const DistanceDetectionCameraScreen({
    super.key,
    required this.category,
    required this.detectionType,
  });

  @override
  State<DistanceDetectionCameraScreen> createState() =>
      _DistanceDetectionCameraScreenState();
}

class _DistanceDetectionCameraScreenState
    extends State<DistanceDetectionCameraScreen> {
  // ✅ CHANGED: Use service manager instead of direct service
  final DetectionServiceManager _serviceManager = DetectionServiceManager();
  dynamic _detectionService;
  CameraAngleService? _angleService;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  File? _capturedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];
  double? _captureAngle;
  bool _isZoomedView = false;
  bool get _requiresGyro => widget.detectionType == DetectionType.utilityPole;

  String get _detectionLabel {
    switch (widget.detectionType) {
      case DetectionType.pothole:
        return 'potholes';
      case DetectionType.roadblock:
        return 'roadblocks';
      case DetectionType.utilityPole:
        return 'utility poles';
    }
  }

  String get _instructionText {
    if (_requiresGyro) {
      return 'Hold your phone straight and capture the utility pole';
    }
    return 'Capture the road - distance detection will find far potholes';
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
    if (_requiresGyro) {
      _angleService = CameraAngleService();
      _angleService!.startListening();
    }
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _angleService?.dispose();
    // ✅ Manager handles service disposal
    super.dispose();
  }

  // ✅ CRITICAL: Load the correct service through the manager
  Future<void> _initializeServices() async {
    switch (widget.detectionType) {
      case DetectionType.pothole:
        _detectionService = await _serviceManager.getPotholeService();
        break;
      case DetectionType.roadblock:
        _detectionService = await _serviceManager.getRoadblocksService();
        break;
      case DetectionType.utilityPole:
        _detectionService = await _serviceManager.getUtilityPoleService();
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
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
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_detectionService == null) {
      debugPrint('⚠️ Detection service not loaded yet');
      return;
    }

    if (_requiresGyro && _angleService != null) {
      final angleValidation = _angleService!.validateForPoleDetection();

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
    }
    await _cameraController!.setZoomLevel(1.0);

    try {
      debugPrint(
        '🚀 ${_detectionLabel.toUpperCase()} DISTANCE DETECTION START (Hybrid Zoom)',
      );
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);
      final decodedImage = await _detectionService.decodeImage(file);
      if (!mounted) return;

      setState(() {
        _capturedImage = file;
        _decodedImage = decodedImage;
        _isProcessing = true;
        _detections.clear();
        _isZoomedView = false;
      });

      LoadingModal.show(
        context,
        title: "Processing Image",
        description: "Running distance detection (hybrid zoom)...",
      );

      // ✅ Step 1: Detect on full image
      debugPrint('📸 Step 1: Full image detection');
      final fullDetections = await _detectionService.detectObjects(file);
      debugPrint('   Found ${fullDetections.length} detections in full view');

      // ✅ Step 2: Crop and detect on road region (40% bottom)
      debugPrint('📸 Step 2: Cropping road region (40% bottom)');
      final croppedResult = await ImageCroppingUtility.cropRoadRegion(
        file,
        cropRatio: 0.4,
      );

      setState(() {}); // Update UI during processing

      debugPrint('📸 Step 3: Detecting on cropped region');
      final croppedDetections = await _detectionService.detectObjects(
        croppedResult.croppedFile,
      );
      debugPrint(
        '   Found ${croppedDetections.length} detections in cropped view',
      );

      // ✅ Step 4: Remap cropped detections back to full image coordinates
      debugPrint('🔄 Step 4: Remapping coordinates');
      final remappedDetections = ImageCroppingUtility.remapDetections(
        croppedDetections: croppedDetections,
        cropStartY: croppedResult.cropStartY,
        originalHeight: croppedResult.originalHeight,
        cropHeight: croppedResult.cropHeight,
      );

      final remappedResults = remappedDetections.map((rd) {
        return DetectionResult(
          className: rd.className,
          confidence: rd.confidence,
          centerX: rd.x + (rd.width / 2),
          centerY: rd.y + (rd.height / 2),
          width: rd.width,
          height: rd.height,
        );
      }).toList();

      // ✅ Step 5: Merge both detections using IoU threshold
      debugPrint('🔀 Step 5: Merging detections (IoU threshold: 0.5)');
      final mergedDetections = DetectionMergerUtility.mergeDetections(
        fullDetections: fullDetections,
        croppedDetections: remappedResults,
        iouThreshold: 0.5,
      );

      debugPrint('✅ Final: ${mergedDetections.length} merged detections');
      if (mergedDetections.isNotEmpty) {
        for (int i = 0; i < mergedDetections.length; i++) {
          final d = mergedDetections[i];
          debugPrint(
            '   #${i + 1}: ${d.className} - ${(d.confidence * 100).toStringAsFixed(1)}%',
          );
        }
      }

      // ✅ Cleanup temporary cropped file
      try {
        await croppedResult.croppedFile.delete();
        // ignore: empty_catches
      } catch (e) {}

      if (!mounted) return;

      setState(() {
        _detections = mergedDetections;
        _isProcessing = false;
      });

      LoadingModal.hide(context);
    } catch (e) {
      debugPrint('❌ Distance detection error: $e');
      if (!mounted) return;

      setState(() => _isProcessing = false);
      LoadingModal.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Detection error: $e"),
          backgroundColor: statusDanger,
        ),
      );
    }
  }

  Future<void> _confirmReport() async {
    if (!mounted) return;

    if (_detections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No $_detectionLabel detected. Please try another image.',
          ),
          backgroundColor: statusDanger,
          duration: const Duration(seconds: 3),
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

    final detectionTags = _formatDetectionTags(detectionCounts);

    final descriptionParts = <String>[];
    descriptionParts.add('The Model has detected (Distance Detection):');

    for (var entry in detectionCounts.entries) {
      final displayName = _formatDisplayName(entry.key);
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
            reportType: widget.category?.label ?? _detectionLabel,
            detections: detectionTags,
            autoDescription: autoDescription,
          ),
        ),
      );
    }
  }

  List<String> _formatDetectionTags(Map<String, int> detectionCounts) {
    return detectionCounts.keys.map((className) {
      return _formatDisplayName(className);
    }).toList();
  }

  String _formatDisplayName(String className) {
    switch (widget.detectionType) {
      case DetectionType.roadblock:
        switch (className) {
          case 'Fallen_Tree':
            return 'Fallen Tree';
          case 'Road_Barrier':
            return 'Road Barrier';
          case 'Tires':
            return 'Tires';
          case 'Traffic_Cones':
            return 'Traffic Cones';
          default:
            return className;
        }
      case DetectionType.utilityPole:
        return className == 'Broken_Pole' || className == 'Compromised-Pole'
            ? 'Compromised Utility Pole'
            : className;
      case DetectionType.pothole:
        return className;
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _decodedImage = null;
      _detections.clear();
      _captureAngle = null;
      _isZoomedView = false;
    });
  }

  void _toggleZoomView() {
    setState(() {
      _isZoomedView = !_isZoomedView;
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

        Positioned.fill(child: CustomPaint(painter: CameraGuideOverlay())),

        if (_requiresGyro && _angleService != null)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: CameraAngleIndicator(angleService: _angleService!),
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
                  color: _requiresGyro
                      ? (_angleService?.isPhoneStraight() ?? false
                            ? Colors.green
                            : Colors.red.withValues(alpha: 0.5))
                      : primary,
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
            child: Text(
              _instructionText,
              style: const TextStyle(color: inputFill, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionView() {
    final displayScale = _isZoomedView ? 2.0 : 1.0;

    return Stack(
      children: [
        if (_capturedImage != null && _decodedImage != null)
          Center(
            child: GestureDetector(
              onTap: _toggleZoomView,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AspectRatio(
                  aspectRatio: _decodedImage!.width / _decodedImage!.height,
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: displayScale,
                        child: Image.file(_capturedImage!, fit: BoxFit.contain),
                      ),
                      if (!_isProcessing)
                        Positioned.fill(
                          child: Transform.scale(
                            scale: displayScale,
                            child: CustomPaint(
                              painter: BoundingBoxPainter(
                                detections: _detections,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_capturedImage != null)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isZoomedView ? Icons.zoom_in : Icons.zoom_out,
                      color: primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isZoomedView
                          ? 'Viewing 2x zoom - Tap to see full image'
                          : 'Full view (1x) - Tap to zoom 2x',
                      style: const TextStyle(color: inputFill, fontSize: 12),
                    ),
                  ],
                ),
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
              categoryLabel: widget.category?.label ?? _detectionLabel,
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
