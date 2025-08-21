import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportActionButtons extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onReportAnother;
  final VoidCallback onDone;
  final bool isLoading; // ✅ added loading flag

  const ReportActionButtons({
    super.key,
    required this.onSubmit,
    required this.onReportAnother,
    required this.onDone,
    this.isLoading = false, // ✅ default false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Send Report button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: statusSuccess,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(inputFill),
                    ),
                  )
                : const Text(
                    'Send Report',
                    style: TextStyle(fontSize: 16, color: inputFill),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Report Another Issue button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onReportAnother,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Report Another Issue',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Done button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isLoading ? null : onDone,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Done', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
