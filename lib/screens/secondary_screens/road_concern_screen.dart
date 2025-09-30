import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadfix/screens/secondary_screens/send_report_screen.dart';
import 'package:roadfix/services/custom_annotation_service.dart';
import 'package:roadfix/widgets/detection_widgets/custom_annotation_widget.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.initialImageSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImageFromSource(widget.initialImageSource!);
      });
    } else {
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
      });
      _annotationService.clearAnnotations();
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

    CompactLoadingModal.show(context, message: "Preparing report...");

    final annotatedImagePath = await _annotationService.createAnnotatedImage(
      _imageData!.file,
      _imageData!.bytes,
      statusDanger,
    );

    if (!mounted) return;
    CompactLoadingModal.hide(context);

    final annotations = _annotationService.getAnnotations();

    // Tags are always just "Road Concern"
    final detectionTags = ['Road Concern'];

    // Description shows the labels
    String autoDescription;
    if (annotations.isEmpty) {
      autoDescription = 'The Reporter reported a Road Concern: General Issue';
    } else {
      final labels = annotations
          .map((ann) => ann['label'].toString())
          .join(', ');
      autoDescription = 'The Reporter reported a Road Concern: $labels';
    }

    if (annotatedImagePath != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReportScreen(
            imagePath: annotatedImagePath,
            reportType: 'Road Concern',
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: secondary.withValues(alpha: 0.7),
                ),
                icon: const Icon(Icons.arrow_back, color: inputFill),
              ),
              IconButton(
                onPressed: () {
                  _annotationService.clearAnnotations();
                  setState(() {});
                },
                style: IconButton.styleFrom(
                  backgroundColor: secondary.withValues(alpha: 0.7),
                ),
                icon: const Icon(Icons.clear_all, color: inputFill),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: altSecondary.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomAnnotationWidget(
                  imageBytes: _imageData!.bytes,
                  controller: _annotationService.controller,
                  boxColor: statusDanger,
                  strokeWidth: 3.0,
                ),
              ),
            ),
          ),
        ),

        Padding(padding: const EdgeInsets.all(20), child: _buildControls()),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.gesture, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tap and drag to draw boxes',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _annotationService.controller,
            builder: (context, child) {
              final count = _annotationService.controller.annotations.length;
              if (count > 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '$count annotation${count > 1 ? 's' : ''} added',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _imageData = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Retake', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirmReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
