import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../data/tamil_nadu_electoral_data.dart";
import "../models/registration_draft.dart";
import "../models/registration_request.dart";
import "../providers/auth_provider.dart";
import "../widgets/app_text_field.dart";
import "../widgets/primary_button.dart";
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDistrict == null || _selectedConstituency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select district and constituency")),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final verificationToken = authProvider.registrationVerificationToken;

    if (verificationToken == null || verificationToken.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP verification expired. Please login again."),
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

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Registration failed"),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final constituencyOptions = _selectedDistrict == null
        ? const <String>[]
        : TamilNaduElectoralData.constituenciesForDistrict(_selectedDistrict!);
    final showStateWideFallback = _selectedDistrict != null &&
        !TamilNaduElectoralData.hasSpecificDistrictMapping(_selectedDistrict!);

    return Scaffold(
      appBar: AppBar(title: const Text("Step 2: Address Info")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Address details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _streetController,
                  label: "Street",
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if ((value ?? "").trim().length < 3) {
                      return "Street is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _doorNumberController,
                  label: "Door Number",
                  prefixIcon: Icons.home,
                  validator: (value) {
                    if ((value ?? "").trim().isEmpty) {
                      return "Door number is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _villageController,
                  label: "Village / City",
                  prefixIcon: Icons.location_city,
                  validator: (value) {
                    if ((value ?? "").trim().length < 2) {
                      return "Village / City is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  initialValue: TamilNaduElectoralData.state,
                  decoration: const InputDecoration(
                    labelText: "State",
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "District",
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: TamilNaduElectoralData.districts
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "District is required";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedConstituency = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: constituencyOptions.contains(_selectedConstituency)
                      ? _selectedConstituency
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Constituency",
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: constituencyOptions
                      .map(
                        (constituency) => DropdownMenuItem(
                          value: constituency,
                          child: Text(constituency),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Constituency is required";
                    }
                    return null;
                  },
                  onChanged: _selectedDistrict == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedConstituency = value;
                          });
                        },
                ),
                if (_selectedDistrict == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Select district first to load constituencies.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                    ),
                  ),
                ],
                if (showStateWideFallback) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Showing full Tamil Nadu constituency list for this district.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AppTextField(
                  controller: _pincodeController,
                  label: "Pincode",
                  prefixIcon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (!RegExp(r"^\d{6}$").hasMatch((value ?? "").trim())) {
                      return "Enter valid 6-digit pincode";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: "Submit Registration",
                  icon: Icons.check_circle,
                  isLoading: authProvider.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
