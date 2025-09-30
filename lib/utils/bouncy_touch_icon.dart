import 'package:flutter/material.dart';

class BouncyTouchIcon extends StatefulWidget {
  final double size;
  final Color color;
  final bool rotateDown;
  final Duration duration;
  final double bounceRange;
  final IconData icon;
  final bool autoStart;
  final String? direction; // New parameter for direction

  const BouncyTouchIcon({
    super.key,
    this.size = 30,
    this.color = Colors.white,
    this.rotateDown = true,
    this.duration = const Duration(milliseconds: 1000),
    this.bounceRange = 8.0,
    this.icon = Icons.touch_app,
    this.autoStart = true,
    this.direction, // Optional direction parameter
  });

  @override
  State<BouncyTouchIcon> createState() => _BouncyTouchIconState();
}

class _BouncyTouchIconState extends State<BouncyTouchIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation =
        Tween<double>(
          begin: -widget.bounceRange,
          end: widget.bounceRange,
        ).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );

    if (widget.autoStart) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (!_bounceController.isAnimating) {
      _bounceController.repeat(reverse: true);
    }
  }

  void stopAnimation() {
    _bounceController.stop();
  }

  double _getRotation() {
    // If direction is provided, use it; otherwise use rotateDown
    if (widget.direction != null) {
      switch (widget.direction!) {
        case 'up':
          return 0;
        case 'left':
          return 1.5708;
        case 'right':
          return -1.5708;
        case 'down':
        default:
          return 3.14159;
      }
    } else {
      // Backward compatibility with rotateDown
      return widget.rotateDown ? 3.14159 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _getRotation(),
            child: Icon(widget.icon, color: widget.color, size: widget.size),
          ),
        );
      },
    );
  }
}

// Alternative bouncy widgets for different use cases
class BouncyWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bounceRange;
  final bool autoStart;
  final Curve curve;

  const BouncyWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.bounceRange = 8.0,
    this.autoStart = true,
    this.curve = Curves.easeInOut,
  });

  @override
  State<BouncyWidget> createState() => _BouncyWidgetState();
}

class _BouncyWidgetState extends State<BouncyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: -widget.bounceRange,
      end: widget.bounceRange,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

// Pulsing widget for attention-grabbing elements
class PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool autoStart;

  const PulsingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.8,
    this.maxScale = 1.1,
    this.autoStart = true,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  void stopAnimation() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

// Utility class for common animation presets
class AnimationPresets {
  static const Duration fastBounce = Duration(milliseconds: 500);
  static const Duration normalBounce = Duration(milliseconds: 1000);
  static const Duration slowBounce = Duration(milliseconds: 1500);

  static const Duration fastPulse = Duration(milliseconds: 800);
  static const Duration normalPulse = Duration(milliseconds: 1500);
  static const Duration slowPulse = Duration(milliseconds: 2500);

  // Predefined bouncy touch icons for common scenarios
  static Widget tutorialPointer({
    double size = 30,
    Color color = Colors.white,
  }) {
    return BouncyTouchIcon(
      size: size,
      color: color,
      rotateDown: true,
      duration: normalBounce,
    );
  }

  static Widget attentionGrabber({
    double size = 24,
    Color color = Colors.orange,
  }) {
    return BouncyTouchIcon(
      size: size,
      color: color,
      rotateDown: false,
      duration: fastBounce,
      icon: Icons.touch_app,
    );
  }

  static Widget callToAction({double size = 20, Color color = Colors.blue}) {
    return BouncyTouchIcon(
      size: size,
      color: color,
      rotateDown: false,
      duration: normalBounce,
      icon: Icons.ads_click,
    );
  }
}
