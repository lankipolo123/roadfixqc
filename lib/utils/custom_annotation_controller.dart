import 'package:flutter/material.dart';

class CustomAnnotationController extends ChangeNotifier {
  final List<AnnotationBox> _annotations = [];
  AnnotationBox? _currentDrawing;
  Size? _displaySize;
  Size? _frozenDisplaySize; // Freeze size during drawing

  List<AnnotationBox> get annotations => List.unmodifiable(_annotations);
  AnnotationBox? get currentDrawing => _currentDrawing;

  void setDisplaySize(Size size) {
    _displaySize = size;
  }

  void startDrawing(Offset start) {
    if (_displaySize == null) return;

    // FREEZE the display size at draw start
    _frozenDisplaySize = _displaySize;

    _currentDrawing = AnnotationBox(
      topLeft: start,
      bottomRight: start,
      label: '',
      isNormalized: false,
    );
    notifyListeners();
  }

  void updateDrawing(Offset current) {
    if (_currentDrawing != null) {
      _currentDrawing = AnnotationBox(
        topLeft: _currentDrawing!.topLeft,
        bottomRight: current,
        label: _currentDrawing!.label,
        isNormalized: false,
      );
      notifyListeners();
    }
  }

  void finishDrawing(String label) {
    if (_currentDrawing != null && _frozenDisplaySize != null) {
      final drawnTopLeft = _currentDrawing!.topLeft;
      final drawnBottomRight = _currentDrawing!.bottomRight;

      final width = (drawnBottomRight.dx - drawnTopLeft.dx).abs();
      final height = (drawnBottomRight.dy - drawnTopLeft.dy).abs();

      if (width > 10 && height > 10) {
        // Normalize using FROZEN size (from when drawing started)
        final left = drawnTopLeft.dx < drawnBottomRight.dx
            ? drawnTopLeft.dx
            : drawnBottomRight.dx;
        final top = drawnTopLeft.dy < drawnBottomRight.dy
            ? drawnTopLeft.dy
            : drawnBottomRight.dy;
        final right = drawnTopLeft.dx > drawnBottomRight.dx
            ? drawnTopLeft.dx
            : drawnBottomRight.dx;
        final bottom = drawnTopLeft.dy > drawnBottomRight.dy
            ? drawnTopLeft.dy
            : drawnBottomRight.dy;

        _annotations.add(
          AnnotationBox(
            topLeft: Offset(
              left / _frozenDisplaySize!.width,
              top / _frozenDisplaySize!.height,
            ),
            bottomRight: Offset(
              right / _frozenDisplaySize!.width,
              bottom / _frozenDisplaySize!.height,
            ),
            label: label.isEmpty ? 'Unlabeled' : label,
            isNormalized: true,
          ),
        );
      }

      _currentDrawing = null;
      _frozenDisplaySize = null; // Release frozen size
      notifyListeners();
    }
  }

  void cancelDrawing() {
    _currentDrawing = null;
    _frozenDisplaySize = null;
    notifyListeners();
  }

  void clear() {
    _annotations.clear();
    _currentDrawing = null;
    _frozenDisplaySize = null;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _annotations.length) {
      _annotations.removeAt(index);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getAnnotationData() {
    return _annotations.map((box) => box.toMap()).toList();
  }

  Size? get currentDisplaySize => _frozenDisplaySize ?? _displaySize;
}

class AnnotationBox {
  final Offset topLeft;
  final Offset bottomRight;
  final String label;
  final bool isNormalized;

  AnnotationBox({
    required this.topLeft,
    required this.bottomRight,
    required this.label,
    this.isNormalized = false,
  });

  Rect rect(Size size) {
    if (isNormalized) {
      return Rect.fromLTRB(
        topLeft.dx * size.width,
        topLeft.dy * size.height,
        bottomRight.dx * size.width,
        bottomRight.dy * size.height,
      );
    }
    return Rect.fromPoints(topLeft, bottomRight);
  }

  Map<String, dynamic> toMap() {
    return {
      'topLeft': {'x': topLeft.dx, 'y': topLeft.dy},
      'bottomRight': {'x': bottomRight.dx, 'y': bottomRight.dy},
      'label': label,
      'isNormalized': isNormalized,
    };
  }
}
