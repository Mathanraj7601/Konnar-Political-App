import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../providers/auth_provider.dart";
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

  // Theme Colors - Matching Address Info Screen
  final Color _blueTheme = const Color(0xFF1223B3); // Blue
  final Color _yellowAccent = const Color(0xFFFFD100); // Yellow
  final Color _bgOffWhite = const Color(
    0xFFF6F4EE,
  ); // Light Beige/Off-white background

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(text: widget.mobileNumber);
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final mobile = _mobileController.text.trim();

    final registered = await authProvider.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: mobile,
    );

    if (!mounted) return;

    if (!registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Registration failed"),
        ),
      );
      return;
    }

    final otpSent = await authProvider.sendOtp(mobile);
    if (!mounted) return;

    if (!otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Failed to send OTP"),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                "Registration Initialized!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Routing to verification...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
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

  // Helper to build fields matching the image style
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

  InputDecoration _inputDeco({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
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
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _bgOffWhite,
      appBar: AppBar(
        title: Text(
          "Create Member Account",
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
                  "Become a Member",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _blueTheme,
                  ),
                ),
                const Text(
                  "உறுப்பினர் பதிவு",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                      _buildFieldLayout(
                        "Mobile Number",
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _inputDeco(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "+91",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          validator: (val) {
                            if ((val?.trim() ?? "").isEmpty) return "Required";
                            if (!RegExp(r"^\d{10}$").hasMatch(val!))
                              return "Invalid 10-digit number";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildFieldLayout(
                        "Full Name",
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDeco(
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (val) => (val?.trim() ?? "").length < 3
                              ? "Name required"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLayout(
                        "Father's Name",
                        TextFormField(
                          controller: _fatherNameController,
                          decoration: _inputDeco(
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          validator: (val) => (val?.trim() ?? "").length < 3
                              ? "Required"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLayout(
                        "Email (Optional)",
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDeco(
                            hintText: "name@example.com",
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFieldLayout(
                              "Gender",
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: _inputDeco(),
                                items: const ["Male", "Female", "Other"]
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedGender = val),
                                validator: (val) =>
                                    val == null ? "Required" : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFieldLayout(
                              "Voter ID",
                              TextFormField(
                                controller: _voterIdController,
                                decoration: _inputDeco(),
                                validator: (val) => (val?.trim() ?? "").isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLayout(
                        "Aadhaar Number",
                        TextFormField(
                          controller: _aadhaarController,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _inputDeco(
                            prefixIcon: const Icon(Icons.fingerprint),
                          ),
                          validator: (val) => (val?.trim() ?? "").length != 12
                              ? "Invalid Aadhaar"
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blueTheme,
                      foregroundColor: _yellowAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        : const Text(
                            "Submit & Get OTP",
                            style: TextStyle(
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
