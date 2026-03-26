import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../data/tamil_nadu_electoral_data.dart";
import "../models/registration_draft.dart";
import "../models/registration_request.dart";
import "../providers/auth_provider.dart";
import "../providers/language_provider.dart";
import "login_screen.dart";
import "registration_success_screen.dart";

class AddressInfoScreen extends StatefulWidget {
  final RegistrationDraft draft;

  const AddressInfoScreen({super.key, required this.draft});

  @override
  State<AddressInfoScreen> createState() => _AddressInfoScreenState();
}

class _AddressInfoScreenState extends State<AddressInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _doorNumberController = TextEditingController();
  final _villageController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedConstituency;

  // Exact Colors from Mockup
  final Color _blueTheme = const Color(0xFF1223B3); // Blue
  final Color _yellowAccent = const Color(0xFFFFD100); // Yellow
  final Color _bgOffWhite = const Color(
    0xFFF6F4EE,
  ); // Light Beige/Off-white background

  Future<void> _submit() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDistrict == null || _selectedConstituency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTamil ? "மாவட்டம் மற்றும் தொகுதியை தேர்ந்தெடுக்கவும்" : "Please select district and constituency"),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final verificationToken = authProvider.registrationVerificationToken;

    if (verificationToken == null || verificationToken.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTamil ? "OTP சரிபார்ப்பு காலாவதியானது. மீண்டும் உள்நுழையவும்." : "OTP verification expired. Please login again."),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    final request = RegistrationRequest(
      name: widget.draft.name,
      mobile: widget.draft.mobile,
      dob: widget.draft.dob,
      street: _streetController.text.trim(),
      doorNumber: _doorNumberController.text.trim(),
      village: "${_villageController.text.trim()}, $_selectedDistrict",
      taluk: _selectedConstituency!,
      pincode: _pincodeController.text.trim(),
      verificationToken: verificationToken,
    );

    authProvider.setProfileImagePath(widget.draft.profileImagePath);
    final success = await authProvider.registerMember(request);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? (isTamil ? "பதிவு தோல்வியடைந்தது" : "Registration failed")),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RegistrationSuccessScreen(
          memberId: authProvider.currentUser?.memberId ?? "",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _doorNumberController.dispose();
    _villageController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Helper to build the bold labels above fields
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper to generate the pill-shaped input decoration
  InputDecoration _pillDecoration({String? hintText, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey.shade400, size: 20)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: _blueTheme, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isTamil = context.watch<LanguageProvider>().isTamil;
    final size = MediaQuery.of(context).size;

    final constituencyOptions = _selectedDistrict == null
        ? const <String>[]
        : TamilNaduElectoralData.constituenciesForDistrict(_selectedDistrict!);
    final showStateWideFallback =
        _selectedDistrict != null &&
        !TamilNaduElectoralData.hasSpecificDistrictMapping(_selectedDistrict!);

    return Scaffold(
      backgroundColor: _bgOffWhite, // Off-white background from mockup
      body: Stack(
        children: [
          // TOP BLUE BACKGROUND WITH YELLOW ACCENT
          Container(
            height: size.height * 0.45,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_blueTheme, _blueTheme.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // HEADER TEXT
                  Text(
                    isTamil ? "முகவரி விவரங்கள்" : "Address Info",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 255, 255, 255),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil ? "பதிவை முடிக்கவும்" : "Complete Registration",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // WHITE FORM CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header
                          Center(
                            child: Text(
                              isTamil ? "இட விவரங்கள்" : "Location Details",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              isTamil ? "தேர்தல் வரைபடத்திற்காக உங்கள் இருப்பிட முகவரி விவரங்களை வழங்கவும்." : "Please provide your residential address details for electoral mapping.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Street Field
                          _buildLabel(isTamil ? "தெரு பெயர்" : "Street Name"),
                          TextFormField(
                            controller: _streetController,
                            decoration: _pillDecoration(
                              hintText: isTamil ? "தெரு பெயரை உள்ளிடவும்" : "Enter street name",
                              suffixIcon: Icons.location_on,
                            ),
                            validator: (value) =>
                                (value ?? "").trim().length < 3
                                ? (isTamil ? "தெரு பெயர் தேவை" : "Street is required")
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Side-by-Side: Door Number & Pincode (To match mockup layout)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(isTamil ? "கதவு எண்" : "Door No."),
                                    TextFormField(
                                      controller: _doorNumberController,
                                      decoration: _pillDecoration(
                                        hintText: isTamil ? "எண்." : "No.",
                                      ),
                                      validator: (value) =>
                                          (value ?? "").trim().isEmpty
                                          ? (isTamil ? "தேவை" : "Required")
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(isTamil ? "அஞ்சல் குறியீடு" : "Pincode"),
                                    TextFormField(
                                      controller: _pincodeController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      decoration: _pillDecoration(
                                        hintText: isTamil ? "6 இலக்கங்கள்" : "6 digits",
                                      ).copyWith(counterText: ""),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (value) =>
                                          !RegExp(
                                            r"^\d{6}$",
                                          ).hasMatch((value ?? "").trim())
                                          ? (isTamil ? "தவறானது" : "Invalid")
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Village Field
                          _buildLabel(isTamil ? "கிராமம் / நகரம்" : "Village / City"),
                          TextFormField(
                            controller: _villageController,
                            decoration: _pillDecoration(
                              hintText: isTamil ? "கிராமம் அல்லது நகரத்தை உள்ளிடவும்" : "Enter village or city",
                              suffixIcon: Icons.location_city,
                            ),
                            validator: (value) =>
                                (value ?? "").trim().length < 2
                                ? (isTamil ? "கிராமம் / நகரம் தேவை" : "Village / City is required")
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // District Dropdown
                          _buildLabel(isTamil ? "மாவட்டம்" : "District"),
                          DropdownButtonFormField<String>(
                            value: _selectedDistrict,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade400,
                            ),
                            decoration: _pillDecoration(),
                            hint: Text(
                              isTamil ? "மாவட்டத்தை தேர்ந்தெடுக்கவும்" : "Select District",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                            items: TamilNaduElectoralData.districts
                                .map(
                                  (district) => DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  ),
                                )
                                .toList(),
                            validator: (value) => value == null || value.isEmpty
                                ? (isTamil ? "மாவட்டம் தேவை" : "District is required")
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _selectedDistrict = value;
                                _selectedConstituency = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Constituency Dropdown
                          _buildLabel(isTamil ? "தொகுதி" : "Constituency"),
                          DropdownButtonFormField<String>(
                            value:
                                constituencyOptions.contains(
                                  _selectedConstituency,
                                )
                                ? _selectedConstituency
                                : null,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade400,
                            ),
                            decoration: _pillDecoration(),
                            hint: Text(
                              isTamil ? "தொகுதியை தேர்ந்தெடுக்கவும்" : "Select Constituency",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                            items: constituencyOptions
                                .map(
                                  (constituency) => DropdownMenuItem(
                                    value: constituency,
                                    child: Text(constituency),
                                  ),
                                )
                                .toList(),
                            validator: (value) => value == null || value.isEmpty
                                ? (isTamil ? "தொகுதி தேவை" : "Constituency is required")
                                : null,
                            onChanged: _selectedDistrict == null
                                ? null
                                : (value) {
                                    setState(
                                      () => _selectedConstituency = value,
                                    );
                                  },
                          ),

                          if (_selectedDistrict == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text(
                                isTamil ? "தொகுதிகளை ஏற்ற முதலில் மாவட்டத்தைத் தேர்ந்தெடுக்கவும்." : "Select district first to load constituencies.",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (showStateWideFallback)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text(
                                isTamil ? "முழு தமிழ்நாடு தொகுதி பட்டியலைக் காட்டுகிறது." : "Showing full Tamil Nadu constituency list.",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // State Field (Read-only)
                          _buildLabel(isTamil ? "மாநிலம்" : "State"),
                          TextFormField(
                            readOnly: true,
                            initialValue: TamilNaduElectoralData.state,
                            style: TextStyle(color: Colors.grey.shade600),
                            decoration: _pillDecoration(
                              suffixIcon: Icons.flag,
                            ).copyWith(fillColor: Colors.grey.shade50),
                          ),
                          const SizedBox(height: 30),

                          // SAVE & CONTINUE BUTTON (Blue Pill)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _blueTheme,
                                foregroundColor: _yellowAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: _yellowAccent,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isTamil ? "சேமித்து தொடரவும்" : "Save & Continue",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // BACK TO LOGIN TEXT BUTTON
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87,
                              ),
                              child: Text(
                                isTamil ? "உள்நுழையவும்" : "Back to Login",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
