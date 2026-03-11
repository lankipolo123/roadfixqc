import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/unified_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/image_source_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

/// Unified Detection Screen - Detects ALL hazards at once
class UnifiedDetectionScreen extends StatefulWidget {
  final ImageSource? initialImageSource;
  final ReportCategory? category;

  const UnifiedDetectionScreen({
    super.key,
    this.initialImageSource,
    this.category,
  });

  @override
  State<UnifiedDetectionScreen> createState() => _UnifiedDetectionScreenState();
}

class _UnifiedDetectionScreenState extends State<UnifiedDetectionScreen> {
  final UnifiedDetectionService _detectionService = UnifiedDetectionService();
  bool _isProcessing = false;

  File? _selectedImage;
  Uint8List? _annotatedImageBytes;
  List<DetectionResult> _detections = [];

  @override
  void initState() {
    super.initState();
    _initializeAndPickImage();
  }

  @override
  void dispose() {
    _detectionService.dispose();
    super.dispose();
  }

  Future<void> _initializeAndPickImage() async {
    await _detectionService.loadModel();

    if (widget.initialImageSource != null && mounted) {
      await _pickImageFromSource(widget.initialImageSource!);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final imageFile = await _detectionService.pickImageFromSource(source);

    if (imageFile == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedImage = imageFile;
      _annotatedImageBytes = null;
      _isProcessing = true;
      _detections.clear();

    });

    LoadingModal.show(
      context,
      title: "Analyzing Image",
      description: "Detecting ALL road hazards with unified AI model...",
    );

    try {
      final output = await _detectionService.detectObjects(
        imageFile,
        confidenceThreshold: 0.3,
      );

      if (!mounted) return;
      setState(() {
        _detections = output.detections;
        _annotatedImageBytes = output.annotatedImage;
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

    // Save annotated image (from YOLO) or fall back to original
    String? processedImagePath;
    if (_annotatedImageBytes != null) {
      processedImagePath =
          await UnifiedDetectionService.saveAnnotatedImage(_annotatedImageBytes!);
    }
    processedImagePath ??= _selectedImage!.path;

    if (!mounted) return;
    CompactLoadingModal.hide(context);

    // Build detection summary
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
    descriptionParts.add('AI Detection Results:');
    descriptionParts.add('');

    for (var entry in detectionCounts.entries) {
      final displayName = _formatDisplayName(entry.key);
      descriptionParts.add(
        '${entry.value}x $displayName${entry.value > 1 ? 's' : ''}',
      );
    }

    descriptionParts.add('');
    descriptionParts.add('Average confidence: $avgConfidence%');

    final autoDescription = descriptionParts.join('\n');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendReportScreen(
          imagePath: processedImagePath!,
          reportType: widget.category?.label ?? 'Road Hazard',
          detections: detectionTags,
          autoDescription: autoDescription,
        ),
      ),
    );
  }

  String _formatDisplayName(String className) {
    switch (className) {
      case 'Fallen_Tree':
        return 'Fallen Tree';
      case 'Road_Barrier':
        return 'Road Barrier';
      case 'Fallen_Cone':
        return 'Fallen Cone';
      case 'Fallen_Barrier':
        return 'Fallen Barrier';
      case 'Road_Crack':
        return 'Road Crack';
      case 'Broken_Pole':
      case 'Compromised-Pole':
        return 'Broken Utility Pole';
      case 'Pothole':
        return 'Pothole';
      case 'Traffic_Cones':
        return 'Traffic Cone';
      case 'Tires':
        return 'Tire';
      default:
        return className.replaceAll('_', ' ');
    }
  }

  Future<void> _showImageSourceDialog() async {
    final source = await ImageSourceDialog.show(context);
    if (source != null && mounted) {
      await _pickImageFromSource(source);
    }
  }

  void _retakePhoto() async {
    setState(() {
      _selectedImage = null;
      _annotatedImageBytes = null;
      _detections.clear();

    });
    await _showImageSourceDialog();
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 80, color: altSecondary),
          const SizedBox(height: 16),
          const Text(
            'No image selected',
            style: TextStyle(color: inputFill, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Select an image to detect all road hazards',
              style: TextStyle(color: altSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: inputFill,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionView() {
    // Show annotated image (with YOLO bounding boxes) if available, else original
    final Widget imageWidget = _annotatedImageBytes != null && !_isProcessing
        ? Image.memory(_annotatedImageBytes!, fit: BoxFit.contain)
        : Image.file(_selectedImage!, fit: BoxFit.contain);

    return Stack(
      children: [
        Center(child: imageWidget),

        if (!_isProcessing && _selectedImage != null)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: DetectionBottomCard(
              detections: _detections,
              categoryLabel: 'All Hazards',
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
