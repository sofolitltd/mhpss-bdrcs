import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../../domain/scoring_engine.dart';
import 'severity_helpers.dart';

class AssessmentScaleCard extends StatelessWidget {
  final ScoreResult result;
  final String testId;

  const AssessmentScaleCard({
    super.key,
    required this.result,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = severityColor(result.severity);
    final thresholds = getSeverityThresholds(testId, result.scale);
    final maxScore = result.maxScore > 0 ? result.maxScore : 1;
    final fontFamily = GoogleFonts.outfit().fontFamily;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result.scale.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  result.severity,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.rawScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 4),
                child: Text(
                  '/ $maxScore',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: AppRadius.roundedSm,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final t in thresholds)
                    Expanded(
                      flex: t.max - t.min + 1,
                      child: Container(
                        color: severityColorFromThreshold(t, result.severity),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...thresholds.map((t) {
            final isCurrent = t.label == result.severity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? severityColor(t.label)
                          : severityColor(t.label).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent
                            ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${t.min}${t.min != t.max ? ' - ${t.max}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrent
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (result.interpretation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                result.interpretation!,
                style:
                    TextStyle(
                      fontSize: 13,
                      color: color.withValues(alpha: 0.9),
                      height: 1.4,
                    ).merge(
                      testId.endsWith('_bn') ? GoogleFonts.tiroBangla() : null,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
