import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/unified_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/location_required_dialog.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/models/location_models.dart';
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
  List<DetectionResult> _detections = [];
  double? _imageAspectRatio;

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

    if (!mounted) return;

    if (widget.initialImageSource != null) {
      await _pickImageFromSource(widget.initialImageSource!);
    } else {
      // No source provided — go back, dialog should happen before navigation
      Navigator.pop(context);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final imageFile = await _detectionService.pickImageFromSource(source);

    if (imageFile == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    // Decode image dimensions so CustomPaint aligns with BoxFit.contain
    final imageBytes = await imageFile.readAsBytes();
    final ui.Image decoded = await decodeImageFromList(imageBytes);

    if (!mounted) return;

    setState(() {
      _selectedImage = imageFile;
      _isProcessing = true;
      _detections.clear();
      _imageAspectRatio = decoded.width / decoded.height;
    });

    LoadingModal.show(
      context,
      title: "Analyzing Image",
      description: "Detecting ALL road hazards with unified AI model...",
    );

    try {
      final output = await _detectionService.detectObjects(
        imageFile,
        confidenceThreshold: 0.35,
      );

      if (!mounted) return;
      setState(() {
        _detections = output.detections;
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

    // Show location dialog before proceeding to report
    final shouldGetLocation = await LocationRequiredDialog.show(context);
    if (!mounted) return;
    if (!shouldGetLocation) return;

    // Fetch GPS location with enhanced accuracy
    CompactLoadingModal.show(context, message: "Getting your location...");

    LocationData? locationData;
    try {
      final geoService = GeolocationService();
      locationData = await geoService.getCurrentLocationForReports();
    } catch (e) {
      if (!mounted) return;
      CompactLoadingModal.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: statusDanger,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!mounted) return;
    CompactLoadingModal.hide(context);

    // Render our own annotations onto the image so they appear in the report.
    // We draw only the filtered detections (not the raw YOLO annotated image
    // which includes ALL classes including excluded ones).
    final annotatedFile =
        await _renderAnnotatedImage(_selectedImage!, _detections);
    final String processedImagePath =
        annotatedFile?.path ?? _selectedImage!.path;

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
          imagePath: processedImagePath,
          reportType: widget.category?.label ?? 'Road Hazard',
          detections: detectionTags,
          autoDescription: autoDescription,
          locationData: locationData,
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

  /// Renders bounding-box annotations directly onto the image pixels
  /// so they show up in the final report on any device.
  Future<File?> _renderAnnotatedImage(
    File imageFile,
    List<DetectionResult> detections,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());

      // Draw the original image
      canvas.drawImage(image, Offset.zero, Paint());

      // Draw bounding boxes
      for (final det in detections) {
        final left = (det.centerX - det.width / 2) * size.width;
        final top = (det.centerY - det.height / 2) * size.height;
        final right = (det.centerX + det.width / 2) * size.width;
        final bottom = (det.centerY + det.height / 2) * size.height;

        final rect = Rect.fromLTRB(left, top, right, bottom);

        // Box outline
        final boxPaint = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawRect(rect, boxPaint);

        // Label
        final label =
            '${det.className.replaceAll('_', ' ')} ${(det.confidence * 100).toStringAsFixed(0)}%';
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final bgRect = Rect.fromLTWH(
          left,
          top - textPainter.height - 8,
          textPainter.width + 16,
          textPainter.height + 8,
        );
        canvas.drawRect(bgRect, Paint()..color = Colors.redAccent);
        textPainter.paint(
            canvas, Offset(left + 8, top - textPainter.height - 4));
      }

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(image.width, image.height);
      final pngBytes =
          await rendered.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) return null;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/report_annotated_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint('Failed to render annotated image: $e');
      return null;
    }
  }

  void _retakePhoto() async {
    if (widget.initialImageSource != null) {
      setState(() {
        _selectedImage = null;
        _detections.clear();
      });
      await _pickImageFromSource(widget.initialImageSource!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SafeArea(
        child: _selectedImage == null
            ? const Center(child: CircularProgressIndicator(color: primary))
            : _buildDetectionView(),
      ),
    );
  }

  Widget _buildDetectionView() {
    return Stack(
      children: [
        // Constrain the Stack to the image's aspect ratio so CustomPaint
        // lines up exactly with the rendered image (no letterbox offset).
        Center(
          child: _imageAspectRatio != null
              ? AspectRatio(
                  aspectRatio: _imageAspectRatio!,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_selectedImage!, fit: BoxFit.cover),
                      if (!_isProcessing && _detections.isNotEmpty)
                        CustomPaint(
                          painter: _DetectionBoxPainter(
                            detections: _detections,
                          ),
                        ),
                    ],
                  ),
                )
              : Image.file(_selectedImage!, fit: BoxFit.contain),
        ),

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
              onRetry: _retakePhoto,
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

/// Paints bounding boxes over the original image using normalized coordinates.
class _DetectionBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;

  _DetectionBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      final left = (det.centerX - det.width / 2) * size.width;
      final top = (det.centerY - det.height / 2) * size.height;
      final right = (det.centerX + det.width / 2) * size.width;
      final bottom = (det.centerY + det.height / 2) * size.height;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      // Box outline
      final boxPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRect(rect, boxPaint);

      // Label background
      final label =
          '${det.className.replaceAll('_', ' ')} ${(det.confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = Rect.fromLTWH(
        left,
        top - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );
      canvas.drawRect(bgRect, Paint()..color = Colors.redAccent);
      textPainter.paint(canvas, Offset(left + 4, top - textPainter.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
