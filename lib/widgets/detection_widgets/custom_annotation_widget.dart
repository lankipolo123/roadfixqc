import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:roadfix/utils/custom_annotation_controller.dart';
import 'package:roadfix/widgets/themes.dart';

class CustomAnnotationWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final CustomAnnotationController controller;
  final Color boxColor;
  final double strokeWidth;

  const CustomAnnotationWidget({
    super.key,
    required this.imageBytes,
    required this.controller,
    this.boxColor = Colors.red,
    this.strokeWidth = 3.0,
  });

  @override
  State<CustomAnnotationWidget> createState() => _CustomAnnotationWidgetState();
}

class _CustomAnnotationWidgetState extends State<CustomAnnotationWidget> {
  Size? _imageSize;

  Future<void> _showLabelDialog() async {
    final TextEditingController labelController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Label this annotation'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            hintText: 'Enter label (e.g., Pothole, Crack)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
              widget.controller.cancelDrawing();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, labelController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: secondary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      widget.controller.finishDrawing(result);
    } else {
      widget.controller.cancelDrawing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Set display size for normalization
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_imageSize != Size(constraints.maxWidth, constraints.maxHeight)) {
            _imageSize = Size(constraints.maxWidth, constraints.maxHeight);
            widget.controller.setDisplaySize(_imageSize!);
          }
        });

        return GestureDetector(
          onPanStart: (details) {
            widget.controller.startDrawing(details.localPosition);
          },
          onPanUpdate: (details) {
            widget.controller.updateDrawing(details.localPosition);
          },
          onPanEnd: (_) {
            _showLabelDialog();
          },
          child: Stack(
            children: [
              Image.memory(
                widget.imageBytes,
                fit: BoxFit.contain,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnnotationPainter(
                        annotations: widget.controller.annotations,
                        currentDrawing: widget.controller.currentDrawing,
                        boxColor: widget.boxColor,
                        strokeWidth: widget.strokeWidth,
                        displaySize:
                            _imageSize ??
                            Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<AnnotationBox> annotations;
  final AnnotationBox? currentDrawing;
  final Color boxColor;
  final double strokeWidth;
  final Size displaySize;

  AnnotationPainter({
    required this.annotations,
    required this.currentDrawing,
    required this.boxColor,
    required this.strokeWidth,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw completed annotations (normalized)
    for (final annotation in annotations) {
      final rect = annotation.rect(displaySize);
      canvas.drawRect(rect, paint);
      _drawLabel(canvas, rect, annotation.label);
    }

    // Draw current drawing (not normalized yet)
    if (currentDrawing != null) {
      final rect = currentDrawing!.rect(displaySize);
      canvas.drawRect(rect, paint);
    }
  }

  void _drawLabel(Canvas canvas, Rect rect, String label) {
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final labelX = rect.left;
    final labelY = (rect.top - textPainter.height - 4).clamp(
      0.0,
      displaySize.height,
    );

    final labelBgRect = Rect.fromLTWH(
      labelX,
      labelY,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    canvas.drawRect(
      labelBgRect,
      Paint()..color = boxColor.withValues(alpha: 0.9),
    );

    textPainter.paint(canvas, Offset(labelX + 4, labelY + 2));
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) => true;
}
