import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bounding_box_annotation/bounding_box_annotation.dart';
import 'package:roadfix/services/annotation_service.dart';
import 'package:roadfix/screens/reporting_detection_screens/send_report_screen.dart';
import 'package:roadfix/widgets/detection_widgets/road_concern_annotation_widget.dart';
import 'package:roadfix/widgets/themes.dart';

class RoadConcernScreen extends StatefulWidget {
  final ImageSource? initialImageSource;

  const RoadConcernScreen({super.key, this.initialImageSource});

  @override
  State<RoadConcernScreen> createState() => _RoadConcernScreenState();
}

class _RoadConcernScreenState extends State<RoadConcernScreen> {
  final AnnotationService _annotationService = AnnotationService();

  AnnotationImageData? _imageData;
  List<AnnotationDetails> _annotations = [];

  @override
  void initState() {
    super.initState();
    // Image source should ALWAYS be provided from report type screen
    if (widget.initialImageSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImageFromSource(widget.initialImageSource!);
      });
    } else {
      // This shouldn't happen - go back if no image source provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final imageData = await _annotationService.pickImageFromSource(source);
    if (imageData != null && mounted) {
      setState(() {
        _imageData = imageData;
        _annotations.clear();
      });
      _annotationService.clearAnnotations();
    }
  }

  Future<void> _refreshAnnotations() async {
    final annotations = await _annotationService.getAnnotations();
    if (mounted) {
      setState(() {
        _annotations = annotations;
      });
    }
  }

  void _confirmReport() async {
    if (_imageData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image first'),
            backgroundColor: statusDanger,
          ),
        );
      }
      return;
    }

    await _refreshAnnotations();
    final detectionTags = _annotationService.convertToDetectionTags(
      _annotations,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReportScreen(
            imagePath: _imageData!.file.path,
            reportType: 'Road Concern',
            detections: detectionTags.isNotEmpty
                ? detectionTags
                : ['Road Concern: General Issue'],
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
        child: _imageData == null
            ? _buildLoadingView()
            : _buildAnnotationView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primary),
          SizedBox(height: 16),
          Text(
            'Loading image...',
            style: TextStyle(color: inputFill, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationView() {
    // Calculate proper display dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Available space for the image (accounting for margins and controls)
    final availableWidth = screenWidth - 20; // 10px margin on each side
    final availableHeight = screenHeight - 210; // 60px top + 150px bottom

    return Stack(
      children: [
        // Full-screen camera-style annotation widget with fixed dimensions
        Positioned.fill(
          top: 60,
          bottom: 150,
          left: 10,
          right: 10,
          child: Container(
            width: availableWidth,
            height: availableHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: altSecondary.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: availableWidth,
                height: availableHeight,
                child: BoundingBoxAnnotation(
                  controller: _annotationService.controller,
                  imageBytes: _imageData!.bytes,
                  imageWidth: availableWidth,
                  imageHeight: availableHeight,
                  color: statusDanger,
                  strokeWidth: 3.0,
                ),
              ),
            ),
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

        // Clear button
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            onPressed: () {
              _annotationService.clearAnnotations();
              setState(() => _annotations.clear());
            },
            style: IconButton.styleFrom(
              backgroundColor: secondary.withValues(alpha: 0.7),
            ),
            icon: const Icon(Icons.clear_all, color: inputFill),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: AnnotationControls(
            annotations: _annotations,
            onRefresh: _refreshAnnotations,
            onChangeImage: () {
              setState(() {
                _imageData = null;
                _annotations.clear();
              });
            },
            onConfirm: _confirmReport,
          ),
        ),
      ],
    );
  }
}
