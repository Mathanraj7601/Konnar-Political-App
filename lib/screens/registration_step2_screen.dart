import 'dart:io';
import 'package:flutter/material.dart';
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
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _draft.idProofPath = result.files.single.path;
      });
    }
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(isTamil ? "அடையாள விவரங்கள்" : "Identity Details", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(isTamil ? "உங்களைப் பற்றி மேலும் சொல்லுங்கள்" : "Tell us more about yourself", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            CustomStepper(
              currentStep: 1,
              onStepTapped: (index) {
                if (index < 1) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormInputField(controller: _fatherNameController, label: isTamil ? "தந்தை / பாதுகாவலர் பெயர்" : "Father's / Guardian's Name", prefixIcon: Icons.person, validator: (v) => (v?.isEmpty ?? true) ? (isTamil ? "தேவை" : "Required") : null),
                    const SizedBox(height: 20),
                    FormInputField(controller: _voterIdController, label: isTamil ? "வாக்காளர் அடையாள அட்டை எண்" : "Voter ID Number", prefixIcon: Icons.how_to_vote),
                    const SizedBox(height: 20),
                    FormInputField(controller: _aadhaarController, label: isTamil ? "ஆதார் எண்" : "Aadhaar Number", prefixIcon: Icons.fingerprint, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    Text(isTamil ? "அடையாளச் சான்றை பதிவேற்றவும் (விருப்பத்தேர்வு)" : "Upload ID Proof (Optional)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                          child: _draft.idProofPath != null
                              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Flexible(child: Text(_draft.idProofPath!.split('/').last.split('\\').last, overflow: TextOverflow.ellipsis))])
                              : Column(children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.upload_file, color: Color(0xFF1E2A5D), size: 20), const SizedBox(width: 8), Text(isTamil ? "ஆவணத்தைப் பதிவேற்று" : "Upload Document", style: const TextStyle(color: Color(0xFF1E2A5D), fontWeight: FontWeight.bold))]),
                                  const SizedBox(height: 8),
                                  Text(isTamil ? "JPG, PNG அல்லது PDF (அதிகபட்சம் 2MB)" : "JPG, PNG or PDF (Max 2MB)", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB732), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                onPressed: _next,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isTamil ? "தொடரவும்" : "Continue", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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