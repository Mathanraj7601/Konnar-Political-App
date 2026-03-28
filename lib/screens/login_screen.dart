import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "../providers/language_provider.dart";
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

    if (!userExists) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(mobileNumber: mobile),
        ),
      );
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Demo OTP: $debugOtp"))
      );
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
    final isTamil = context.watch<LanguageProvider>().isTamil;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Matched light background
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // --- DEEP BLUE CURVED BACKGROUND ---
            Container(
              height: size.height * 0.48, // Slightly adjusted for better proportion
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF142C8E), // Deep royal blue
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35), // Smoother curve
                  bottomRight: Radius.circular(35),
                ),
              ),
            ),

            // --- FOREGROUND CONTENT ---
            SafeArea(
              child: Column(
                children: [
                  // --- LANGUAGE SWITCHER ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 8.0),
                      child: TextButton.icon(
                        onPressed: () => context.read<LanguageProvider>().toggleLanguage(),
                        icon: const Icon(Icons.language, color: Colors.white70, size: 18),
                        label: Text(
                          isTamil ? "English" : "தமிழ்",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // --- GLOWING PROFILE AVATAR ---
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700), // Gold border
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4), // Soft Gold glow
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppConfig.profileImageAsset, // Ensure this path is correct
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF142C8E),
                                size: 45,
                              ),
                            ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // --- BULL LOGO ---
                  const Icon(
                    Icons.pest_control_rodent_outlined, // Placeholder - Swap with your asset!
                    color: Color(0xFFFFD700),
                    size: 45,
                  ),
                  
                  const SizedBox(height: 8),

                  // --- TITLES ---
                  const Text(
                    "ஆயர் புரட்சி கழகம்",
                    style: TextStyle(
                      color: Color(0xFFFFD700), // Gold text
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ஒற்றுமை • வளர்ச்சி • சக்தி",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 35),

                  // --- WHITE LOGIN CARD ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 24,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Sign in to your member account",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                const Text(
                                  "Mobile Number",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // --- EXACT TEXT FIELD MATCH ---
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 11,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                                    _PhoneNumberFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "Enter your mobile number",
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                    
                                    // ADDED: The specific light-blue background behind the phone icon
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8EEFF), // Light blue background
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.phone, color: Color(0xFF1E2A5D), size: 16),
                                      ),
                                    ),
                                    
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1E2A5D)),
                                    ),
                                  ),
                                  validator: (value) {
                                    final input = value?.replaceAll(' ', '').trim() ?? "";
                                    if (input.isEmpty) {
                                      return isTamil ? "மொபைல் எண் தேவை" : "Mobile number is required";
                                    }
                                    if (!RegExp(r"^\d{10}$").hasMatch(input)) {
                                      return isTamil ? "சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்" : "Enter a valid 10-digit mobile number";
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 24),

                                // --- GRADIENT BUTTON ---
                                Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFCC33), // Lighter Yellow
                                        Color(0xFFFFB020), // Darker Orange/Amber
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _sendOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.arrow_forward, color: Colors.black87, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                "Send OTP",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // --- FOOTER RICH TEXT ---
                                Center(
                                  child: GestureDetector(
                                    onTap: _goToRegistration,
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: "Create New Member",
                                            style: TextStyle(
                                              color: Color(0xFF1E2A5D), // Dark Blue
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- SECURITY BADGE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield, // Filled shield fits design better
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Secured with 256-bit encryption",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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