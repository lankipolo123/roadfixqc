import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/image_proccessor_service.dart';
import 'package:roadfix/services/pothole_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/bounding_box.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/themes.dart';

class PotholeDetectionScreen extends StatefulWidget {
  final ImageSource? initialImageSource;
  final ReportCategory? category;

  const PotholeDetectionScreen({
    super.key,
    this.initialImageSource,
    this.category,
  });

  @override
  State<PotholeDetectionScreen> createState() => _PotholeDetectionScreenState();
}

class _PotholeDetectionScreenState extends State<PotholeDetectionScreen> {
  final DetectionService _detectionService = DetectionService();
  bool _isProcessing = false;

  File? _selectedImage;
  ui.Image? _decodedImage;
  List<DetectionResult> _detections = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
    if (widget.initialImageSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImageFromSource(widget.initialImageSource!);
      });
    }
  }

  Future<void> _loadModel() async {
    await _detectionService.loadModel();
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
    });

    LoadingModal.show(
      context,
      title: "Processing Image",
      description: "Detecting road issues, please wait...",
    );

    try {
      final detections = await _detectionService.detectObjects(imageFile);

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
          content: Text('No potholes detected. Please try another image.'),
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

    final detectionTags = detectionCounts.keys.toList();

    final descriptionParts = <String>[];
    descriptionParts.add('The Model has detected:');

    for (var entry in detectionCounts.entries) {
      descriptionParts.add(
        '- ${entry.value} ${entry.key}${entry.value > 1 ? 's' : ''}',
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
            reportType: widget.category?.label,
            detections: detectionTags,
            autoDescription: autoDescription,
          ),
        ),
      );
    }
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
                  categoryLabel: widget.category?.label,
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
