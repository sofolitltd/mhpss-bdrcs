import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;

  const DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
