import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.onTap,
    this.onChanged,
    this.contentPadding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLabelStyle = labelStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFF3F5F7),
          letterSpacing: -0.2,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(label!, style: resolvedLabelStyle),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          minLines: minLines,
          maxLines: maxLines ?? 1,
          onTap: onTap,
          onChanged: onChanged,
          style: const TextStyle(
            color: Color(0xFFF3F5F7),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8E939A),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: Color(0xFFF3F5F7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              color: Color(0xFFF3F5F7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFF1F2227),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4D535B),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4D535B),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF7EB3FF),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
