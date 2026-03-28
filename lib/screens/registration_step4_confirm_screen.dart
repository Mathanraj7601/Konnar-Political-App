import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isTamil ? "விவரங்களை உறுதிப்படுத்தவும்" : "Confirm Details", style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 24),
            
            Text(
              isTamil ? "மதிப்பாய்வு செய்க" : "Review Details",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // --- HEADER PROFILE CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+91 ${draft.mobile}",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- PERSONAL DETAILS CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    title: isTamil ? "முழு பெயர்" : "Full Name",
                    value: draft.name.isNotEmpty ? draft.name : "-",
                  ),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    title: isTamil ? "மொபைல் எண்" : "Mobile Number",
                    value: draft.mobile,
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: isTamil ? "பிறந்த தேதி" : "Date of Birth",
                    value: draft.dob != null ? formatDateLong(draft.dob!) : "-",
                  ),
                  _buildDetailRow(
                    icon: Icons.people_outline,
                    title: isTamil ? "பாலினம்" : "Gender",
                    value: draft.gender ?? "-",
                  ),
                  _buildDetailRow(
                    icon: Icons.supervisor_account_outlined,
                    title: isTamil ? "தந்தை / பாதுகாவலர் பெயர்" : "Father / Guardian Name",
                    value: (draft.fatherName?.isNotEmpty ?? false) ? draft.fatherName! : "-",
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- ADDRESS DETAILS CARD ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5), // Slight cream/yellow tint
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildAddressRow(
                    icon: Icons.location_on,
                    iconBgColor: const Color(0xFFFFF3D6),
                    iconColor: const Color(0xFFFFB732),
                    title: isTamil ? "முகவரி" : "Address",
                    subtitle: "${isTamil ? "தெரு" : "Street"}: ${draft.street ?? '-'}",
                  ),
                  _buildAddressRow(
                    icon: Icons.home_work_outlined,
                    title: "${isTamil ? "கதவு எண்" : "Door No"}: ${draft.doorNumber ?? '-'}",
                    subtitle: "${isTamil ? "கிராமம்/நகரம்" : "City / Village"}: ${draft.village ?? '-'}\n${isTamil ? "அஞ்சல் குறியீடு" : "Pincode"}: ${draft.pincode ?? '-'}",
                  ),
                  _buildAddressRow(
                    icon: Icons.location_city_outlined,
                    title: "${isTamil ? "மாவட்டம்" : "District"}: ${draft.district ?? '-'}",
                    subtitle: "${isTamil ? "தொகுதி" : "Constituency"}: ${draft.constituency ?? '-'}",
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A5D), // Deep Blue matching the "Edit Profile" style
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 4,
                  shadowColor: const Color(0xFF1E2A5D).withOpacity(0.4),
                ),
                onPressed: _isSubmitting ? null : _submitRegistration,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isTamil ? "உறுதிசெய்து OTP அனுப்பு" : "Send OTP & Register",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE ROW WIDGET FOR PERSONAL DETAILS ---
  Widget _buildDetailRow({required IconData icon, required String title, required String value, bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE8EEFF), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF1E2A5D), size: 20)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade700))])),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: Colors.grey.shade200, indent: 64, endIndent: 16),
      ],
    );
  }

  // --- REUSABLE ROW WIDGET FOR ADDRESS DETAILS ---
  Widget _buildAddressRow({required IconData icon, required String title, required String subtitle, Color iconColor = const Color(0xFF1E2A5D), Color iconBgColor = const Color(0xFFE8EEFF), bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade700))])),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: Colors.grey.shade200, indent: 64, endIndent: 16),
      ],
    );
  }
}