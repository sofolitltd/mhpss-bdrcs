import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import 'district_picker_dialog.dart';

class DistrictField extends StatelessWidget {
  final String district;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const DistrictField({
    super.key,
    required this.district,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await DistrictPickerDialog.show(
              context: context,
              currentDistrict: district,
              surface: surface,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
            );
            if (result != null) onChanged(result);
          },
          borderRadius: AppRadius.roundedSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: AppRadius.roundedSm,
            ),
            child: Row(
              children: [
                Icon(Icons.map_rounded, size: 20, color: textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    district.isNotEmpty ? district : 'Select district',
                    style: TextStyle(
                      color: district.isNotEmpty ? textPrimary : textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
