import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:provider/provider.dart";

import "../models/registration_draft.dart";
import "../providers/auth_provider.dart";
import "../utils/age_utils.dart";
import "../widgets/app_text_field.dart";
import "../widgets/primary_button.dart";
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
    );

    if (picked == null) {
      return;
    }

    final age = calculateAge(picked);

    setState(() {
      _selectedDob = picked;
      _dobController.text = formatDateLong(picked);
      _ageController.text = age.toString();
    });
  }

  Future<void> _pickProfileImage() async {
    final selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1400,
    );

    if (selectedImage == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _profileImagePath = selectedImage.path;
    });
  }

  void _removeProfileImage() {
    setState(() {
      _profileImagePath = null;
    });
  }

  void _next() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date of birth")),
      );
      return;
    }

    final age = int.tryParse(_ageController.text) ?? 0;

    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member must be at least 18 years old")),
      );
      return;
    }

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload profile photo")),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.registrationVerificationToken == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Session Expired")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "OTP verification is required before registration.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: "Back to Login",
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Step 1: Personal Info")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: _profileImagePath != null
                                ? Image.file(
                                    File(_profileImagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 42,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 38,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _pickProfileImage,
                        icon: const Icon(Icons.upload),
                        label: Text(
                          _profileImagePath == null
                              ? "Upload Photo"
                              : "Change Photo",
                        ),
                      ),
                      if (_profileImagePath != null)
                        TextButton(
                          onPressed: _removeProfileImage,
                          child: const Text("Remove"),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  initialValue: widget.mobileNumber,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _nameController,
                  label: "Full Name",
                  prefixIcon: Icons.person,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.length < 3) {
                      return "Name must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _dobController,
                  label: "Date of Birth",
                  prefixIcon: Icons.cake,
                  readOnly: true,
                  onTap: _pickDob,
                  validator: (value) {
                    if ((value ?? "").isEmpty) {
                      return "Date of birth is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _ageController,
                  label: "Age",
                  prefixIcon: Icons.badge,
                  readOnly: true,
                  validator: (value) {
                    final age = int.tryParse(value ?? "") ?? 0;
                    if (age < 18) {
                      return "Age must be 18 or above";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: "Continue to Address",
                  icon: Icons.arrow_forward,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
