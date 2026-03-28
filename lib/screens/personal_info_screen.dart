import "dart:io";
import "dart:typed_data";
import "dart:ui";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:provider/provider.dart";

import "../models/registration_draft.dart";
import "../providers/auth_provider.dart";
import "../providers/language_provider.dart";
import "../utils/age_utils.dart";
import "address_info_screen.dart";
import "login_screen.dart";
import '../widgets/custom_stepper.dart';

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
  late final TextEditingController _mobileController;
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime? _selectedDob;
  String? _profileImagePath;
  String? _profileImageBytes; 

  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Theme Colors from Image
  final Color _deepBlue = const Color(0xFF142C8E); 
  final Color _bgOffWhite = const Color(0xFFF3F5F9); 
  final Color _iconBg = const Color(0xFFEEF2FF);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _mobileController = TextEditingController(text: widget.mobileNumber);
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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _deepBlue),
          ),
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
        final bytes = await selectedImage.readAsBytes();
        setState(() {
          _profileImagePath = selectedImage.path;
          _profileImageBytes = String.fromCharCodes(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? 'படம் தேர்ந்தெடுப்பதில் பிழை: $e' : 'Error picking image: $e'))
      );
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

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTamil ? "சுயவிவர புகைப்படத்தை பதிவேற்றவும்" : "Please upload profile photo")),
      );
      return;
    }

    final age = int.tryParse(_ageController.text) ?? 0;

    final draft = RegistrationDraft(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      dob: _selectedDob!,
      age: age,
      profileImagePath: _profileImagePath,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      // Pass gender and blood group to your draft model here if needed
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddressInfoScreen(draft: draft)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(IconData? prefixIcon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _deepBlue, width: 1.5),
      ),
      prefixIcon: prefixIcon != null ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: _iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(prefixIcon, color: _deepBlue, size: 20),
        ),
      ) : null,
    );
  }

  Widget _buildFieldLayout(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isTamil = context.watch<LanguageProvider>().isTamil;
    const List<String> steps = ['Personal', 'Identity', 'Address', 'Confirm'];
    const int currentStep = 0;

    return Scaffold(
      backgroundColor: _bgOffWhite,
      appBar: AppBar(
        backgroundColor: _bgOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),

                // --- HEADER ---
                Center(
                  child: Column(
                    children: [
                      Text(
                        isTamil ? "உறுப்பினர் கணக்கை உருவாக்கவும்" : "Create Member Account",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "உறுப்பினர் பதிவு",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- STEPPER ---
                CustomStepper(
                  currentStep: currentStep,
                  steps: steps,
                  // The activeColor is already set to match this screen's theme.
                ),
                const SizedBox(height: 32),

                // --- PERSONAL INFORMATION SECTION ---
                const Center(
                  child: Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PROFILE PHOTO UPLOAD (From Image 2) ---
                      const Text(
                        "Profile Photo",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      CustomPaint(
                        painter: DashedRectPainter(
                          color: Colors.grey.shade300,
                          strokeWidth: 2,
                          gap: 6,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Stack(
                              children: [
                                // Image Box
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20), // Rounded square
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: _profileImagePath != null
                                        ? Image.file(
                                            File(_profileImagePath!),
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.person, size: 45, color: Colors.grey.shade400),
                                  ),
                                ),
                                // Edit Badge
                                Positioned(
                                  bottom: -5,
                                  right: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Color(0xFF142C8E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Action Buttons (Take Photo / Gallery)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickProfileImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, color: Color(0xFF142C8E), size: 18),
                              label: Text(
                                isTamil ? "புகைப்படம் எடு" : "Take Photo",
                                style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickProfileImage(ImageSource.gallery),
                              icon: const Icon(Icons.image, color: Color(0xFF142C8E), size: 18),
                              label: Text(
                                isTamil ? "கேலரி" : "Gallery",
                                style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade100, thickness: 1.5),
                      const SizedBox(height: 20),

                      // --- FORM FIELDS ---
                      _buildFieldLayout(
                        isTamil ? "முழு பெயர்" : "Full Name",
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDeco(Icons.person),
                          validator: (val) => (val?.trim() ?? "").length < 3 ? "Required" : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLayout(
                        isTamil ? "மொபைல் எண்" : "Mobile Number",
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: _inputDeco(Icons.phone),
                          validator: (val) {
                            final input = val?.trim() ?? "";
                            if (input.isEmpty) return isTamil ? "தேவை" : "Required";
                            if (!RegExp(r"^\d{10}$").hasMatch(input)) {
                              return isTamil ? "சரியான எண்ணை உள்ளிடவும்" : "Invalid Number";
                            }
                            return null;
                          },
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
                                decoration: _inputDeco(Icons.calendar_month).copyWith(
                                  hintText: isTamil ? "தேதியைத் தேர்ந்தெடுக்கவும்" : "Select Date",
                                  hintStyle: TextStyle(color: Colors.grey.shade400)
                                ),
                                validator: (val) => (val ?? "").isEmpty ? "Required" : null,
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
                                textAlign: TextAlign.center,
                                decoration: _inputDeco(null),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFieldLayout(
                              isTamil ? "பாலினம்" : "Gender",
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                decoration: _inputDeco(Icons.person_outline).copyWith(hintText: isTamil ? "பாலினத்தைத் தேர்ந்தெடுக்கவும்" : "Select Gender"),
                                items: _genders.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                validator: (val) => val == null ? (isTamil ? "தேவை" : "Required") : null,
                                onChanged: (val) => setState(() => _selectedGender = val),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFieldLayout(
                              isTamil ? "இரத்த வகை" : "Blood Group",
                              DropdownButtonFormField<String>(
                                value: _selectedBloodGroup,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                decoration: _inputDeco(null).copyWith(hintText: isTamil ? "குழுவைத் தேர்ந்தெடுக்கவும்" : "Select Group"),
                                items: _bloodGroups.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedBloodGroup = val),
                                validator: (val) => val == null ? "Required" : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- BOTTOM CONTINUE BUTTON ---
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD34E), Color(0xFFFFB020)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR DASHED BORDER AROUND PHOTO ---
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    var rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height), 
      const Radius.circular(16)
    );
    path.addRRect(rrect);

    var metrics = path.computeMetrics();
    var dashedPath = Path();
    for (var metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}