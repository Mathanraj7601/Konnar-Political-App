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
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final mobile = _mobileController.text.trim();
    final userExists = await authProvider.checkUserExists(mobile);

    if (!mounted) return;

    if (userExists == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Unable to verify user"),
        ),
      );
      return;
    }

    // Navigate to registration if user doesn't exist
    if (!userExists) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(mobileNumber: mobile),
        ),
      );
      return;
    }

    // User exists - proceed with OTP flow
    final success = await authProvider.sendOtp(mobile);
    if (!mounted) return;

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Very light modern slate-blue tinted background
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // --- ENHANCED BACKGROUND DESIGN ---
            Container(
              height: size.height * 0.42,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            // Decorative Background Circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // --- FOREGROUND CONTENT ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Enhanced Profile Avatar with glowing borders
                    Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppConfig.profileImageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppTheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primary,
                                    size: 50,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    AlternatingWordText(
                      text: AppConfig.partyName,
                      firstColor: Colors.white,
                      secondColor: AppTheme.secondary,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Member Portal",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- ENHANCED FLOATING FORM CARD ---
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.lock_person_rounded,
                                    color: AppTheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Secure Login",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Enter your registered mobile number to continue",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            AppTextField(
                              controller: _mobileController,
                              label: "Mobile Number",
                              hintText: "Enter 10-digit number",
                              prefixIcon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                final input = value?.trim() ?? "";
                                if (input.isEmpty)
                                  return "Mobile number is required";
                                if (!RegExp(r"^\d{10}$").hasMatch(input))
                                  return "Enter a valid 10-digit mobile number";
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                label: "Send OTP",
                                icon: Icons.arrow_forward_rounded,
                                isLoading: authProvider.isLoading,
                                onPressed: _sendOtp,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have a member account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _goToRegistration,
                                  child: const Text(
                                    "Create New Member",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Footer Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Secured by 256-bit encryption",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
