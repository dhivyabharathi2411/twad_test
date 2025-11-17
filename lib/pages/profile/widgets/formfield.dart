import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:twad/constants/app_constants.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? hintText;
  final List<TextInputFormatter> inputFormatters;

  const ProfileFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEnabled,
    this.validator,
    this.keyboardType,
    this.hintText,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppConstants.bodyTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          validator: validator,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          style: AppConstants.bodyTextStyle.copyWith(
            fontSize: 16,
            color: isEnabled
                ? AppConstants.textPrimaryColor
                : AppConstants.textSecondaryColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: AppConstants.primaryColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
