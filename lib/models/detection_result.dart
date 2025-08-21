// Simple data model to replace the Map<String, dynamic>
class DetectionResult {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double confidence;
  final String className;

  DetectionResult({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.confidence,
    required this.className,
  });

  // Create from your existing Map format
  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      centerX: map['xc'],
      centerY: map['yc'],
      width: map['width'],
      height: map['height'],
      confidence: map['confidence'],
      className: map['className'],
    );
  }

  // Convert back to Map if needed
  Map<String, dynamic> toMap() {
    return {
      'xc': centerX,
      'yc': centerY,
      'width': width,
      'height': height,
      'confidence': confidence,
      'className': className,
    };
  }
}
