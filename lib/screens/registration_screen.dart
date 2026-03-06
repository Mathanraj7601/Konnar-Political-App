import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../providers/auth_provider.dart";
import "../widgets/app_text_field.dart";
import "../widgets/primary_button.dart";
import "otp_verification_screen.dart";

class RegistrationScreen extends StatefulWidget {
  final String mobileNumber;

  const RegistrationScreen({super.key, required this.mobileNumber});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mobileController;
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _voterIdController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(text: widget.mobileNumber);
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final mobile = _mobileController.text.trim();

    final registered = await authProvider.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: mobile,
    );

    if (!mounted) {
      return;
    }

    if (!registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Registration failed"),
        ),
      );
      return;
    }

    final otpSent = await authProvider.sendOtp(mobile);

    if (!mounted) {
      return;
    }

    if (!otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Failed to send OTP")),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Text("Registration Completed Successfully!"),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    final debugOtp = authProvider.debugOtp;
    if (debugOtp != null && debugOtp.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Demo OTP: $debugOtp")));
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          mobileNumber: mobile,
          prefilledName: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _fatherNameController.dispose();
    _voterIdController.dispose();
    _aadhaarController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _mobileController,
                  label: "Mobile Number",
                  hintText: "Enter 10-digit mobile number",
                  prefixIcon: Icons.phone_android,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final mobile = value?.trim() ?? "";
                    if (mobile.isEmpty) {
                      return "Mobile number is required";
                    }
                    if (!RegExp(r"^\d{10}$").hasMatch(mobile)) {
                      return "Enter a valid 10-digit mobile number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: "Full Name",
                  prefixIcon: Icons.person,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.length < 3) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _fatherNameController,
                  label: "Father Name",
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.length < 3) {
                      return "Father name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const ["Male", "Female", "Other"]
                      .map(
                        (gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Gender is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _voterIdController,
                  label: "Voter ID",
                  hintText: "Enter voter ID",
                  prefixIcon: Icons.badge,
                  validator: (value) {
                    final voterId = value?.trim() ?? "";
                    if (voterId.isEmpty) {
                      return "Voter ID is required";
                    }

                    if (!RegExp(r"^[A-Za-z0-9]{6,20}$").hasMatch(voterId)) {
                      return "Enter a valid voter ID";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _aadhaarController,
                  label: "Aadhaar Number",
                  hintText: "Enter 12-digit Aadhaar number",
                  prefixIcon: Icons.fingerprint,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final aadhaar = value?.trim() ?? "";
                    if (aadhaar.isEmpty) {
                      return "Aadhaar number is required";
                    }
                    if (!RegExp(r"^\d{12}$").hasMatch(aadhaar)) {
                      return "Enter a valid 12-digit Aadhaar number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: "Email",
                  hintText: "Optional",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? "";

                    if (email.isEmpty) {
                      return null;
                    }

                    const pattern = r"^[^\s@]+@[^\s@]+\.[^\s@]+$";
                    if (!RegExp(pattern).hasMatch(email)) {
                      return "Enter a valid email";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: "Submit & Get OTP",
                  icon: Icons.sms_outlined,
                  isLoading: authProvider.isLoading,
                  onPressed: _submitRegistration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
