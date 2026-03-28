import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../models/registration_draft.dart';
import '../models/registration_request.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import 'registration_screen.dart';
import 'registration_success_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final RegistrationDraft? draft;

  const OtpVerificationScreen({super.key, required this.mobileNumber, this.draft});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  
  Timer? _timer;
  int _start = 35; // Countdown start time
  final int _maxTime = 35;
  bool _isResendEnabled = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _start = _maxTime;
      _isResendEnabled = false;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    final otp = _otpController.text;
    
    if (otp.length == 6) {
      setState(() => _isVerifying = true);
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.verifyOtp(mobile: widget.mobileNumber, otp: otp);
      
      if (!mounted) return;
      
      if (response != null) {
        if (response.isNewUser && widget.draft != null) {
          // --- REGISTRATION FLOW ---
          final request = RegistrationRequest(
            name: widget.draft!.name,
            mobile: widget.draft!.mobile,
            dob: widget.draft!.dob!,
            gender: widget.draft!.gender ?? 'Male',
            bloodGroup: widget.draft!.bloodGroup,
            fatherName: widget.draft!.fatherName ?? '',
            voterId: widget.draft!.voterId,
            aadhaarNumber: widget.draft!.aadhaarNumber,
            street: widget.draft!.street!,
            doorNumber: widget.draft!.doorNumber!,
            village: widget.draft!.village!,
            taluk: widget.draft!.constituency!,
            district: widget.draft!.district!,
            state: widget.draft!.state ?? 'Tamil Nadu',
            pincode: widget.draft!.pincode!,
            verificationToken: authProvider.registrationVerificationToken!,
          );
          authProvider.setProfileImagePath(widget.draft!.profileImagePath);
          
          final success = await authProvider.registerMember(request);
          if (!mounted) return;
          
          setState(() => _isVerifying = false);
          
          if (success) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => RegistrationSuccessScreen(memberId: authProvider.currentUser?.memberId ?? 'UNKNOWN')),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? (isTamil ? "பதிவு தோல்வியடைந்தது" : "Registration Failed"))));
          }
        } else if (!response.isNewUser) {
          // --- LOGIN FLOW ---
          setState(() => _isVerifying = false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // Edge case: Logged in as unregistered user, but no draft available
          setState(() => _isVerifying = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RegistrationScreen(mobileNumber: widget.mobileNumber)),
          );
        }
      } else {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? (isTamil ? "தவறான OTP" : "Invalid OTP"))));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "6 இலக்க OTP ஐ உள்ளிடவும்" : "Please enter the 6-digit OTP")),
      );
    }
  }

  Future<void> _resendOtp() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.sendOtp(widget.mobileNumber);
    
    if (!mounted) return;
    
    if (success) {
      _otpController.clear();
      _startTimer();
      final debugOtp = authProvider.debugOtp;
      if (debugOtp != null && debugOtp.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTamil ? "OTP மீண்டும் அனுப்பப்பட்டது" : "OTP has been resent")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? (isTamil ? "OTP அனுப்ப முடியவில்லை" : "Failed to resend OTP"))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<LanguageProvider>().isTamil;

    // --- Pinput Styling to match the white rounded boxes ---
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Matched light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // --- TOP SHIELD ICON WITH SOFT GLOW ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8F9FA),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E2A5D).withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E2A5D), // Dark Blue
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security, // Closest matching icon
                    color: Color(0xFFFFB732), // Yellow
                    size: 28,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- HEADINGS ---
              Text(
                isTamil ? "உங்கள் மொபைலைச் சரிபார்க்கவும்" : "Check your phone",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isTamil ? "அனுப்பப்பட்ட 6 இலக்க குறியீட்டை உள்ளிடவும்" : "Enter the 6-digit code sent to",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "+91 ${widget.mobileNumber}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- 6-DIGIT OTP INPUT ---
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFF1E2A5D), width: 1.5),
                  ),
                ),
                showCursor: true,
                onCompleted: (pin) => _verifyOtp(),
              ),
              
              const SizedBox(height: 30),
              
              // --- PROGRESS BAR ---
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _start / _maxTime,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E2A5D)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // --- TIMER TEXT ---
              Text(
                isTamil ? "குறியீடு காலாவதியாகும் நேரம் 00:${_start.toString().padLeft(2, '0')}" : "Codes expire in 00:${_start.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- VERIFY BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB732), // Yellow
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: (_otpController.text.length == 6 && !_isVerifying) ? _verifyOtp : null,
                  child: _isVerifying 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 20, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              isTamil ? "சரிபார்" : "Verify",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // --- RESEND OTP BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey.shade700,
                    elevation: 0,
                    shadowColor: Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _isResendEnabled ? _resendOtp : null,
                  icon: Icon(
                    Icons.refresh, 
                    size: 20, 
                    color: _isResendEnabled ? Colors.grey.shade700 : Colors.grey.shade400
                  ),
                  label: Text(
                    isTamil ? "மீண்டும் அனுப்பு" : "Resend OTP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isResendEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}