import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class TutorialInstructionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? bulletPoints;
  final int currentStep;
  final int totalSteps;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isCompact;

  const TutorialInstructionCard({
    super.key,
    required this.title,
    required this.description,
    this.bulletPoints,
    this.currentStep = 1,
    this.totalSteps = 5,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(20),
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: primary.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with step indicator and title
          Row(
            children: [
              // Compact step indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentStep/$totalSteps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),

          // Description (if provided)
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.7),
                decoration: TextDecoration.none,
                height: 1.3,
              ),
            ),
          ],

          // Bullet points (if provided)
          if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: bulletPoints!.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4, right: 8),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.8),
                              decoration: TextDecoration.none,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
