// lib/models/detection_box.dart

class DetectionBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  final double confidence;

  DetectionBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.confidence,
  });
}
