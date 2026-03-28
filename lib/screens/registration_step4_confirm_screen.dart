import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/registration_draft.dart';
import '../models/registration_request.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/age_utils.dart';
import '../widgets/custom_stepper.dart';
import 'login_screen.dart';
import 'registration_success_screen.dart';
import 'otp_verification_screen.dart';

class RegistrationStep4ConfirmScreen extends StatefulWidget {
  final RegistrationDraft draft;

  const RegistrationStep4ConfirmScreen({super.key, required this.draft});

  @override
  State<RegistrationStep4ConfirmScreen> createState() => _RegistrationStep4ConfirmScreenState();
}

class _RegistrationStep4ConfirmScreenState extends State<RegistrationStep4ConfirmScreen> {
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    
    if (widget.draft.mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "மொபைல் எண் தேவை. முந்தைய திரைக்குச் சென்று உள்ளிடவும்." : "Mobile number is required. Please go back and enter it.")),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    final authProvider = context.read<AuthProvider>();

    // Send OTP to the user's mobile instead of finalizing registration immediately
    final success = await authProvider.sendOtp(widget.draft.mobile);
    
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final debugOtp = authProvider.debugOtp;
      if (debugOtp != null && debugOtp.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(
          mobileNumber: widget.draft.mobile,
          draft: widget.draft, // Pass the draft forward!
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? (isTamil ? "OTP அனுப்ப முடியவில்லை" : "Failed to send OTP"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final isTamil = context.watch<LanguageProvider>().isTamil;

    // Make status bar transparent for full blue header coverage
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF4F6FB),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 🔷 BLUE HEADER CARD - FULL WIDTH
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK BUTTON AND TITLE
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTamil ? "விவரங்களை உறுதிப்படுத்தவும்" : "Confirm Details",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // PROFILE INFO
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: DecorationImage(
                            image: draft.profileImageBytes != null 
                                ? MemoryImage(draft.profileImageBytes!) as ImageProvider
                                : const AssetImage(AppConfig.profileImageAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.name.isNotEmpty ? draft.name : (isTamil ? "பெயர் இல்லை" : "Name not provided"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "+91 ${draft.mobile}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // WHITE CONTENT AREA
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // --- STEPPER ---
                  CustomStepper(
                    currentStep: 3, // Step 4 active
                    onStepTapped: (index) {
                      if (index < 3) {
                        int pops = 3 - index;
                        for (int i = 0; i < pops; i++) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _baseCard(
                    children: [
                      _row(Icons.person, isTamil ? "முழு பெயர்" : "Full Name", draft.name.isNotEmpty ? draft.name : "-"),
                      _divider(),
                      _row(Icons.phone, isTamil ? "மொபைல் எண்" : "Mobile Number", draft.mobile),
                      _divider(),
                      _row(Icons.calendar_today, isTamil ? "பிறந்த தேதி" : "Date of Birth", draft.dob != null ? formatDateLong(draft.dob!) : "-"),
                      _divider(),
                      _row(Icons.people, isTamil ? "பாலினம்" : "Gender", draft.gender ?? "-"),
                      _divider(),
                      _row(Icons.person_outline, isTamil ? "தந்தை / பாதுகாவலர் பெயர்" : "Father / Guardian Name", (draft.fatherName?.isNotEmpty ?? false) ? draft.fatherName! : "-"),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _baseCard(
                    children: [
                      _sectionTitle(Icons.location_on, isTamil ? "முகவரி" : "Address"),
                      _divider(),
                      _row(Icons.location_on, isTamil ? "தெரு" : "Street", draft.street ?? "-"),
                      _divider(),
                      _row(Icons.home, isTamil ? "கதவு எண்" : "Door No", draft.doorNumber ?? "-"),
                      _divider(),
                      _row(Icons.location_city, isTamil ? "கிராமம்/நகரம்" : "City / Village", draft.village ?? "-"),
                      _divider(),
                      _row(Icons.map, isTamil ? "மாவட்டம்" : "District", draft.district ?? "-"),
                      _divider(),
                      _row(Icons.place, isTamil ? "தொகுதி" : "Constituency", draft.constituency ?? "-"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _button(isTamil),

                  const SizedBox(height: 20), // bottom safe spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baseCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E2A78), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(color: Colors.grey.shade200),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _button(bool isTamil) {
    return InkWell(
      onTap: _isSubmitting ? null : _submitRegistration,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: _isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              isTamil ? "உறுதிசெய்து OTP அனுப்பு" : "Send OTP & Register",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
      ),
    );
  }
}