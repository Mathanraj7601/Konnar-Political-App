import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  
  // --- NEW ADDITIONS FOR ROBUST FORM HANDLING ---
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;
  
  // --- THEME COLORS ---
  final Color focusColor;
  final Color iconBackgroundColor;

  const FormInputField({
    super.key,
    required this.label,
    this.controller,
    this.prefixIcon,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.start,
    // Matches the deep blue from your Login & PersonalInfo screens
    this.focusColor = const Color(0xFF142C8E), 
    // Light background for the prefix icon
    this.iconBackgroundColor = const Color(0xFFEEF2FF), 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700, // Slightly bolder for better hierarchy
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          textAlign: textAlign,
          decoration: InputDecoration(
            // Hides the default character counter if maxLength is used
            counterText: "", 
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            
            // Improved Prefix Icon with a subtle background box
            prefixIcon: prefixIcon != null 
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(prefixIcon, color: focusColor, size: 20),
                    ),
                  ) 
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            
            // Normal State
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            
            // Focused / Active State
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusColor, width: 1.5),
            ),
            
            // Error States
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}