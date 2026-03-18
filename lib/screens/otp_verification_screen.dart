import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "member_card_screen.dart";
import "personal_info_screen.dart";

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String? prefilledName;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
    this.prefilledName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds = AppConfig.otpExpirySeconds;

  // Exact Colors from your previous yellow theme mockup
  final Color _yellowTheme = const Color(0xFFFFBF43);

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Add listener to update custom OTP boxes when user types
    _otpController.addListener(() {
      if (mounted) setState(() {});
    });
    
    // Auto-focus the OTP field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNode);
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = AppConfig.otpExpirySeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
        return;
      }
      if (mounted) setState(() => _remainingSeconds -= 1);
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, "0");
    final seconds = (totalSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  Future<void> _verifyOtp() async {
    final otpText = _otpController.text.trim();
    if (otpText.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.verifyOtp(
      mobile: widget.mobileNumber,
      otp: otpText,
    );

    if (!mounted) return;

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "OTP verification failed")),
      );
      return;
    }

    if (response.isNewUser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PersonalInfoScreen(
            mobileNumber: widget.mobileNumber,
            initialName: widget.prefilledName,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MemberCardScreen()),
      (route) => false,
    );
  }

  Future<void> _resendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(widget.mobileNumber);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Could not resend OTP")),
      );
      return;
    }

    _otpController.clear();
    _startTimer();
    FocusScope.of(context).requestFocus(_otpFocusNode);

    final debugOtp = authProvider.debugOtp;
    if (debugOtp != null && debugOtp.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  // Custom widget to draw each digit box
  Widget _buildOtpBox(int index) {
    final text = _otpController.text;
    final isFocused = _otpFocusNode.hasFocus && text.length == index;
    final hasData = text.length > index;
    final digit = hasData ? text[index] : "";

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused 
              ? Colors.black87 
              : hasData 
                  ? Colors.grey.shade500 
                  : Colors.grey.shade300,
          width: isFocused ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isExpired = _remainingSeconds == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // We will build a custom back button
        title: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade500, size: 18),
              const SizedBox(width: 4),
              Text(
                "Go Back",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // --- TITLES ---
                const Text(
                  "Check your phone",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We've sent the code to +91 ${widget.mobileNumber}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 40),

                // --- CUSTOM OTP BOXES ---
                SizedBox(
                  height: 60,
                  child: Stack(
                    children: [
                      // Invisible TextField to handle actual keyboard input
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(counterText: ""),
                            showCursor: false,
                          ),
                        ),
                      ),
                      // Visual Overlay for the boxes
                      IgnorePointer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => _buildOtpBox(index)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- TIMER TEXT ---
                RichText(
                  text: TextSpan(
                    text: isExpired ? "Code expired " : "Code expires in: ",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: isExpired ? "Please resend" : _formatTimer(_remainingSeconds),
                        style: TextStyle(
                          color: isExpired ? Colors.red.shade600 : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- BUTTONS ---
                // Verify Button (Yellow Pill)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellowTheme,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Send Again Button (Outlined Pill)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isExpired && !authProvider.isLoading ? _resendOtp : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(
                        color: isExpired ? Colors.grey.shade400 : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      "Send again",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isExpired ? Colors.black87 : Colors.grey.shade400,
                      ),
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