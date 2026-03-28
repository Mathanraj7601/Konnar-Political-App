import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomStepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int step;
  final int totalSteps;

  const CustomStepAppBar({
    super.key,
    required this.title,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: (step - 1) / totalSteps,
              end: step / totalSteps,
            ),
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}