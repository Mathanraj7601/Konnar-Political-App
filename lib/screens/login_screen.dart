import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "../theme/app_theme.dart";
import "../widgets/alternating_word_text.dart";
import "../widgets/app_text_field.dart";
import "../widgets/primary_button.dart";
import "otp_verification_screen.dart";
import "registration_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  Future<void> _goToRegistration() async {
    final mobile = _mobileController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegistrationScreen(mobileNumber: mobile),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final mobile = _mobileController.text.trim();
    final userExists = await authProvider.checkUserExists(mobile);

    if (!mounted) {
      return;
    }

    if (userExists == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Unable to verify user"),
        ),
      );
      return;
    }

    if (!userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mobile number not registered. Please use Register."),
        ),
      );
      return;
    }

    final success = await authProvider.sendOtp(mobile);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Failed to send OTP"),
        ),
      );
      return;
    }

    final debugOtp = authProvider.debugOtp;

    if (debugOtp != null && debugOtp.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(mobileNumber: mobile),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppConfig.profileImageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AlternatingWordText(
                  text: AppConfig.partyName,
                  firstColor: AppTheme.primary,
                  secondColor: AppTheme.secondary,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AlternatingWordText(
                  text: "Member Login",
                  firstColor: AppTheme.primary,
                  secondColor: AppTheme.secondary,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _mobileController,
                  hintText: "Enter 10-digit mobile number",
                  prefixIcon: Icons.phone_android,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final input = value?.trim() ?? "";
                    if (input.isEmpty) {
                      return "Mobile number is required";
                    }
                    if (!RegExp(r"^\d{10}$").hasMatch(input)) {
                      return "Enter a valid 10-digit mobile number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: "Send OTP",
                  icon: Icons.sms_outlined,
                  isLoading: authProvider.isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: authProvider.isLoading ? null : _goToRegistration,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text("New user? Register"),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    "Use a verified mobile number. OTP expires in 2 minutes.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
