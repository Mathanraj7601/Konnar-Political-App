import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/registration_draft.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_stepper.dart';
import '../widgets/form_input_field.dart';
import 'registration_step3_screen.dart';

class RegistrationStep2Screen extends StatefulWidget {
  final RegistrationDraft draft;
  const RegistrationStep2Screen({super.key, required this.draft});

  @override
  State<RegistrationStep2Screen> createState() => _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  late final RegistrationDraft _draft;

  final _fatherNameController = TextEditingController();
  final _voterIdController = TextEditingController();
  final _aadhaarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _fatherNameController.text = _draft.fatherName ?? '';
    _voterIdController.text = _draft.voterId ?? '';
    _aadhaarController.text = _draft.aadhaarNumber ?? '';
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _voterIdController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _pickIdProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true, // Ensures bytes are loaded, crucial for web support
    );

    if (result != null && result.files.single != null) {
      final file = result.files.single;
      setState(() {
        if (!kIsWeb) {
          _draft.idProofPath = file.path; // Path is only available on mobile
        }
        _draft.idProofBytes = file.bytes; // Bytes for web/other platforms
        _draft.idProofName = file.name; // Name for display
      });
    }
  }

  void _next() {
    final isTamil = context.read<LanguageProvider>().isTamil;
    if (_formKey.currentState!.validate()) {
      // Check if a file has been picked (either path or bytes should exist)
      if ((_draft.idProofPath == null || _draft.idProofPath!.isEmpty) && _draft.idProofBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isTamil ? "அடையாளச் சான்றை பதிவேற்றவும்" : "Please upload ID proof")),
        );
        return;
      }

      _draft.fatherName = _fatherNameController.text.trim();
      _draft.voterId = _voterIdController.text.trim();
      _draft.aadhaarNumber = _aadhaarController.text.trim();

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RegistrationStep3Screen(draft: _draft)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<LanguageProvider>().isTamil;
    const List<String> steps = ['Personal', 'Identity', 'Address', 'Confirm'];
    const int currentStep = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Text(isTamil ? "அடையாள விவரங்கள்" : "Identity Details",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(
                isTamil ? "உங்களைப் பற்றி மேலும் சொல்லுங்கள்" : "Tell us more about yourself",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            CustomStepper(
              currentStep: currentStep,
              steps: steps,
              onStepTapped: (index) {
                if (index < currentStep) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormInputField(
                        controller: _fatherNameController,
                        label: isTamil
                            ? "தந்தை / பாதுகாவலர் பெயர்"
                            : "Father's / Guardian's Name",
                        hintText: isTamil 
                            ? "தந்தை/பாதுகாவலர் பெயரை உள்ளிடவும்" 
                            : "Enter father/guardian name",
                        prefixIcon: Icons.person,
                        validator: (v) => (v?.isEmpty ?? true)
                            ? (isTamil ? "தேவை" : "Required")
                            : null),
                    const SizedBox(height: 20),
                    FormInputField(
                        controller: _aadhaarController,
                        label: isTamil ? "ஆதார் எண்" : "Aadhaar Number",
                        hintText: isTamil ? "12 இலக்க ஆதார் எண்" : "12-digit Aadhaar number",
                        prefixIcon: Icons.fingerprint,
                        keyboardType: TextInputType.number,
                        maxLength: 12),
                    const SizedBox(height: 20),
                    FormInputField(
                        controller: _voterIdController,
                        label: isTamil ? "வாக்காளர் அடையாள அட்டை எண்" : "Voter ID Number",
                        hintText: isTamil ? "வாக்காளர் அடையாள எண்ணை உள்ளிடவும்" : "Enter voter ID number",
                        prefixIcon: Icons.how_to_vote),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(text: isTamil ? "அடையாளச் சான்றை பதிவேற்றவும்" : "Upload ID Proof"),
                          const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickIdProof,
                      child: DottedBorder(
                        color: Colors.grey.shade400,
                        strokeWidth: 1.5,
                        dashPattern: const [8, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _draft.idProofName != null && _draft.idProofName!.isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Flexible(child: Text(_draft.idProofName!, overflow: TextOverflow.ellipsis))
                                    ])
                              : Column(children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Icon(Icons.upload_file, color: Color(0xFF1E2A5D), size: 20),
                                    const SizedBox(width: 8),
                                    Text(isTamil ? "ஆவணத்தைப் பதிவேற்று" : "Upload Document", style: const TextStyle(color: Color(0xFF1E2A5D), fontWeight: FontWeight.bold))
                                  ]),
                                  const SizedBox(height: 8),
                                  Text(isTamil ? "JPG, PNG அல்லது PDF" : "JPG, PNG or PDF", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB732),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0),
                onPressed: _next,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isTamil ? "தொடரவும்" : "Continue",
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}