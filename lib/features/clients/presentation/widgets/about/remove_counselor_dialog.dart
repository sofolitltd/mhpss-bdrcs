import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import '../../../../contacts/domain/counselor.dart';

Future<bool> showRemoveCounselorConfirmation(
  BuildContext context,
  Counselor c,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textPrimary = isDark
      ? AppColors.textPrimaryDark
      : AppColors.textPrimary;
  final textSecondary = isDark
      ? AppColors.textSecondaryDark
      : AppColors.textSecondary;
  final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_remove_rounded, color: Colors.red),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Remove Counselor',
                        style: TextStyle(
                          fontSize: Theme.of(
                            ctx,
                          ).textTheme.titleLarge?.fontSize,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Remove ${c.name} from this client?',
                  style: TextStyle(color: textSecondary, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ).then((v) => v ?? false);
}
