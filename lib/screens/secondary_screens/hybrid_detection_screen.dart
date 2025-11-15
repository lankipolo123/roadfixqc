import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/sequential_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

/// 🚀 SEQUENTIAL DETECTION SCREEN
/// Uses 3 specialized models
class HybridDetectionScreen extends StatefulWidget {
  final ImageSource? initialImageSource;
  final ReportCategory? category;

  const HybridDetectionScreen({
    super.key,
    this.initialImageSource,
    this.category,
  });

  @override
  State<HybridDetectionScreen> createState() => _HybridDetectionScreenState();
}

class _HybridDetectionScreenState extends State<HybridDetectionScreen> {
  final SequentialDetectionService _detectionService =
      SequentialDetectionService();
  bool _isProcessing = false;

  File? _selectedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndPickImage();
    });
  }

  @override
  void dispose() {
    _detectionService.dispose();
    super.dispose();
  }

  Future<void> _initializeAndPickImage() async {
    debugPrint('🔄 Initializing unified detection...');
    await _loadModels();

    if (widget.initialImageSource != null && mounted) {
      debugPrint('📸 Auto-picking image from ${widget.initialImageSource}');
      await _pickImageFromSource(widget.initialImageSource!);
    }
  }

  Future<void> _loadModels() async {
    if (!mounted) return;

    LoadingModal.show(
      context,
      title: "Loading AI Model",
      description:
          "Loading RoadFix unified model\nDetecting all road hazards...",
    );

    try {
      debugPrint('📥 Loading unified model...');
      await _detectionService.loadAllModels();
      debugPrint('✅ Model ready!');
    } catch (e) {
      debugPrint('❌ Failed to load models: $e');
      if (mounted) {
        LoadingModal.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load models: $e'),
            backgroundColor: statusDanger,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (mounted) {
      LoadingModal.hide(context);
      setState(() {});
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    if (!mounted) return;

    debugPrint('🎯 Calling ImagePicker with source: $source');
    final imageFile = await _detectionService.pickImageFromSource(source);

    if (imageFile == null) {
      debugPrint('❌ User cancelled image selection');
      if (mounted) Navigator.pop(context);
      return;
    }

    debugPrint('✅ Image selected: ${imageFile.path}');

    final decodedImage = await _detectionService.decodeImage(imageFile);
    if (!mounted) return;

    setState(() {
      _selectedImage = imageFile;
      _decodedImage = decodedImage;
      _isProcessing = true;
      _detections.clear();
    });

    LoadingModal.show(
      context,
      title: "Analyzing Image",
      description: "Running unified detection\nDetecting all road hazards...",
    );

    try {
      debugPrint('\n========================================');
      debugPrint('🚀 UNIFIED DETECTION');
      debugPrint('========================================');

      // 🎯 Run unified detection
      final detections = await _detectionService.detectAllHazards(
        imageFile,
        confidenceThreshold: 0.3,
      );

      debugPrint('\n📊 FINAL RESULTS:');
      debugPrint('   Total hazards detected: ${detections.length}');

      final Map<String, int> counts = {};
      for (var d in detections) {
        counts[d.className] = (counts[d.className] ?? 0) + 1;
      }

      if (detections.isEmpty) {
        debugPrint('   ⚠️ No hazards detected!');
      } else {
        debugPrint('\n   Breakdown:');
        for (var entry in counts.entries) {
          debugPrint('      - ${entry.key}: ${entry.value}');
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
        const SnackBar(
          content: Text('No hazards detected. Please try another image.'),
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
    descriptionParts.add('🤖 AI Detection Results:');
    descriptionParts.add('');

    for (var entry in detectionCounts.entries) {
      final displayName = _formatDisplayName(entry.key);
      descriptionParts.add(
        '• ${entry.value}x $displayName${entry.value > 1 ? 's' : ''}',
      );
    }

    descriptionParts.add('');
    descriptionParts.add('📊 Average confidence: $avgConfidence%');
    descriptionParts.add('🎯 Detected by RoadFix Unified Model');

    final autoDescription = descriptionParts.join('\n');

    if (processedImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReportScreen(
            imagePath: processedImagePath,
            reportType: widget.category?.label ?? 'Road Hazard',
            detections: detectionTags,
            autoDescription: autoDescription,
          ),
        ),
      );
    }
  }

  String _formatDisplayName(String className) {
    switch (className) {
      case 'Compromised-Pole':
        return 'Broken Utility Pole';
      case 'Fallen-Barrier':
        return 'Fallen Barrier';
      case 'Fallen-Cone':
        return 'Fallen Cone';
      case 'Pothole':
        return 'Pothole';
      case 'Road-Cracks':
      case 'Road_Crack':
        return 'Road Crack';
      case 'Road_Barrier':
        return 'Road Barrier';
      case 'Sewage-Manhole':
        return 'Sewage Manhole';
      case 'Stable':
        return 'Stable Object';
      case 'Tires':
        return 'Tire';
      case 'Tires_with_rim':
        return 'Tire with Rim';
      case 'Traffic_Cones':
        return 'Traffic Cone';
      default:
        return className.replaceAll('_', ' ').replaceAll('-', ' ');
    }
  }

  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _decodedImage = null;
      _detections.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: _selectedImage == null
            ? _buildEmptyState()
            : _buildDetectionView(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primary),
          SizedBox(height: 24),
          Text(
            'Preparing Detection...',
            style: TextStyle(
              color: inputFill,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Loading 3 specialized AI models',
              style: TextStyle(color: altSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionView() {
    return Stack(
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
                        painter: BoundingBoxPainter(detections: _detections),
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
              categoryLabel: 'Sequential (3 Models)',
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
