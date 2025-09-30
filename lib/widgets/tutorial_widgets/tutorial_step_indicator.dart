import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

class TutorialStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final double stepSize;
  final double connectorWidth;
  final double connectorHeight;

  const TutorialStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = primary,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.completedColor = primary,
    this.stepSize = 28.0,
    this.connectorWidth = 20.0,
    this.connectorHeight = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildSteps(),
    );
  }

  List<Widget> _buildSteps() {
    List<Widget> steps = [];

    for (int index = 0; index < totalSteps; index++) {
      final stepNumber = index + 1;
      final isActive = stepNumber == currentStep;
      final isCompleted = stepNumber < currentStep;

      steps.add(_buildStepCircle(stepNumber, isActive, isCompleted));

      if (index < totalSteps - 1) {
        steps.add(_buildConnector(stepNumber < currentStep));
      }
    }

    return steps;
  }

  Widget _buildStepCircle(int stepNumber, bool isActive, bool isCompleted) {
    return Container(
      width: stepSize,
      height: stepSize,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? activeColor : inactiveColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? activeColor : Colors.grey.shade400,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: altSecondary.withValues(alpha: 0.7),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: Colors.white, size: stepSize * 0.55)
            : Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: isActive || isCompleted
                      ? Colors.white
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: stepSize * 0.42,
                  decoration: TextDecoration.none,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: connectorWidth,
      height: connectorHeight,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isCompleted ? completedColor : inactiveColor,
        borderRadius: BorderRadius.circular(connectorHeight / 2),
      ),
    );
  }
}

class CompactTutorialStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const CompactTutorialStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = primary,
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: TextStyle(
            fontSize: 12,
            color: activeColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(totalSteps, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: index < currentStep ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ],
    );
  }
}
