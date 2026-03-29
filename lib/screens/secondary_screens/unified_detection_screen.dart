import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/models/detection_result.dart';
import 'package:roadfix/models/report_category_model.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/unified_detection_service.dart';
import 'package:roadfix/widgets/detection_widgets/detection_bottom_card.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/location_required_dialog.dart';
import 'package:roadfix/utils/location_permission_manager.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/models/location_models.dart';
import 'package:roadfix/widgets/themes.dart';

class DetectionScreen extends StatefulWidget {
  final ImageSource? initialImageSource;
  final ReportCategory? category;

  const DetectionScreen({
    super.key,
    this.initialImageSource,
    this.category,
  });

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final DetectionService _detectionService = DetectionService();
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
    try {
      await _detectionService.loadModel();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load model: $e'),
            backgroundColor: statusDanger,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    if (widget.initialImageSource != null) {
      await _pickImageFromSource(widget.initialImageSource!);
    } else {
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
      description: "Detecting road hazards...",
    );

    try {
      final output = await _detectionService.detectObjects(
        imageFile,
        confidenceThreshold: 0.25,
      );

      if (!mounted) return;
      setState(() {
        _detections = output.detections;
        _isProcessing = false;
      });

      LoadingModal.hide(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      LoadingModal.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detection error: $e'),
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

    final hasPermission =
        await LocationPermissionManager.hasLocationPermission();

    if (!hasPermission) {
      if (!mounted) return;
      final granted = await LocationRequiredDialog.show(context);
      if (!mounted) return;
      if (!granted) return;
    }

    if (!mounted) return;
    CompactLoadingModal.show(context, message: "Getting your location...");

    LocationData? locationData;
    try {
      final geoService = GeolocationService();
      locationData = await geoService.getCurrentLocationForReports();
    } catch (e) {
      if (!mounted) return;
      CompactLoadingModal.hide(context);

      final stillHasPermission =
          await LocationPermissionManager.hasLocationPermission();
      if (!mounted) return;

      if (!stillHasPermission) {
        final granted = await LocationRequiredDialog.show(context);
        if (!mounted) return;
        if (!granted) return;

        CompactLoadingModal.show(context, message: "Getting your location...");
        try {
          final geoService = GeolocationService();
          locationData = await geoService.getCurrentLocationForReports();
        } catch (retryError) {
          if (!mounted) return;
          CompactLoadingModal.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get location: $retryError'),
              backgroundColor: statusDanger,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    CompactLoadingModal.hide(context);

    final annotatedFile = await _renderAnnotatedImage(
      _selectedImage!,
      _detections,
    );
    final String processedImagePath =
        annotatedFile?.path ?? _selectedImage!.path;

    if (!mounted) return;

    final Map<String, int> detectionCounts = {};
    double totalConfidence = 0;

    for (var detection in _detections) {
      detectionCounts[detection.className] =
          (detectionCounts[detection.className] ?? 0) + 1;
      totalConfidence += detection.confidence;
    }

    final avgConfidence =
        (totalConfidence / _detections.length * 100).toStringAsFixed(1);

    final detectionTags = detectionCounts.keys
        .map((className) => _formatDisplayName(className))
        .toList();

    final descriptionParts = <String>[];
    descriptionParts.add('Detection Results:');
    descriptionParts.add('');

    for (var entry in detectionCounts.entries) {
      final displayName = _formatDisplayName(entry.key);
      descriptionParts.add(
        '${entry.value}x $displayName${entry.value > 1 ? 's' : ''}',
      );
    }

    descriptionParts.add('');
    descriptionParts.add('Confidence: $avgConfidence%');

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

  Future<File?> _renderAnnotatedImage(
    File imageFile,
    List<DetectionResult> detections,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final original = frame.image;

      final w = original.width.toDouble();
      final h = original.height.toDouble();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

      canvas.drawImage(original, Offset.zero, Paint());

      final boxPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = (w * 0.005).clamp(2.0, 8.0);

      final bgPaint = Paint()..color = Colors.redAccent;
      final fontSize = (w * 0.025).clamp(12.0, 48.0);

      for (final det in detections) {
        final left = (det.centerX - det.width / 2) * w;
        final top = (det.centerY - det.height / 2) * h;
        final right = (det.centerX + det.width / 2) * w;
        final bottom = (det.centerY + det.height / 2) * h;

        final rect = Rect.fromLTRB(left, top, right, bottom);
        canvas.drawRect(rect, boxPaint);

        final label =
            '${_formatDisplayName(det.className)} ${(det.confidence * 100).toStringAsFixed(1)}%';
        final builder = ui.ParagraphBuilder(
          ui.ParagraphStyle(textAlign: TextAlign.left, fontSize: fontSize),
        )
          ..pushStyle(
            ui.TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
          ..addText(label);
        final paragraph = builder.build()
          ..layout(ui.ParagraphConstraints(width: right - left + 100));

        final labelH = paragraph.height + 4;
        canvas.drawRect(
          Rect.fromLTWH(left, top - labelH, paragraph.longestLine + 8, labelH),
          bgPaint,
        );
        canvas.drawParagraph(paragraph, Offset(left + 4, top - labelH + 2));
      }

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(w.toInt(), h.toInt());
      final pngBytes =
          await rendered.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) return null;

      final dir = await getTemporaryDirectory();
      final outFile = File(
        '${dir.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await outFile.writeAsBytes(pngBytes.buffer.asUint8List());
      return outFile;
    } catch (e) {
      debugPrint('Error rendering annotated image: $e');
      return null;
    }
  }

  String _formatDisplayName(String className) {
    switch (className) {
      case 'Fallen-Barrier':
      case 'Fallen_Barrier':
        return 'Fallen Barrier';
      case 'Fallen-Cone':
      case 'Fallen_Cone':
        return 'Fallen Cone';
      case 'Fallen-Pole':
      case 'Fallen_Pole':
        return 'Fallen Utility Pole';
      case 'Pothole':
        return 'Pothole';
      default:
        return className.replaceAll('-', ' ').replaceAll('_', ' ');
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

      final boxPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRect(rect, boxPaint);

      final label =
          '${det.className.replaceAll('-', ' ').replaceAll('_', ' ')} ${(det.confidence * 100).toStringAsFixed(1)}%';
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
      textPainter.paint(
          canvas, Offset(left + 4, top - textPainter.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
