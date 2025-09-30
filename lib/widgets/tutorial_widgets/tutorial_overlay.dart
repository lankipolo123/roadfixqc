import 'package:flutter/material.dart';
import 'package:roadfix/utils/bouncy_touch_icon.dart';
import 'package:roadfix/widgets/themes.dart';
import 'tutorial_instruction_card.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey? targetKey;
  final List<GlobalKey>? targetKeys;
  final String title;
  final String description;
  final List<String>? bulletPoints;
  final String actionText;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool enabled;
  final int currentStep;
  final int totalSteps;

  // Positioning parameters
  final double? cardTop;
  final double? cardBottom;
  final double? cardLeft;
  final double? cardRight;
  final bool isCardCompact;

  // Gesture icon positioning
  final String gesturePosition;
  final double gestureOffset;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.targetKey,
    this.targetKeys,
    required this.title,
    required this.description,
    this.bulletPoints,
    required this.actionText,
    this.onComplete,
    this.onSkip,
    this.enabled = true,
    this.currentStep = 1,
    this.totalSteps = 5,
    this.cardTop,
    this.cardBottom,
    this.cardLeft = 20,
    this.cardRight = 20,
    this.isCardCompact = false,
    this.gesturePosition = 'top',
    this.gestureOffset = 50,
  }) : assert(
         targetKey != null || targetKeys != null,
         'Either targetKey or targetKeys must be provided',
       ),
       assert(
         cardTop == null || cardBottom == null,
         'Cannot specify both cardTop and cardBottom',
       );

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  List<Rect> _targetRects = [];

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateTargetPositions();
        });
      });
    }
  }

  void _updateTargetPositions() {
    List<Rect> rects = [];

    if (widget.targetKey != null) {
      final renderBox =
          widget.targetKey!.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final position = renderBox.localToGlobal(Offset.zero);
        rects.add(
          Rect.fromLTWH(
            position.dx,
            position.dy,
            renderBox.size.width,
            renderBox.size.height,
          ),
        );
      }
    }

    if (widget.targetKeys != null) {
      for (final key in widget.targetKeys!) {
        final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          final position = renderBox.localToGlobal(Offset.zero);
          rects.add(
            Rect.fromLTWH(
              position.dx,
              position.dy,
              renderBox.size.width,
              renderBox.size.height,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _targetRects = rects;
      });
    }
  }

  /// Text box positioning (offset farther out so it won’t overlap the icon)
  Map<String, double> _getGesturePositions() {
    if (_targetRects.isEmpty) return {'left': 0, 'top': 0};

    final targetRect = _targetRects.first;
    final centerX = targetRect.center.dx;
    final centerY = targetRect.center.dy;

    switch (widget.gesturePosition) {
      case 'top':
        return {
          'left': centerX - 50,
          'top': targetRect.top - widget.gestureOffset - 80,
        };
      case 'bottom':
        return {
          'left': centerX - 50,
          'top': targetRect.bottom + widget.gestureOffset + 40,
        };
      case 'left':
        return {
          'left': targetRect.left - widget.gestureOffset - 140,
          'top': centerY - 25,
        };
      case 'right':
        return {
          'left': targetRect.right + widget.gestureOffset + 40,
          'top': centerY - 25,
        };
      default:
        return {
          'left': centerX - 50,
          'top': targetRect.top - widget.gestureOffset - 80,
        };
    }
  }

  /// Icon positioning (always hugs the highlight edge, centered)
  Map<String, double> _getBouncyIconPositions() {
    if (_targetRects.isEmpty) return {'left': 0, 'top': 0};

    final targetRect = _targetRects.first;
    final centerX = targetRect.center.dx;
    final centerY = targetRect.center.dy;

    switch (widget.gesturePosition) {
      case 'top':
        return {
          'left': centerX - 15,
          'top': targetRect.top - widget.gestureOffset,
        };
      case 'bottom':
        return {
          'left': centerX - 15,
          'top': targetRect.bottom + widget.gestureOffset,
        };
      case 'left':
        return {
          'left': targetRect.left - widget.gestureOffset - 30,
          'top': centerY - 15,
        };
      case 'right':
        return {
          'left': targetRect.right + widget.gestureOffset,
          'top': centerY - 15,
        };
      default:
        return {
          'left': centerX - 15,
          'top': targetRect.top - widget.gestureOffset,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (widget.enabled) ...[
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                final tapPosition = details.globalPosition;
                for (final rect in _targetRects) {
                  if (rect.contains(tapPosition)) {
                    if (widget.onComplete != null) {
                      widget.onComplete!();
                    }
                    return;
                  }
                }
              },
              child: CustomPaint(
                painter: TutorialOverlayPainter(cutoutRects: _targetRects),
                child: Container(),
              ),
            ),
          ),

          if (_targetRects.isNotEmpty)
            Positioned(
              left: widget.cardLeft,
              right: widget.cardRight,
              top: widget.cardTop,
              bottom: widget.cardBottom ?? (widget.cardTop == null ? 80 : null),
              child: TutorialInstructionCard(
                title: widget.title,
                description: widget.description,
                bulletPoints: widget.bulletPoints,
                currentStep: widget.currentStep,
                totalSteps: widget.totalSteps,
                isCompact: widget.isCardCompact,
              ),
            ),

          if (_targetRects.isNotEmpty)
            Builder(
              builder: (context) {
                final positions = _getGesturePositions();
                return Positioned(
                  left: positions['left'],
                  top: positions['top'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.actionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),

          if (_targetRects.isNotEmpty)
            Builder(
              builder: (context) {
                final positions = _getBouncyIconPositions();
                String direction;

                switch (widget.gesturePosition) {
                  case 'top':
                    direction = 'down';
                    break;
                  case 'bottom':
                    direction = 'up';
                    break;
                  case 'left':
                    direction = 'right';
                    break;
                  case 'right':
                    direction = 'left';
                    break;
                  default:
                    direction = 'down';
                }

                return Positioned(
                  left: positions['left'],
                  top: positions['top'],
                  child: BouncyTouchIcon(direction: direction),
                );
              },
            ),

          Positioned(
            top: 60,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (widget.onSkip != null) {
                  widget.onSkip!();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.close, color: statusDanger, size: 25),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TutorialOverlayPainter extends CustomPainter {
  final List<Rect> cutoutRects;

  TutorialOverlayPainter({required this.cutoutRects});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (cutoutRects.isNotEmpty) {
      Path cutoutPath = Path();

      for (final rect in cutoutRects) {
        cutoutPath.addRRect(
          RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(12)),
        );
      }

      final pathWithHoles = Path.combine(
        PathOperation.difference,
        fullScreenPath,
        cutoutPath,
      );
      canvas.drawPath(pathWithHoles, paint);
    } else {
      canvas.drawPath(fullScreenPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is TutorialOverlayPainter &&
        !_listEquals(oldDelegate.cutoutRects, cutoutRects);
  }

  bool _listEquals(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
