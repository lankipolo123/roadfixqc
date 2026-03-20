// Simple data model to replace the Map<String, dynamic>
class DetectionResult {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  double confidence;
  final String className;

  /// The real confidence from the model, preserved even when confidence is masked.
  final double originalConfidence;

  /// Whether the confidence is currently masked (showing suppressed value).
  bool get isMasked => confidence != originalConfidence;

  DetectionResult({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.confidence,
    required this.className,
    double? originalConfidence,
  }) : originalConfidence = originalConfidence ?? confidence;

  // Create from your existing Map format
  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      centerX: map['xc'],
      centerY: map['yc'],
      width: map['width'],
      height: map['height'],
      confidence: map['confidence'],
      className: map['className'],
      originalConfidence: map['originalConfidence'] as double?,
    );
  }

  /// Mask the confidence to a suppressed value (keeps original preserved).
  void maskConfidence(double suppressedValue) {
    confidence = suppressedValue;
  }

  /// Restore the real confidence from the model.
  void restoreConfidence() {
    confidence = originalConfidence;
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
      'originalConfidence': originalConfidence,
    };
  }
}
