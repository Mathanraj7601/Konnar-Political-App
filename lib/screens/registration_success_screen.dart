import "dart:async";

import "package:flutter/material.dart";

import "../config/app_config.dart";
import "../theme/app_theme.dart";
import "../widgets/alternating_word_text.dart";
import "../widgets/primary_button.dart";
import "member_card_screen.dart";

class RegistrationSuccessScreen extends StatefulWidget {
  final String memberId;

  const RegistrationSuccessScreen({super.key, required this.memberId});

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _openMemberCard();
    });
  }

  void _openMemberCard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MemberCardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Checkmark Effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                const AlternatingWordText(
                  text: "Registration Successful!",
                  firstColor: AppTheme.primary,
                  secondColor: Colors.black87,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  "Welcome to the ${AppConfig.partyName} family.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (widget.memberId.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Your Member ID",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.memberId,
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Text(
                  "An SMS confirmation has been sent to your registered mobile number.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                PrimaryButton(
                  label: "View Member Card",
                  icon: Icons.credit_card_rounded,
                  onPressed: _openMemberCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}