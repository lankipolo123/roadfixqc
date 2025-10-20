import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/road_blocks_detection_service.dart';
import 'package:roadfix/utils/detection_service_manager.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

class RoadblockDetectionScreen extends StatefulWidget {
  final ImageSource? initialImageSource;
  final ReportCategory? category;

  const RoadblockDetectionScreen({
    super.key,
    this.initialImageSource,
    this.category,
  });

  @override
  State<RoadblockDetectionScreen> createState() =>
      _RoadblockDetectionScreenState();
}

class _RoadblockDetectionScreenState extends State<RoadblockDetectionScreen> {
  final DetectionServiceManager _serviceManager = DetectionServiceManager();
  RoadblocksDetectionService? _detectionService;
  bool _isProcessing = false;

  File? _selectedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];

  @override
  void initState() {
    super.initState();
    _initializeAndPickImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ✅ FIX: Load model THEN pick image
  Future<void> _initializeAndPickImage() async {
    debugPrint('🔄 Initializing roadblock detection...');

    // Wait for model to load
    await _loadModel();

    // Then pick image if source was provided
    if (widget.initialImageSource != null && mounted) {
      debugPrint('📸 Auto-picking image from ${widget.initialImageSource}');
      await _pickImageFromSource(widget.initialImageSource!);
    }
  }

  Future<void> _loadModel() async {
    debugPrint('📥 Loading roadblock model...');
    _detectionService = await _serviceManager.getRoadblocksService();
    debugPrint('✅ Roadblock model ready!');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    if (_detectionService == null) {
      debugPrint('⚠️ Service not loaded yet - this should not happen!');
      return;
    }

    debugPrint('🎯 Calling ImagePicker with source: $source');
    final imageFile = await _detectionService!.pickImageFromSource(source);

    if (imageFile == null) {
      debugPrint('❌ User cancelled image selection');
      // ✅ FIX: Don't pop! Just stay on empty screen so user can try again
      return;
    }

    debugPrint('✅ Image selected: ${imageFile.path}');

    final decodedImage = await _detectionService!.decodeImage(imageFile);
    if (!mounted) return;

    setState(() {
      _selectedImage = imageFile;
      _decodedImage = decodedImage;
      _isProcessing = true;
      _detections.clear();
    });

    LoadingModal.show(
      context,
      title: "Processing Image",
      description: "Detecting roadblocks, please wait...",
    );

    try {
      final detections = await _detectionService!.detectObjects(imageFile);

      if (!mounted) return;
      setState(() {
        _detections = detections;
        _isProcessing = false;
      });

      LoadingModal.hide(context);
    } catch (e) {
      debugPrint('Detection failed: $e');
      if (!mounted) return;

      setState(() => _isProcessing = false);
      LoadingModal.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Detection failed: $e"),
          backgroundColor: statusDanger,
        ),
      );
    }
  }

  Future<void> _confirmReport() async {
    if (!mounted) return;

    if (_detections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No roadblocks detected. Please try another image.'),
          backgroundColor: statusDanger,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    CompactLoadingModal.show(context, message: "Preparing report...");

    final processedImagePath = await ImageProcessorService.createProcessedImage(
      _selectedImage!,
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
      return _formatDisplayName(className);
    }).toList();

    final descriptionParts = <String>[];
    descriptionParts.add('The Model has detected:');

    for (var entry in detectionCounts.entries) {
      final displayName = _formatDisplayName(entry.key);
      descriptionParts.add(
        '- ${entry.value} $displayName${entry.value > 1 ? 's' : ''}',
      );
    }

    descriptionParts.add('\nAverage confidence: $avgConfidence%');

    final autoDescription = descriptionParts.join('\n');

    if (processedImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReportScreen(
            imagePath: processedImagePath,
            reportType: widget.category?.label ?? 'Roadblock',
            detections: detectionTags,
            autoDescription: autoDescription,
          ),
        ),
      );
    }
  }

  String _formatDisplayName(String className) {
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
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading while model loads
    if (_detectionService == null) {
      return const Scaffold(
        backgroundColor: secondary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primary),
              SizedBox(height: 16),
              Text(
                'Loading detection model...',
                style: TextStyle(color: inputFill, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: Stack(
          children: [
            if (_selectedImage != null && _decodedImage != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _decodedImage!.width / _decodedImage!.height,
                  child: Stack(
                    children: [
                      Image.file(_selectedImage!, fit: BoxFit.contain),
                      if (!_isProcessing)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              detections: _detections,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            if (!_isProcessing && _selectedImage != null)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: DetectionBottomCard(
                  detections: _detections,
                  categoryLabel: widget.category?.label ?? 'Roadblock',
                  onConfirm: _confirmReport,
                  onCancel: () => Navigator.pop(context),
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
        ),
      ),
    );
  }
}
