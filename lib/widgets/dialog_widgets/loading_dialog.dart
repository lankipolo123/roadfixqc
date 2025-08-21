// lib/widgets/common_widgets/loading_modal.dart
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class LoadingModal extends StatelessWidget {
  final String title;
  final String description;
  final bool barrierDismissible;

  const LoadingModal({
    super.key,
    required this.title,
    required this.description,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: secondary.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinning animation
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: primary,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primary,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: secondary,
                  height: 1.5,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static method to show the modal
  static void show(
    BuildContext context, {
    required String title,
    required String description,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: secondary.withAlpha(125),
      builder: (context) => LoadingModal(
        title: title,
        description: description,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // Static method to hide the modal
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}

// Compact version for simple loading states
class CompactLoadingModal extends StatelessWidget {
  final String message;
  final bool barrierDismissible;

  const CompactLoadingModal({
    super.key,
    required this.message,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: secondary.withAlpha(25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: primary,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: secondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static methods for compact version
  static void show(
    BuildContext context, {
    required String message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: secondary.withAlpha(100),
      builder: (context) => CompactLoadingModal(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
