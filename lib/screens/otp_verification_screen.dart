import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../config/app_config.dart";
import "../providers/auth_provider.dart";
import "../theme/app_theme.dart";
import "../widgets/alternating_word_text.dart";
import "../widgets/app_text_field.dart";
import "../widgets/primary_button.dart";
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

  Timer? _timer;
  int _remainingSeconds = AppConfig.otpExpirySeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = AppConfig.otpExpirySeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _remainingSeconds = 0;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, "0");
    final seconds = (totalSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.verifyOtp(
      mobile: widget.mobileNumber,
      otp: _otpController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "OTP verification failed"),
        ),
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

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Could not resend OTP"),
        ),
      );
      return;
    }

    _startTimer();

    final debugOtp = authProvider.debugOtp;
    if (debugOtp != null && debugOtp.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AlternatingWordText(
                  text: "Enter OTP",
                  firstColor: AppTheme.primary,
                  secondColor: AppTheme.secondary,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sent to +91 ${widget.mobileNumber}",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _otpController,
                  label: "6-digit OTP",
                  prefixIcon: Icons.password,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final input = value?.trim() ?? "";
                    if (!RegExp(r"^\d{6}$").hasMatch(input)) {
                      return "Enter a valid 6-digit OTP";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  _remainingSeconds > 0
                      ? "OTP expires in ${_formatTimer(_remainingSeconds)}"
                      : "OTP expired",
                  style: TextStyle(
                    color: _remainingSeconds > 0
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.75)
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: "Verify OTP",
                  icon: Icons.verified_user,
                  isLoading: authProvider.isLoading,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _remainingSeconds == 0 && !authProvider.isLoading
                      ? _resendOtp
                      : null,
                  child: const Text("Resend OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
