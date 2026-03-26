import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "../providers/language_provider.dart";
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start slightly below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _goToRegistration() async {
    final mobile = _mobileController.text.replaceAll(' ', '').trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegistrationScreen(mobileNumber: mobile),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final mobile = _mobileController.text.replaceAll(' ', '').trim();
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
    _animationController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final isTamil = langProvider.isTamil;
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
                    // --- LANGUAGE SWITCHER ---
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () => langProvider.toggleLanguage(),
                        icon: const Icon(Icons.language, color: Colors.white, size: 20),
                        label: Text(
                          isTamil ? "English" : "தமிழ்",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
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
                      isTamil ? "உறுப்பினர் தளம்" : "Member Portal",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- ENHANCED FLOATING FORM CARD ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
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
                                  Text(
                                    isTamil ? "பாதுகாப்பான உள்நுழைவு" : "Secure Login",
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
                                  isTamil ? "தொடர உங்கள் பதிவு செய்யப்பட்ட அலைபேசி எண்ணை உள்ளிடவும்" : "Enter your registered mobile number to continue",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 32),
    
                                AppTextField(
                                  controller: _mobileController,
                                  label: isTamil ? "அலைபேசி எண்" : "Mobile Number",
                                  hintText: isTamil ? "10 இலக்க எண்ணை உள்ளிடவும்" : "Enter 10-digit number",
                                  prefixIcon: Icons.phone_android_rounded,
                                  keyboardType: TextInputType.number,
                              maxLength: 11, // 10 digits + 1 space
                                  inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                                _PhoneNumberFormatter(),
                                  ],
                                  validator: (value) {
                                final input = value?.replaceAll(' ', '').trim() ?? "";
                                    if (input.isEmpty)
                                      return isTamil ? "அலைபேசி எண் தேவை" : "Mobile number is required";
                                    if (!RegExp(r"^\d{10}$").hasMatch(input))
                                      return isTamil ? "சரியான 10 இலக்க எண்ணை உள்ளிடவும்" : "Enter a valid 10-digit mobile number";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
    
                                SizedBox(
                                  width: double.infinity,
                                  child: PrimaryButton(
                                    label: isTamil ? "OTP-ஐ அனுப்பு" : "Send OTP",
                                    icon: Icons.arrow_forward_rounded,
                                    isLoading: authProvider.isLoading,
                                    onPressed: _sendOtp,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Text(
                                        isTamil ? "உறுப்பினர் கணக்கு இல்லையா? " : "Don't have a member account? ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _goToRegistration,
                                        child: Text(
                                          isTamil ? "புதிய உறுப்பினரை உருவாக்கு" : "Create New Member",
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
                                ),
                              ],
                            ),
                          ),
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
                          isTamil ? "256-பிட் குறியாக்கத்தால் பாதுகாக்கப்படுகிறது" : "Secured by 256-bit encryption",
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

/// Custom TextInputFormatter to format the mobile number as "XXXXX XXXXX"
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 4 && i != digitsOnly.length - 1) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
