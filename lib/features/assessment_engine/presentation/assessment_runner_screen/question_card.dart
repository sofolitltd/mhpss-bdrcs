import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../../domain/assessment_models.dart';

class QuestionCard extends StatelessWidget {
  final TestQuestion question;
  final List<TestOption> options;
  final int? selectedValue;
  final int questionNumber;
  final ValueChanged<int?> onChanged;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.questionNumber,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAnswered = selectedValue != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isAnswered
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: isAnswered ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? AppColors.primary
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: isAnswered ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: GoogleFonts.tiroBangla(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: selectedValue,
              onChanged: onChanged,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((opt) {
                  final isSel = selectedValue == opt.value;
                  return RadioListTile<int>(
                    value: opt.value,
                    activeColor: AppColors.primary,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt.label,
                      style: GoogleFonts.tiroBangla(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                        color: isSel
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
