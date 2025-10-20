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
                color: secondary.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: primary,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),
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

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: secondary.withValues(alpha: 0.49),
      builder: (context) => LoadingModal(
        title: title,
        description: description,
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
                color: secondary.withValues(alpha: 0.10),
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

  static void show(
    BuildContext context, {
    required String message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: secondary.withValues(alpha: 0.39),
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

// NEW: Progress Loading Modal
class ProgressLoadingModal extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool barrierDismissible;

  const ProgressLoadingModal({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

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
                color: secondary.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      color: primary,
                      backgroundColor: Colors.grey.shade200,
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
