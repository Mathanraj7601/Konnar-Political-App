import 'package:flutter/material.dart';

/// A customizable stepper widget that shows progress through a series of steps.
///
/// It visually distinguishes between completed, active, and inactive steps.
class CustomStepper extends StatelessWidget {
  /// The index of the current active step, starting from 0.
  final int currentStep;

  /// The list of labels for the steps.
  final List<String> steps;

  /// The color used for active and completed steps.
  final Color activeColor;

  /// The color used for inactive steps.
  final Color inactiveColor;

  /// Callback when a step is tapped.
  final ValueChanged<int>? onStepTapped;

  const CustomStepper({
    super.key,
    required this.currentStep,
    this.steps = const ['Personal', 'Identity', 'Address', 'Confirm'],
    this.activeColor = const Color(0xFF142C8E), // Matches PersonalInfoScreen
    this.inactiveColor = const Color(0xFFE0E0E0), // A light grey
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          final stepIndex = index ~/ 2;

          // It's a connecting line
          if (index.isOdd) {
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                // Aligns the line with the center of the step circles
                margin: const EdgeInsets.only(bottom: 28, left: 4, right: 4),
                color: isCompleted ? activeColor : inactiveColor,
              ),
            );
          }

          // It's a step node
          final isCompleted = stepIndex < currentStep;
          final isActive = stepIndex == currentStep;

          return GestureDetector(
            onTap: onStepTapped != null ? () => onStepTapped!(stepIndex) : null,
            behavior: HitTestBehavior.opaque,
            child: _buildStepNode(
              stepIndex: stepIndex,
              isCompleted: isCompleted,
              isActive: isActive,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepNode({
    required int stepIndex,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor;
    Color borderColor;
    Color labelColor;
    FontWeight labelWeight;
    Widget child;

    if (isActive) {
      circleColor = activeColor;
      borderColor = activeColor;
      labelColor = Colors.black87;
      labelWeight = FontWeight.w700;
      child = Text(
        '${stepIndex + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (isCompleted) {
      circleColor = activeColor;
      borderColor = activeColor;
      labelColor = Colors.black87;
      labelWeight = FontWeight.w500;
      child = const Icon(Icons.check, color: Colors.white, size: 20);
    } else { // Inactive
      circleColor = Colors.white;
      borderColor = inactiveColor;
      labelColor = Colors.grey.shade500;
      labelWeight = FontWeight.w500;
      child = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: !isCompleted && !isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                : [],
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 8),
        Text(
          steps[stepIndex],
          style: TextStyle(
            fontSize: 12,
            color: labelColor,
            fontWeight: labelWeight,
          ),
        ),
      ],
    );
  }
}