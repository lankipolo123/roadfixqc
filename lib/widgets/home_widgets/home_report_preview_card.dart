import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class HomeReportPreviewCard extends StatelessWidget {
  final String status;
  final bool isActive;

  const HomeReportPreviewCard({
    super.key,
    required this.status,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isActive ? primary : altSecondary, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_outlined, size: 20, color: secondary),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? primary : altSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
