import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class DistrictField extends StatelessWidget {
  final bool isDark;
  final String districtText;
  final VoidCallback onTap;

  const DistrictField({
    super.key,
    required this.isDark,
    required this.districtText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: AppRadius.roundedSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    districtText.isNotEmpty ? districtText : '',
                    style: TextStyle(
                      color: districtText.isNotEmpty
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
