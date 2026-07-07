import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class GenderAgeRow extends StatelessWidget {
  final String gender;
  final String ageRange;
  final bool isDark;
  final Color textPrimary;
  final Color border;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onAgeRangeChanged;

  const GenderAgeRow({
    super.key,
    required this.gender,
    required this.ageRange,
    required this.isDark,
    required this.textPrimary,
    required this.border,
    required this.onGenderChanged,
    required this.onAgeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Gender'),
              const SizedBox(height: 8),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: gender,
                  decoration: _dropdownDecoration(),
                  items: ['Male', 'Female']
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => onGenderChanged(v!),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Age Range'),
              const SizedBox(height: 8),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: ageRange,
                  decoration: _dropdownDecoration(),
                  items:
                      const [
                            '0-5',
                            '6-12',
                            '13-17',
                            '18-29',
                            '30-39',
                            '40-49',
                            '50-59',
                            '60-69',
                            '70-89',
                            '90-100+',
                          ]
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (v) => onAgeRangeChanged(v!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: textPrimary,
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: AppRadius.roundedSm,
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.roundedSm,
        borderSide: BorderSide(color: border),
      ),
    );
  }
}
