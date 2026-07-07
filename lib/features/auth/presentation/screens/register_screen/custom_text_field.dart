import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class CustomTextField extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.isDark,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rfs(context, 14),
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onFieldSubmitted: (_) => onFieldSubmitted?.call(),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
            border: const OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
