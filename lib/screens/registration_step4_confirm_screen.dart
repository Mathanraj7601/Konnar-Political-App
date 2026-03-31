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

  void _editDetails() {
    // Navigate back to the first screen (step 0)
    // currentStep is 3, so we need to pop 3 times.
    const int popsToFirstScreen = 3;
    for (int i = 0; i < popsToFirstScreen; i++) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

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
    const List<String> steps = ['Personal', 'Identity', 'Address', 'Confirm'];
    const int currentStep = 3;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF4F6FB),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        child: Column(
          children: [
            // --- STEP X OF Y TITLE ---
            Center(
              child: Text(
                isTamil
                    ? "படி ${currentStep + 1} / ${steps.length}"
                    : "Step ${currentStep + 1} of ${steps.length}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              isTamil ? "விவரங்களை உறுதிப்படுத்தவும்" : "Confirm Details",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              isTamil ? "உங்கள் தகவலைச் சரிபார்க்கவும்" : "Review your information",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            // --- STEPPER ---
            CustomStepper(
              currentStep: currentStep,
              steps: steps,
              onStepTapped: (index) {
                if (index < currentStep) {
                  int pops = currentStep - index;
                  for (int i = 0; i < pops; i++) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            // 🔥 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _card(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: draft.profileImageBytes != null 
                        ? MemoryImage(draft.profileImageBytes!) as ImageProvider
                        : const AssetImage(AppConfig.profileImageAsset),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.name.isNotEmpty ? draft.name : (isTamil ? "பெயர் இல்லை" : "Name not provided"),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+91 ${draft.mobile}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔲 DETAILS CARD
            _cardSection([
              _row(Icons.person, isTamil ? "முழு பெயர்" : "Full Name", draft.name.isNotEmpty ? draft.name : "-"),
              _divider(),
              _row(Icons.phone, isTamil ? "மொபைல் எண்" : "Mobile Number", draft.mobile),
              _divider(),
              _row(Icons.calendar_today, isTamil ? "பிறந்த தேதி" : "Date of Birth", draft.dob != null ? formatDateLong(draft.dob!) : "-"),
              _divider(),
              _row(Icons.people, isTamil ? "பாலினம்" : "Gender", draft.gender ?? "-"),
              _divider(),
              _row(Icons.person_outline, isTamil ? "தந்தை / பாதுகாவலர் பெயர்" : "Father / Guardian Name", (draft.fatherName?.isNotEmpty ?? false) ? draft.fatherName! : "-"),
            ]),

            const SizedBox(height: 16),

            // 📍 ADDRESS CARD
            _cardSection([
              _sectionTitle(Icons.location_on, isTamil ? "முகவரி" : "Address"),
              _divider(),
              _row(Icons.location_on, isTamil ? "தெரு" : "Street", draft.street ?? "-"),
              _divider(),
              _row(Icons.home, isTamil ? "கதவு எண்" : "Door No", draft.doorNumber ?? "-"),
              _divider(),
              _row(Icons.location_city, isTamil ? "கிராமம்/நகரம்" : "City / Village", draft.village ?? "-"),
              _divider(),
              _row(Icons.groups_2_outlined, isTamil ? "ஒன்றியம்" : "Union", (draft.union?.isNotEmpty ?? false) ? draft.union! : "-"),
              _divider(),
              _row(Icons.map, isTamil ? "மாவட்டம்" : "District", draft.district ?? "-"),
              _divider(),
              _row(Icons.place, isTamil ? "தொகுதி" : "Constituency", draft.constituency ?? "-"),
            ]),

            const SizedBox(height: 24),

            // 🔘 BUTTONS
            Row(
              children: [
                // EDIT BUTTON
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _editDetails,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E2A78),
                        side: const BorderSide(color: Color(0xFF1E2A78), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isTamil ? "திருத்து" : "Edit",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // REGISTER BUTTON
                Expanded(
                  child: InkWell(
                    onTap: _isSubmitting ? null : _submitRegistration,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isTamil ? "பதிவு செய்" : "Register",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔲 CARD WRAPPER
  Widget _cardSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _card(),
      child: Column(children: children),
    );
  }

  // 🔹 ROW ITEM
  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(12),
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

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    );
  }
}