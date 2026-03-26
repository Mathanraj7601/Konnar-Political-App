import "dart:io";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:provider/provider.dart";

import "../models/registration_draft.dart";
import "../providers/auth_provider.dart";
import "../providers/language_provider.dart";
import "../utils/age_utils.dart";
import "address_info_screen.dart";
import "login_screen.dart";

class PersonalInfoScreen extends StatefulWidget {
  final String mobileNumber;
  final String? initialName;

  const PersonalInfoScreen({
    super.key,
    required this.mobileNumber,
    this.initialName,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime? _selectedDob;
  String? _profileImagePath;
  String? _profileImageBytes; // For web support

  // Theme Colors - Matching Address Info Screen
  final Color _blueTheme = const Color(0xFF1223B3); // Blue
  final Color _yellowAccent = const Color(0xFFFFD100); // Yellow
  final Color _bgOffWhite = const Color(
    0xFFF6F4EE,
  ); // Light Beige/Off-white background

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final latestAllowedDob = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: latestAllowedDob,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: _blueTheme)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final age = calculateAge(picked);
      setState(() {
        _selectedDob = picked;
        _dobController.text = formatDateLong(picked);
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    try {
      final selectedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1400,
      );

      if (selectedImage != null && mounted) {
        // For web, we need to read the bytes
        final bytes = await selectedImage.readAsBytes();

        setState(() {
          _profileImagePath = selectedImage.path;
          _profileImageBytes = String.fromCharCodes(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(isTamil ? 'படம் தேர்ந்தெடுப்பதில் பிழை: $e' : 'Error picking image: $e')));
    }
  }

  void _next() {
    final isTamil = context.read<LanguageProvider>().isTamil;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "பிறந்த தேதியை தேர்ந்தெடுக்கவும்" : "Please select date of birth")),
      );
      return;
    }

    final age = int.tryParse(_ageController.text) ?? 0;
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "உறுப்பினருக்கு குறைந்தபட்சம் 18 வயது இருக்க வேண்டும்" : "Member must be at least 18 years old")),
      );
      return;
    }

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "சுயவிவர புகைப்படத்தை பதிவேற்றவும்" : "Please upload profile photo")),
      );
      return;
    }

    final draft = RegistrationDraft(
      name: _nameController.text.trim(),
      mobile: widget.mobileNumber,
      dob: _selectedDob!,
      age: age,
      profileImagePath: _profileImagePath,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddressInfoScreen(draft: draft)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _buildFieldLayout(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _blueTheme, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isTamil = context.watch<LanguageProvider>().isTamil;

    if (provider.registrationVerificationToken == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isTamil ? "அமர்வு முடிந்தது" : "Session Expired")),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
            child: Text(isTamil ? "உள்நுழையவும்" : "Back to Login"),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgOffWhite,
      appBar: AppBar(
        title: Text(
          isTamil ? "படி 1: தனிப்பட்ட விவரங்கள்" : "Step 1: Personal Info",
          style: TextStyle(fontWeight: FontWeight.bold, color: _blueTheme),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _blueTheme,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTamil ? "உறுப்பினர் விவரங்கள்" : "Member Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _blueTheme,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Upload Section (Matching Image exactly)
                      Text(
                        isTamil ? "புகைப்படம் பதிவேற்றவும்" : "Upload Photo",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _blueTheme.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _blueTheme.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_profileImageBytes != null &&
                                _profileImageBytes!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  Uint8List.fromList(
                                    _profileImageBytes!.codeUnits,
                                  ),
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              )
                            else if (_profileImagePath != null &&
                                _profileImagePath!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_profileImagePath!),
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _yellowAccent,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: _blueTheme,
                                ),
                              ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickProfileImage(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isTamil ? "புகைப்படம் எடு" : "Take Photo",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _blueTheme,
                                      foregroundColor: _yellowAccent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickProfileImage(ImageSource.gallery),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.black87,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isTamil ? "கேலரி" : "Gallery",
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Rest of Personal Info
                      _buildFieldLayout(
                        isTamil ? "அலைபேசி எண்" : "Mobile Number",
                        TextFormField(
                          initialValue: widget.mobileNumber,
                          readOnly: true,
                          decoration: _inputDeco(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLayout(
                        isTamil ? "முழு பெயர்" : "Full Name",
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDeco(),
                          validator: (val) => (val?.trim() ?? "").length < 3
                              ? (isTamil ? "தேவை" : "Required")
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFieldLayout(
                              isTamil ? "பிறந்த தேதி" : "Date of Birth",
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                onTap: _pickDob,
                                decoration: _inputDeco().copyWith(
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: _blueTheme,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) =>
                                    (val ?? "").isEmpty ? (isTamil ? "தேவை" : "Required") : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildFieldLayout(
                              isTamil ? "வயது" : "Age",
                              TextFormField(
                                controller: _ageController,
                                readOnly: true,
                                decoration: _inputDeco(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blueTheme,
                      foregroundColor: _yellowAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: _yellowAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isTamil ? "முகவரிக்குத் தொடரவும்" : "Continue to Address",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
