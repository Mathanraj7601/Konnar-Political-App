// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final TextEditingController _nameController =
//       TextEditingController(text: "Arjun Kumar");
//   final TextEditingController _mobileController =
//       TextEditingController(text: "9876543210");
//   final TextEditingController _dobController =
//       TextEditingController(text: "15 Mar 2001");

//   String _selectedAge = "25";
//   String _selectedGender = "Male";
//   String _selectedBloodGroup = "O+";

//   // DYNAMIC: holds the picked image file; null = show default network image
//   File? _pickedImage;
//   final ImagePicker _picker = ImagePicker();

//   // DYNAMIC: pick image from camera or gallery
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? file = await _picker.pickImage(
//         source: source,
//         imageQuality: 85,
//         maxWidth: 800,
//       );
//       if (file != null) {
//         setState(() => _pickedImage = File(file.path));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Could not pick image: $e")),
//         );
//       }
//     }
//   }

//   // DYNAMIC: bottom sheet to choose camera or gallery
//   void _showImageSourceSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const Text(
//                 "Select Image Source",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8EAF6),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.camera_alt, color: Color(0xFF1E2A78)),
//                 ),
//                 title: const Text("Take Photo",
//                     style: TextStyle(fontWeight: FontWeight.w500)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8EAF6),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.photo_library,
//                       color: Color(0xFF1E2A78)),
//                 ),
//                 title: const Text("Choose from Gallery",
//                     style: TextStyle(fontWeight: FontWeight.w500)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Builder(
//           builder: (ctx) {
//             final w = MediaQuery.of(ctx).size.width;
//             final isTablet = w >= 768;
//             final isSmall = w < 360;
//             return IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.black87,
//                 size: isTablet ? 26 : (isSmall ? 20 : 24),
//               ),
//               onPressed: () => Navigator.pop(context),
//               padding: EdgeInsets.all(isTablet ? 16 : 12),
//               constraints: BoxConstraints(
//                 minWidth: isTablet ? 56 : 48,
//                 minHeight: isTablet ? 56 : 48,
//               ),
//             );
//           },
//         ),
//         title: const Text(
//           "Edit Profile",
//           style: TextStyle(
//               color: Colors.black87, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         titleSpacing: 0,
//       ),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [

//             // ── RESPONSIVE HEADER ──────────────────────────────────
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final screenW = constraints.maxWidth;
//                 final isTablet = screenW >= 768;
//                 final isSmall = screenW < 360;

//                 final avatarRadius =
//                     isTablet ? 64.0 : (isSmall ? 42.0 : 52.0);
//                 final ringPad = isTablet ? 6.0 : 4.0;
//                 final cameraIconSize =
//                     isTablet ? 22.0 : (isSmall ? 15.0 : 18.0);
//                 final cameraBtnPad =
//                     isTablet ? 10.0 : (isSmall ? 6.0 : 8.0);
//                 final headerHeight =
//                     isTablet ? 220.0 : (isSmall ? 160.0 : 190.0);
//                 final btnHeight =
//                     isTablet ? 52.0 : (isSmall ? 38.0 : 44.0);
//                 final btnFontSize =
//                     isTablet ? 15.0 : (isSmall ? 12.0 : 13.5);
//                 final btnIconSize =
//                     isTablet ? 20.0 : (isSmall ? 15.0 : 17.0);
//                 final btnHorizPad =
//                     isTablet ? 48.0 : (isSmall ? 20.0 : 32.0);

//                 return Column(
//                   children: [
//                     // Blue gradient banner + avatar
//                     Container(
//                       width: double.infinity,
//                       height: headerHeight,
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               // Glow + gold ring
//                               Container(
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: const Color(0xFFFFC107)
//                                           .withOpacity(0.55),
//                                       blurRadius: isTablet ? 50 : 36,
//                                       spreadRadius: isTablet ? 14 : 10,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Container(
//                                   padding: EdgeInsets.all(ringPad),
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Color(0xFFFFE082),
//                                         Color(0xFFF9A825),
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                   ),
//                                   // DYNAMIC: shows picked image or default
//                                   child: CircleAvatar(
//                                     radius: avatarRadius,
//                                     backgroundImage: _pickedImage != null
//                                         ? FileImage(_pickedImage!)
//                                             as ImageProvider
//                                         : const NetworkImage(
//                                             "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
//                                           ),
//                                   ),
//                                 ),
//                               ),

//                               // Camera badge — taps open source sheet
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () =>
//                                       _showImageSourceSheet(context),
//                                   child: Container(
//                                     padding: EdgeInsets.all(cameraBtnPad),
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFFFF3E0),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Icon(
//                                       Icons.camera_alt,
//                                       size: cameraIconSize,
//                                       color: const Color(0xFF1E2A78),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Take Photo / Gallery buttons — outside blue box
//                     Container(
//                       color: const Color(0xFFF4F6FB),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: btnHorizPad,
//                         vertical: isTablet ? 16 : 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: _headerBtn(
//                               icon: Icons.camera_alt,
//                               label: "Take Photo",
//                               height: btnHeight,
//                               fontSize: btnFontSize,
//                               iconSize: btnIconSize,
//                               // DYNAMIC: directly opens camera
//                               onTap: () => _pickImage(ImageSource.camera),
//                             ),
//                           ),
//                           SizedBox(width: isTablet ? 16 : 10),
//                           Expanded(
//                             child: _headerBtn(
//                               icon: Icons.photo_library,
//                               label: "Gallery",
//                               height: btnHeight,
//                               fontSize: btnFontSize,
//                               iconSize: btnIconSize,
//                               // DYNAMIC: directly opens gallery
//                               onTap: () => _pickImage(ImageSource.gallery),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),

//             // ── FORM CARD ──────────────────────────────────────────
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final screenW = constraints.maxWidth;
//                 final isTablet = screenW >= 768;
//                 final horizPad = isTablet ? 24.0 : 16.0;

//                 return Padding(
//                   padding: EdgeInsets.symmetric(horizontal: horizPad),
//                   child: Container(
//                     padding: EdgeInsets.all(isTablet ? 24 : 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [

//                         _label("Mobile Number"),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _mobileController,
//                           keyboardType: TextInputType.phone,
//                           style: const TextStyle(fontSize: 14),
//                           decoration: _inputDecoration(
//                             hint: "Enter mobile number",
//                             prefixIcon: const Icon(
//                               Icons.phone,
//                               size: 20,
//                               color: Color(0xFF1E2A78),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         _label("Full Name"),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _nameController,
//                           style: const TextStyle(fontSize: 14),
//                           decoration:
//                               _inputDecoration(hint: "Enter full name"),
//                         ),

//                         const SizedBox(height: 16),

//                         _label("Date of Birth"),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: GestureDetector(
//                                 onTap: () => _selectDate(context),
//                                 child: Container(
//                                   height: 50,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF9FAFB),
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                         color: const Color(0xFFE5E7EB)),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.calendar_today,
//                                           size: 20,
//                                           color: Color(0xFF1E2A78)),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           _dobController.text.isEmpty
//                                               ? "Select date"
//                                               : _dobController.text,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color:
//                                                 _dobController.text.isEmpty
//                                                     ? Colors.grey
//                                                     : Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _dropdownField(
//                                 "Age",
//                                 _selectedAge,
//                                 (v) => setState(() => _selectedAge = v),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         _label("Gender"),
//                         const SizedBox(height: 8),
//                         _dropdownField(
//                           "Gender",
//                           _selectedGender,
//                           (v) => setState(() => _selectedGender = v),
//                           prefixIcon: const Icon(Icons.person,
//                               size: 20, color: Color(0xFF1E2A78)),
//                         ),

//                         const SizedBox(height: 16),

//                         _label("Blood Group"),
//                         const SizedBox(height: 8),
//                         _dropdownField(
//                           "Blood Group",
//                           _selectedBloodGroup,
//                           (v) => setState(() => _selectedBloodGroup = v),
//                           prefixIcon: const Icon(Icons.water_drop,
//                               size: 20, color: Color(0xFF1E2A78)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 20),

//             // ── UPDATE BUTTON ────────────────────────────────────────
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final isTablet = constraints.maxWidth >= 768;
//                 return Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: isTablet ? 40 : 20),
//                   child: GestureDetector(
//                     onTap: _saveProfile,
//                     child: Container(
//                       height: isTablet ? 60 : 55,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFFDB913), Color(0xFFF59E0B)],
//                         ),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Update Profile",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: isTablet ? 17 : 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── HEADER BUTTON ─────────────────────────────────────────────────
//   Widget _headerBtn({
//     required IconData icon,
//     required String label,
//     required double height,
//     required double fontSize,
//     required double iconSize,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: iconSize, color: const Color(0xFF1E2A78)),
//             SizedBox(width: iconSize * 0.35),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF1E2A78),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── SHARED INPUT DECORATION ───────────────────────────────────────
//   InputDecoration _inputDecoration({String? hint, Widget? prefixIcon}) {
//     return InputDecoration(
//       filled: true,
//       fillColor: const Color(0xFFF9FAFB),
//       prefixIcon: prefixIcon,
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide:
//             const BorderSide(color: Color(0xFF1E2A78), width: 1.5),
//       ),
//     );
//   }

//   // ── LABEL ─────────────────────────────────────────────────────────
//   Widget _label(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontWeight: FontWeight.w700,
//         fontSize: 14,
//         color: Color(0xFF374151),
//       ),
//     );
//   }

//   // ── DROPDOWN FIELD ────────────────────────────────────────────────
//   Widget _dropdownField(
//     String label,
//     String value,
//     Function(String) onChanged, {
//     Widget? prefixIcon,
//   }) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           if (prefixIcon != null) ...[
//             const SizedBox(width: 12),
//             prefixIcon,
//             const SizedBox(width: 4),
//           ] else
//             const SizedBox(width: 12),
//           Expanded(
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 isExpanded: true,
//                 icon: const Icon(Icons.keyboard_arrow_down,
//                     color: Colors.black54),
//                 items: _getDropdownItems(label),
//                 onChanged: (String? newValue) {
//                   if (newValue != null) onChanged(newValue);
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//     );
//   }

//   // ── DROPDOWN ITEMS ────────────────────────────────────────────────
//   List<DropdownMenuItem<String>> _getDropdownItems(String label) {
//     switch (label) {
//       case "Age":
//         return List.generate(50, (i) => (i + 18).toString())
//             .map((age) => DropdownMenuItem(
//                 value: age,
//                 child: Text(age, style: const TextStyle(fontSize: 14))))
//             .toList();
//       case "Gender":
//         return ["Male", "Female", "Other"]
//             .map((g) => DropdownMenuItem(
//                 value: g,
//                 child: Text(g, style: const TextStyle(fontSize: 14))))
//             .toList();
//       case "Blood Group":
//         return ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
//             .map((b) => DropdownMenuItem(
//                 value: b,
//                 child: Text(b, style: const TextStyle(fontSize: 14))))
//             .toList();
//       default:
//         return [];
//     }
//   }

//   // ── SAVE ──────────────────────────────────────────────────────────
//   void _saveProfile() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Profile updated successfully!"),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//     Navigator.pop(context);
//   }

//   // ── DATE PICKER ───────────────────────────────────────────────────
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2001, 3, 15),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text =
//             "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
//       });
//     }
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return months[month - 1];
//   }
// }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final TextEditingController _nameController =
//       TextEditingController(text: "Arjun Kumar");
//   final TextEditingController _mobileController =
//       TextEditingController(text: "9876543210");
//   final TextEditingController _dobController =
//       TextEditingController(text: "15 Mar 2001");

//   String _selectedAge = "25";
//   String _selectedGender = "Male";
//   String _selectedBloodGroup = "O+";

//   File? _pickedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? file = await _picker.pickImage(source: source);
//     if (file != null) {
//       setState(() => _pickedImage = File(file.path));
//     }
//   }

//   void _showImageSourceSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.camera_alt),
//             title: const Text("Take Photo"),
//             onTap: () {
//               Navigator.pop(context);
//               _pickImage(ImageSource.camera);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.photo),
//             title: const Text("Gallery"),
//             onTap: () {
//               Navigator.pop(context);
//               _pickImage(ImageSource.gallery);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("Edit Profile",
//             style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [

//             // 🔵 HEADER WITH OVERLAP
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final w = constraints.maxWidth;
//                 final isTablet = w >= 768;

//                 final avatarRadius = isTablet ? 64.0 : 52.0;
//                 final headerHeight = isTablet ? 220.0 : 190.0;

//                 return Column(
//                   children: [
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [

//                         // BLUE HEADER
//                         Container(
//                           height: headerHeight,
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Color(0xFF1E2A78),
//                                 Color(0xFF2F3FA0)
//                               ],
//                             ),
//                           ),
//                         ),

//                         // PROFILE IMAGE
//                         Positioned(
//                           top: headerHeight * 0.25,
//                           left: 0,
//                           right: 0,
//                           child: Center(
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Color(0xFFFFE082),
//                                         Color(0xFFF9A825)
//                                       ],
//                                     ),
//                                   ),
//                                   child: CircleAvatar(
//                                     radius: avatarRadius,
//                                     backgroundImage: _pickedImage != null
//                                         ? FileImage(_pickedImage!)
//                                         : const NetworkImage(
//                                             "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
//                                           ) as ImageProvider,
//                                   ),
//                                 ),

//                                 // CAMERA ICON
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: GestureDetector(
//                                     onTap: _showImageSourceSheet,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: const BoxDecoration(
//                                         color: Color(0xFFFFF3E0),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.camera_alt,
//                                         size: 18,
//                                         color: Color(0xFF1E2A78),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // 🔥 OVERLAP BUTTONS
//                         Positioned(
//                           bottom: -25,
//                           left: 20,
//                           right: 20,
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: _headerBtn(
//                                   icon: Icons.camera_alt,
//                                   label: "Take Photo",
//                                   onTap: () =>
//                                       _pickImage(ImageSource.camera),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _headerBtn(
//                                   icon: Icons.photo,
//                                   label: "Gallery",
//                                   onTap: () =>
//                                       _pickImage(ImageSource.gallery),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 40),
//                   ],
//                 );
//               },
//             ),

//             // 🧾 FORM CARD (UNCHANGED)
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     _label("Mobile Number"),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _mobileController,
//                       decoration: _inputDecoration(
//                         prefixIcon: const Icon(Icons.phone),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     _label("Full Name"),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _nameController,
//                       decoration: _inputDecoration(),
//                     ),

//                     const SizedBox(height: 16),

//                     _label("Date of Birth"),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _boxField(_dobController.text),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _boxField(_selectedAge),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     _label("Gender"),
//                     const SizedBox(height: 8),
//                     _boxField(_selectedGender),

//                     const SizedBox(height: 16),

//                     _label("Blood Group"),
//                     const SizedBox(height: 8),
//                     _boxField(_selectedBloodGroup),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // BUTTON
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Profile Updated")),
//                   );
//                 },
//                 child: Container(
//                   height: 55,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFFDB913), Color(0xFFF59E0B)],
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     "Update Profile",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _headerBtn({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 45,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: const Color(0xFF1E2A78)),
//             const SizedBox(width: 6),
//             Text(label,
//                 style: const TextStyle(
//                     color: Color(0xFF1E2A78),
//                     fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Text(text,
//         style: const TextStyle(fontWeight: FontWeight.bold));
//   }

//   Widget _boxField(String text) {
//     return Container(
//       height: 50,
//       alignment: Alignment.centerLeft,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Text(text),
//     );
//   }

//   InputDecoration _inputDecoration({Widget? prefixIcon}) {
//     return InputDecoration(
//       prefixIcon: prefixIcon,
//       filled: true,
//       fillColor: const Color(0xFFF9FAFB),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }
// }







import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: "Arjun Kumar");
  final TextEditingController _mobileController =
      TextEditingController(text: "9876543210");
  final TextEditingController _dobController =
      TextEditingController(text: "15 Mar 2001");

  String _selectedAge = "25";
  String _selectedGender = "Male";
  String _selectedBloodGroup = "O+";

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // 📷 Pick Image
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  // 💾 SAVE PROFILE (WORKING)
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated Successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      // You can send API here 🔥
      print("Name: ${_nameController.text}");
      print("Mobile: ${_mobileController.text}");
      print("DOB: ${_dobController.text}");
      print("Age: $_selectedAge");
      print("Gender: $_selectedGender");
      print("Blood: $_selectedBloodGroup");

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔷 HEADER
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                    ),
                  ),
                ),

                /// PROFILE IMAGE
                Positioned(
                  top: 40,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFF9A825)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : const NetworkImage(
                                  "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                                ) as ImageProvider,
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF3E0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Color(0xFF1E2A78)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔥 OVERLAP BUTTONS
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: _headerBtn(
                          "Take Photo",
                          Icons.camera_alt,
                          () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _headerBtn(
                          "Gallery",
                          Icons.photo_library,
                          () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            /// 📄 FORM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// MOBILE
                      _label("Mobile Number"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.length != 10) {
                            return "Enter valid mobile number";
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          prefixIcon: const Icon(Icons.phone,
                              color: Color(0xFF1E2A78)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// NAME
                      _label("Full Name"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) =>
                            value!.isEmpty ? "Enter name" : null,
                        decoration: _inputDecoration(),
                      ),

                      const SizedBox(height: 16),

                      /// DOB
                      _label("Date of Birth"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: _boxDecoration(),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 18,
                                        color: Color(0xFF1E2A78)),
                                    const SizedBox(width: 8),
                                    Text(_dobController.text),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _dropdown(
                              _selectedAge,
                              _ageList,
                              (v) => setState(() => _selectedAge = v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// GENDER
                      _label("Gender"),
                      const SizedBox(height: 8),
                      _dropdown(
                        _selectedGender,
                        ["Male", "Female", "Other"],
                        (v) => setState(() => _selectedGender = v),
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 16),

                      /// BLOOD
                      _label("Blood Group"),
                      const SizedBox(height: 8),
                      _dropdown(
                        _selectedBloodGroup,
                        ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
                        (v) => setState(() => _selectedBloodGroup = v),
                        icon: Icons.water_drop,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// UPDATE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _saveProfile,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDB913), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text("Update Profile",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// BUTTON
  Widget _headerBtn(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E2A78)),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2A78))),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _dropdown(String value, List<String> items,
      Function(String) onChanged,
      {IconData? icon}) {
    return Container(
      height: 50,
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: const Color(0xFF1E2A78)),
          if (icon != null) const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => onChanged(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _ageList =>
      List.generate(50, (i) => (18 + i).toString());

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 3, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }
}