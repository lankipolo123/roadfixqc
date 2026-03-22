// Simple data model to replace the Map<String, dynamic>
class DetectionResult {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  double confidence;
  final String className;
  final double originalConfidence;

  DetectionResult({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.confidence,
    required this.className,
    double? originalConfidence,
  }) : originalConfidence = originalConfidence ?? confidence;

  /// Restore real confidence from original value.
  void restoreConfidence() {
    confidence = originalConfidence;
  }

  /// Mask confidence with a fake value.
  void maskConfidence(double masked) {
    confidence = masked;
  }

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
