import 'package:flutter/material.dart';

class CustomStepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int step;
  final int totalSteps;

  const CustomStepAppBar({
    super.key,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Use the background color of your screens (looks like off-white/light gray)
      backgroundColor: const Color(0xFFF8F9FA), 
      elevation: 0,
      centerTitle: true, // Forces the title to be dead center
      
      // Explicitly set the back button on the left
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),

      // Set the Step tracker as the centered title
      title: Text(
        'Step $step of $totalSteps',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}