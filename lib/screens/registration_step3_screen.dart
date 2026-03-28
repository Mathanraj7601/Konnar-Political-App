import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../data/tamil_nadu_electoral_data.dart';
import '../models/registration_draft.dart';
import '../models/registration_request.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_stepper.dart';
import '../widgets/form_input_field.dart';
import 'login_screen.dart';
import 'registration_step4_confirm_screen.dart';

class RegistrationStep3Screen extends StatefulWidget {
  final RegistrationDraft draft;
  const RegistrationStep3Screen({super.key, required this.draft});

  @override
  State<RegistrationStep3Screen> createState() => _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  late final RegistrationDraft _draft;

  final _streetController = TextEditingController();
  final _doorNoController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _villageController = TextEditingController();

  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _streetController.text = _draft.street ?? '';
    _doorNoController.text = _draft.doorNumber ?? '';
    _pincodeController.text = _draft.pincode ?? '';
    _villageController.text = _draft.village ?? '';
  }

  @override
  void dispose() {
    _streetController.dispose();
    _doorNoController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    if (!_formKey.currentState!.validate()) return;

    // Update draft from controllers
    _draft.street = _streetController.text.trim();
    _draft.doorNumber = _doorNoController.text.trim();
    _draft.pincode = _pincodeController.text.trim();
    _draft.village = _villageController.text.trim();

    // Route to Confirmation Step
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegistrationStep4ConfirmScreen(draft: _draft)),
    );
  }

  Future<void> _getCurrentLocation() async {
    final isTamil = context.read<LanguageProvider>().isTamil;
    setState(() => _isLocating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(isTamil ? 'இட அனுமதிகள் மறுக்கப்பட்டுள்ளன' : 'Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception(isTamil ? 'இட அனுமதிகள் நிரந்தரமாக மறுக்கப்பட்டுள்ளன. ஆப் அமைப்புகளில் அதை இயக்கவும்.' : 'Location permissions are permanently denied. Please enable it in app settings.');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Attempt to find a matching district
        String? matchedDistrict;
        final geocodedDistrictName = place.subAdministrativeArea ?? '';
        if (geocodedDistrictName.isNotEmpty) {
          for (final district in TamilNaduElectoralData.districts) {
            if (geocodedDistrictName.toLowerCase().contains(district.toLowerCase())) {
              matchedDistrict = district;
              break;
            }
          }
        }

        setState(() {
          // IMPROVED BINDING LOGIC:
          // 1. subThoroughfare is usually the building/door number
          String doorNo = place.subThoroughfare ?? '';
          
          // 2. thoroughfare is the street name, subLocality is the area
          String street = <String?>[place.thoroughfare, place.subLocality]
              .whereType<String>()
              .where((e) => e.trim().isNotEmpty && e != doorNo) // Don't duplicate door no in street
              .join(', ');

          // 3. locality is usually the city, town, or village
          String village = place.locality ?? place.administrativeArea ?? '';

          _doorNoController.text = doorNo.trim();
          _streetController.text = street.trim();
          _pincodeController.text = place.postalCode ?? '';
          _villageController.text = village.trim();
          
          if (matchedDistrict != null) {
            _draft.district = matchedDistrict;
            _draft.constituency = null; // Reset constituency to avoid errors
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      
      if (errorMsg.toLowerCase().contains("null") || errorMsg.contains("PlatformException")) {
        errorMsg = isTamil 
            ? "முகவரியைக் கண்டறிய முடியவில்லை. தயவுசெய்து கைமுறையாக உள்ளிடவும்." 
            : "Could not automatically detect address. Please enter it manually.";
      } else {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // Data for all Indian states and UTs
  static const List<String> _indianStates = [
    'Andaman and Nicobar Islands', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 
    'Chandigarh', 'Chhattisgarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Goa', 
    'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 
    'Kerala', 'Ladakh', 'Lakshadweep', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 
    'Mizoram', 'Nagaland', 'Odisha', 'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim', 
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<LanguageProvider>().isTamil;
    final authProvider = context.watch<AuthProvider>();
    final constituencyOptions = _draft.district == null ? <String>[] : TamilNaduElectoralData.constituenciesForDistrict(_draft.district!);
    const List<String> steps = ['Personal', 'Identity', 'Address', 'Confirm'];
    const int currentStep = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Overall app background
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
            Text(isTamil ? "குடியிருப்பு முகவரி" : "Residential Address", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(isTamil ? "உங்கள் இருப்பிடத்தை நாங்கள் கண்டறிவோம்..." : "We'll auto-detect your location for accu...", style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            CustomStepper(
              currentStep: currentStep,
              steps: steps,
              onStepTapped: (index) {
                if (index < currentStep) {
                  int pops = currentStep - index;
                  for (int i = 0; i < pops; i++) Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      
                      // --- UPDATED MAP/LOCATION CARD ---
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // Using the light grey theme from your image
                          color: const Color(0xFFF6F7F9), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            // Centered Red Location Pin
                            const Icon(
                              Icons.location_on, 
                              color: Color(0xFFEA4335), // Google Maps Red
                              size: 48
                            ),
                            const Spacer(),
                            // Dark Blue Button inside the card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E2A5D), // Dark blue from your design
                                    foregroundColor: const Color(0xFFFFB732), // Yellow text/icon color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLocating ? null : _getCurrentLocation,
                                  icon: _isLocating 
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFFFFB732), strokeWidth: 2))
                                      : const Icon(Icons.near_me, size: 20),
                                  label: Text(
                                    _isLocating ? (isTamil ? "கண்டுபிடிக்கிறது..." : "Locating...") : (isTamil ? "தற்போதைய இருப்பிடத்தைப் பயன்படுத்தவும்" : "Use Current Location"),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --- END MAP SECTION ---

                      FormInputField(
                          controller: _streetController, 
                          label: isTamil ? "தெரு பெயர்" : "Street Name", 
                          hintText: isTamil ? "தெரு பெயரை உள்ளிடவும்" : "Enter street name",
                          prefixIcon: Icons.location_on, 
                          validator: (v) => (v?.isEmpty ?? true) ? "Required" : null),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: FormInputField(
                                  controller: _doorNoController, 
                                  label: isTamil ? "கதவு எண்" : "Door No.", 
                                  hintText: isTamil ? "கதவு எண்" : "Door number",
                                  prefixIcon: Icons.pin_drop, 
                                  validator: (v) => (v?.isEmpty ?? true) ? "Required" : null)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: FormInputField(
                                  controller: _pincodeController, 
                                  label: isTamil ? "அஞ்சல் குறியீடு" : "Pincode", 
                                  hintText: isTamil ? "6 இலக்கங்கள்" : "6-digit code",
                                  prefixIcon: Icons.markunread_mailbox, 
                                  keyboardType: TextInputType.number, 
                                  maxLength: 6, 
                                  validator: (v) => (v?.length ?? 0) != 6 ? "6 digits" : null)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FormInputField(
                          controller: _villageController, 
                          label: isTamil ? "கிராமம் / நகரம்" : "Village / City", 
                          hintText: isTamil ? "கிராமம் அல்லது நகரத்தை உள்ளிடவும்" : "Enter village or city",
                          prefixIcon: Icons.location_city, 
                          validator: (v) => (v?.isEmpty ?? true) ? "Required" : null),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: TamilNaduElectoralData.districts.contains(_draft.district)
                            ? _draft.district
                            : null,
                        isExpanded: true,
                        hint: Text(isTamil ? "மாவட்டத்தை தேர்ந்தெடுக்கவும்" : "Select District"),
                        items: TamilNaduElectoralData.districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) => setState(() {
                          _draft.district = val;
                          _draft.constituency = null;
                        }),
                        decoration: InputDecoration(
                          labelText: isTamil ? "மாவட்டம்" : "District",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF142C8E), width: 1.5)),
                        ),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: constituencyOptions.contains(_draft.constituency)
                            ? _draft.constituency
                            : null,
                        isExpanded: true,
                        hint: Text(isTamil ? "தொகுதியை தேர்ந்தெடுக்கவும்" : "Select Constituency"),
                        items: constituencyOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _draft.constituency = val),
                        decoration: InputDecoration(
                          labelText: isTamil ? "தொகுதி" : "Constituency",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF142C8E), width: 1.5)),
                        ),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _indianStates.contains(_draft.state) 
                            ? _draft.state 
                            : null,
                        isExpanded: true,
                        hint: Text(isTamil ? "மாநிலத்தைத் தேர்ந்தெடுக்கவும்" : "Select State"),
                        items: _indianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _draft.state = val),
                        decoration: InputDecoration(
                          labelText: isTamil ? "மாநிலம்" : "State",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF142C8E), width: 1.5)),
                        ),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB732), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                onPressed: authProvider.isLoading ? null : _submit,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Row(
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