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
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _redirectTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      _openMemberCard();
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.check, color: AppTheme.secondary, size: 48),
                ),
                const SizedBox(height: 16),
                const AlternatingWordText(
                  text: "Registration Successful",
                  firstColor: AppTheme.primary,
                  secondColor: AppTheme.secondary,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome to ${AppConfig.partyName}.",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (widget.memberId.isNotEmpty)
                  Text(
                    "Member ID: ${widget.memberId}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  "SMS confirmation has been triggered to your registered mobile number.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: "Open Member Card",
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
