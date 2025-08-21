import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class ReportInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;

  const ReportInfoCard({
    super.key,
    this.title = 'Report Details',
    this.description =
        'Your report has been submitted and will be reviewed by our team. Thank you for helping improve road safety!',
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? primary.withValues(alpha: 0.1);
    final bColor = borderColor ?? primary.withValues(alpha: 0.3);
    final iColor = iconColor ?? primary;
    final tColor = textColor ?? secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: secondary),
          ),
        ],
      ),
    );
  }
}

// Pre-defined info card variants
class SuccessInfoCard extends ReportInfoCard {
  const SuccessInfoCard({super.key})
    : super(
        title: 'Report Submitted',
        description:
            'Your report has been submitted successfully and will be reviewed by our team. Thank you for helping improve road safety!',
        icon: Icons.check_circle_outline,
        backgroundColor: statusSuccess,
        borderColor: statusSuccess,
        iconColor: inputFill,
        textColor: inputFill,
      );
}

class ProcessingInfoCard extends ReportInfoCard {
  const ProcessingInfoCard({super.key})
    : super(
        title: 'Processing Report',
        description:
            'We are currently processing your report. You will receive an update once the review is complete.',
        icon: Icons.hourglass_empty,
        backgroundColor: statusWarning,
        borderColor: statusWarning,
        iconColor: inputFill,
        textColor: inputFill,
      );
}

class WarningInfoCard extends ReportInfoCard {
  const WarningInfoCard({
    super.key,
    super.description =
        'Please note that false reports may result in account restrictions.',
  }) : super(
         title: 'Important Notice',
         icon: Icons.warning_outlined,
         backgroundColor: statusDanger,
         borderColor: statusDanger,
         iconColor: inputFill,
         textColor: inputFill,
       );
}
