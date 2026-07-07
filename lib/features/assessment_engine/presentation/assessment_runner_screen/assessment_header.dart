import 'package:flutter/material.dart';

import '../../../../core/design_system/app_design_system.dart';

class AssessmentHeader extends StatelessWidget {
  final String testName;
  final int answeredCount;
  final int totalCount;
  final bool isDark;
  final bool isSaving;
  final VoidCallback? onFinish;
  final VoidCallback onClose;

  const AssessmentHeader({
    super.key,
    required this.testName,
    required this.answeredCount,
    required this.totalCount,
    required this.isDark,
    required this.isSaving,
    this.onFinish,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$answeredCount / $totalCount answered',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
