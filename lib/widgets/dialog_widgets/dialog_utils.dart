import 'package:flutter/material.dart';

class DialogUtils {
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 64),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info, color: Colors.blue, size: 64),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.help_outline, color: Colors.orange, size: 64),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  // NEW: Async confirmation dialog that returns Future<bool?>
  static Future<bool?> showConfirmationAsync({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.help_outline, color: Colors.orange, size: 64),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
