import "package:flutter/material.dart";
import "package:flutter/services.dart";

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final TextAlign textAlign;

  final bool? enabled;
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLength,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      cursorColor: colorScheme.primary,
      textAlign: textAlign,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: (label == null || label!.isEmpty) ? null : label,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        counterText: "",
      ),
    );
  }
}
