import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/language_provider.dart";
import "../theme/app_theme.dart";
import "../widgets/primary_button.dart";
import "member_card_screen.dart";

class RegistrationSuccessScreen extends StatefulWidget {
  final String memberId;

  const RegistrationSuccessScreen({super.key, required this.memberId});

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  void _openMemberCard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MemberCardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<LanguageProvider>().isTamil;

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                        color: Colors.green.withOpacity(0.1),
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
                
                Text(
                  isTamil ? "பதிவு வெற்றிகரமானது!" : "Registration Successful!",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  isTamil ? "${AppConfig.partyName} குடும்பத்திற்கு உங்களை வரவேற்கிறோம்." : "Welcome to the ${AppConfig.partyName} family.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (widget.memberId.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isTamil ? "உங்கள் உறுப்பினர் எண்" : "Your Member ID",
                          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.memberId,
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Text(
                  isTamil ? "உங்கள் பதிவு செய்யப்பட்ட அலைபேசி எண்ணிற்கு SMS உறுதிப்படுத்தல் அனுப்பப்பட்டுள்ளது." : "An SMS confirmation has been sent to your registered mobile number.",
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                PrimaryButton(
                  label: isTamil ? "உறுப்பினர் அட்டையைக் காண்க" : "View Member Card",
                  icon: Icons.credit_card_rounded,
                  onPressed: _openMemberCard,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isTamil ? "பகிர்தல் திரை திறக்கிறது..." : "Opening share menu...")),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: Text(isTamil ? "பகிரவும்" : "Share"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}