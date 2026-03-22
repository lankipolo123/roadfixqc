import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  bool _showDebugPanel = false;

  File? _selectedImage;
  List<DetectionResult> _detections = [];
  double? _imageAspectRatio;
  String _debugInfo = '';
  String _modelStatus = 'Loading model...';

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
      setState(() => _modelStatus = 'Loading YOLO model...');
      await _detectionService.loadModel();
      setState(() => _modelStatus = 'Model loaded OK');
      debugPrint('[DEBUG] Model loaded successfully');
    } catch (e) {
      setState(() {
        _modelStatus = 'MODEL LOAD FAILED: $e';
        _debugInfo = 'Model failed to load: $e';
      });
      debugPrint('[DEBUG] Model load error: $e');
    }

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
        confidenceThreshold: 0.25, // Lowered from 0.35 to catch road cracks
      );

      if (!mounted) return;
      setState(() {
        _detections = output.detections;
        _isProcessing = false;
        _debugInfo = 'Detection complete: ${output.detections.length} objects';
        _modelStatus =
            'Detection complete: ${output.detections.length} objects found';
      });

      debugPrint(
        '[DEBUG] Detection results: ${output.detections.length} objects',
      );
      for (var det in output.detections) {
        debugPrint(
          '[DEBUG]   -> ${det.className} (${(det.confidence * 100).toStringAsFixed(1)}%) '
          'at (${det.centerX.toStringAsFixed(3)}, ${det.centerY.toStringAsFixed(3)})',
        );
      }

      LoadingModal.hide(context);
    } catch (e) {
      debugPrint('[DEBUG] Detection FAILED: $e');
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _debugInfo = 'DETECTION ERROR: $e';
        _modelStatus = 'Detection failed';
      });
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

    // Check if location permission is already granted
    final hasPermission =
        await LocationPermissionManager.hasLocationPermission();

    if (!hasPermission) {
      // Show mandatory location modal
      if (!mounted) return;
      final granted = await LocationRequiredDialog.show(context);
      if (!mounted) return;
      if (!granted) return; // User chose "Go Back"
    }

    // Fetch GPS location with enhanced accuracy
    if (!mounted) return;
    CompactLoadingModal.show(context, message: "Getting your location...");

    LocationData? locationData;
    try {
      final geoService = GeolocationService();
      locationData = await geoService.getCurrentLocationForReports();
    } catch (e) {
      if (!mounted) return;
      CompactLoadingModal.hide(context);

      // Permission may have been revoked — re-check and re-prompt
      final stillHasPermission =
          await LocationPermissionManager.hasLocationPermission();
      if (!mounted) return;

      if (!stillHasPermission) {
        // Re-show mandatory location modal
        final granted = await LocationRequiredDialog.show(context);
        if (!mounted) return;
        if (!granted) return;

        // Retry after re-granting
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
        // Permission is fine, some other location error
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

    // Use the ORIGINAL image for the report — the YOLO annotated image
    // includes bounding boxes for ALL classes (including excluded/filtered ones),
    // so it must NOT be sent to the finalized report.
    final String processedImagePath = _selectedImage!.path;

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

        // Back button
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

        // Debug toggle button
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            onPressed: () => setState(() => _showDebugPanel = !_showDebugPanel),
            style: IconButton.styleFrom(
              backgroundColor: _showDebugPanel
                  ? Colors.orange.withValues(alpha: 0.9)
                  : secondary.withValues(alpha: 0.7),
            ),
            icon: const Icon(Icons.bug_report, color: inputFill),
          ),
        ),

        // Debug info panel
        if (_showDebugPanel)
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEBUG PANEL',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(color: Colors.orange, height: 8),
                    _debugText('Model: $_modelStatus'),
                    _debugText('Detections: ${_detections.length}'),
                    if (_detections.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ..._detections.map(
                        (d) => _debugText(
                          '  ${d.className}: ${(d.confidence * 100).toStringAsFixed(1)}% '
                          'pos(${d.centerX.toStringAsFixed(2)},${d.centerY.toStringAsFixed(2)}) '
                          'size(${d.width.toStringAsFixed(2)}x${d.height.toStringAsFixed(2)})',
                        ),
                      ),
                    ],
                    if (_debugInfo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Divider(color: Colors.grey, height: 8),
                      _debugText(_debugInfo),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _debugText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
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
          '${det.className.replaceAll('_', ' ')} ${(det.confidence * 100).toStringAsFixed(1)}%';
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
