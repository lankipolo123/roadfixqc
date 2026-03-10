import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportActionButtons extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onReportAnother;
  final VoidCallback onDone;
  final bool isLoading;

  const ReportActionButtons({
    super.key,
    required this.onSubmit,
    required this.onReportAnother,
    required this.onDone,
    this.isLoading = false,
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
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: statusSuccess,
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                      valueColor: const AlwaysStoppedAnimation<Color>(inputFill),
                    ),
                  )
                : Text(
                    'Send Report',
                    style: TextStyle(fontSize: 16.sp, color: inputFill),
                  ),
          ),
        ),
        SizedBox(height: 12.h),

        // Report Another Issue button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onReportAnother,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'Report Another Issue',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Done button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isLoading ? null : onDone,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text('Done', style: TextStyle(fontSize: 16.sp)),
          ),
        ),
      ],
    );
  }
}
