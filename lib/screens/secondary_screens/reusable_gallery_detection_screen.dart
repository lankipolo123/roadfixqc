import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/pothole_detection_service.dart';
import 'package:roadfix/services/road_blocks_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

/// Detection type enum (reuse from camera screen)
enum GalleryDetectionType { pothole, roadblock }

/// Reusable gallery screen for pothole and roadblock detection
class ReusableGalleryDetectionScreen extends StatefulWidget {
  final ImageSource initialImageSource;
  final ReportCategory? category;
  final GalleryDetectionType detectionType;

  const ReusableGalleryDetectionScreen({
    super.key,
    required this.initialImageSource,
    required this.category,
    required this.detectionType,
  });

  @override
  State<ReusableGalleryDetectionScreen> createState() =>
      _ReusableGalleryDetectionScreenState();
}

class _ReusableGalleryDetectionScreenState
    extends State<ReusableGalleryDetectionScreen> {
  // Services
  dynamic _detectionService;
  bool _isProcessing = false;
  bool _isZoomedView = false; // ✅ Toggle zoom view

  File? _selectedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];

  // Configuration based on detection type
  String get _detectionLabel {
    switch (widget.detectionType) {
      case GalleryDetectionType.pothole:
        return 'potholes';
      case GalleryDetectionType.roadblock:
        return 'roadblocks';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadModel();

    // Auto-pick image after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImageFromSource(widget.initialImageSource);
    });
  }

  @override
  void dispose() {
    _detectionService?.dispose();
    super.dispose();
  }

  void _initializeServices() {
    switch (widget.detectionType) {
      case GalleryDetectionType.pothole:
        _detectionService = PotholeDetectionService();
        break;
      case GalleryDetectionType.roadblock:
        _detectionService = RoadblocksDetectionService();
        break;
    }
  }

  Future<void> _loadModel() async {
    await _detectionService?.loadModel();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final imageFile = await _detectionService.pickImageFromSource(source);
    if (imageFile == null) return;

    final decodedImage = await _detectionService.decodeImage(imageFile);
    if (!mounted) return;

    setState(() {
      _selectedImage = imageFile;
      _decodedImage = decodedImage;
      _isProcessing = true;
      _detections.clear();
      _isZoomedView = false;
    });

    LoadingModal.show(
      context,
      title: "Processing Image",
      description: "Detecting $_detectionLabel, please wait...",
    );

    try {
      debugPrint('\n========================================');
      debugPrint(
        '🚀 ${_detectionLabel.toUpperCase()} DETECTION START (GALLERY)',
      );
      debugPrint('========================================');

      final detections = await _detectionService.detectObjects(imageFile);

      debugPrint('\n📊 DETECTION RESULTS:');
      debugPrint('   Total detections: ${detections.length}');

      if (detections.isEmpty) {
        debugPrint('   ⚠️  No $_detectionLabel detected!');
      } else {
        for (int i = 0; i < detections.length; i++) {
          final d = detections[i];
          debugPrint('\n   Detection #${i + 1}:');
          debugPrint('      Class: "${d.className}"');
          debugPrint(
            '      Confidence: ${(d.confidence * 100).toStringAsFixed(1)}%',
          );
        }
      }
      debugPrint('========================================\n');

      if (!mounted) return;
      setState(() {
        _detections = detections;
        _isProcessing = false;
      });

      LoadingModal.hide(context);
    } catch (e) {
      debugPrint('❌ Detection failed: $e');
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

    final detectionTags = _formatDetectionTags(detectionCounts);

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
      case GalleryDetectionType.roadblock:
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
      case GalleryDetectionType.pothole:
        return className;
    }
  }

  // ✅ Toggle between zoomed (2x) and normal (1x) view
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
        child: Stack(
          children: [
            if (_selectedImage != null && _decodedImage != null)
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
                            scale: _isZoomedView ? 2.0 : 1.0,
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (!_isProcessing)
                            Positioned.fill(
                              child: Transform.scale(
                                scale: _isZoomedView ? 2.0 : 1.0,
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

            // ✅ Zoom toggle indicator
            if (_selectedImage != null && !_isProcessing)
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
                          style: const TextStyle(
                            color: inputFill,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                  categoryLabel: widget.category?.label ?? _detectionLabel,
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
