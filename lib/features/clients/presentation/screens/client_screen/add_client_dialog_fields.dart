import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';

class GenderAgeDropdownRow extends StatelessWidget {
  final String gender;
  final String ageRange;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onAgeRangeChanged;
  final List<String> ageRanges;

  const GenderAgeDropdownRow({
    super.key,
    required this.gender,
    required this.ageRange,
    required this.onGenderChanged,
    required this.onAgeRangeChanged,
    required this.ageRanges,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: gender,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
              Text(
                'Age Range *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: ageRange,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                  items: ageRanges
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
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
}

class DatePickerField extends StatelessWidget {
  final DateTime joinDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.joinDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
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
            const Icon(
              Icons.event_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${joinDate.day.toString().padLeft(2, '0')}/${joinDate.month.toString().padLeft(2, '0')}/${joinDate.year}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChoiceChips extends StatelessWidget {
  final String category;
  final ValueChanged<String> onCategoryChanged;

  const CategoryChoiceChips({
    super.key,
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Client.categories.map((cat) {
        final selected = category == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => onCategoryChanged(cat),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: selected ? Colors.white : null),
          ),
        );
      }).toList(),
    );
  }
}

class DialogActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const DialogActionButtons({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(140, 48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create Profile'),
        ),
      ],
    );
  }
}
