import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import 'category_choice_chips.dart';
import 'date_field.dart';
import 'district_field.dart';
import 'gender_age_row.dart';

class EditClientForm extends StatelessWidget {
  final TextEditingController caseIdCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController alternatePhoneCtrl;
  final TextEditingController noteCtrl;
  final String gender;
  final String ageRange;
  final String district;
  final String category;
  final DateTime joinDate;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onAgeRangeChanged;
  final ValueChanged<String> onDistrictChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DateTime> onJoinDateChanged;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;

  const EditClientForm({
    super.key,
    required this.caseIdCtrl,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.alternatePhoneCtrl,
    required this.noteCtrl,
    required this.gender,
    required this.ageRange,
    required this.district,
    required this.category,
    required this.joinDate,
    required this.onGenderChanged,
    required this.onAgeRangeChanged,
    required this.onDistrictChanged,
    required this.onCategoryChanged,
    required this.onJoinDateChanged,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSpacing.lg),
        _buildLabel('Case ID'),
        const SizedBox(height: 8),
        _buildTextField(caseIdCtrl, 'e.g. CAS-001', Icons.tag_rounded),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Name'),
        const SizedBox(height: 8),
        _buildTextField(nameCtrl, 'e.g. John Doe', Icons.person_rounded),
        GenderAgeRow(
          gender: gender,
          ageRange: ageRange,
          isDark: isDark,
          textPrimary: textPrimary,
          border: border,
          onGenderChanged: onGenderChanged,
          onAgeRangeChanged: onAgeRangeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Address'),
        const SizedBox(height: 8),
        _buildTextField(
          addressCtrl,
          'e.g. 123 Main Street',
          Icons.location_on_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        DistrictField(
          district: district,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: border,
          surface: surface,
          isDark: isDark,
          onChanged: onDistrictChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Phone'),
        const SizedBox(height: 8),
        _buildTextField(
          phoneCtrl,
          'e.g. +8801XXXXXXXXX',
          Icons.phone_rounded,
          phone: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Alternate Phone'),
        const SizedBox(height: 8),
        _buildTextField(
          alternatePhoneCtrl,
          'e.g. +8801XXXXXXXXX',
          Icons.phone_rounded,
          phone: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Join Date'),
        const SizedBox(height: 8),
        DateField(
          date: joinDate,
          textPrimary: textPrimary,
          border: border,
          onChanged: onJoinDateChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Category'),
        const SizedBox(height: 8),
        CategoryChoiceChips(category: category, onChanged: onCategoryChanged),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Note / Injury Remark'),
        const SizedBox(height: 8),
        _buildTextField(
          noteCtrl,
          'e.g. injury details, special notes',
          Icons.notes_rounded,
          multiLine: true,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.edit_outlined, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Edit Client',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
            fontWeight: FontWeight.bold,
            color: textPrimary,
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool phone = false,
    bool multiLine = false,
  }) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: isDark ? textPrimary : textSecondary),
      keyboardType: phone ? TextInputType.phone : null,
      maxLines: multiLine ? 3 : 1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary),
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedSm,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedSm,
          borderSide: BorderSide(color: border),
        ),
      ),
    );
  }
}
