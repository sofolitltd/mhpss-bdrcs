import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import '../../../../contacts/domain/counselor.dart';

Future<List<String>?> showAddCounselorDialog(
  BuildContext context,
  List<Counselor> counselors,
  Set<String> assignedIds,
) {
  final available = counselors
      .where((c) => !assignedIds.contains(c.id))
      .toList();

  if (available.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All counselors are already assigned.')),
    );
    return Future.value(null);
  }

  final screenHeight = MediaQuery.of(context).size.height;

  return showDialog<List<String>>(
    context: context,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final textPrimary = isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimary;
      final textSecondary = isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondary;
      final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
      final border = isDark ? AppColors.borderDark : AppColors.border;

      final selected = <String>{};

      return StatefulBuilder(
        builder: (ctx, setDialogState) => MaxWidthContainer(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 320,
                    maxHeight: screenHeight * 0.75,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_add_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Add Counselor',
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
                      Expanded(
                        child: available.isEmpty
                            ? Center(
                                child: Text(
                                  'No counselors available to add.',
                                  style: TextStyle(color: textSecondary),
                                ),
                              )
                            : ListView(
                                children: available.map((c) {
                                  final isSelected = selected.contains(c.id);
                                  return InkWell(
                                    borderRadius: AppRadius.roundedSm,
                                    onTap: () {
                                      setDialogState(() {
                                        if (isSelected) {
                                          selected.remove(c.id);
                                        } else {
                                          selected.add(c.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: border,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            child: Text(
                                              c.name.isNotEmpty
                                                  ? c.name[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: textPrimary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '${c.employeeId}${c.designation.isNotEmpty ? ' — ${c.designation}' : ''}',
                                                  style: TextStyle(
                                                    color: textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle_rounded
                                                : Icons
                                                      .radio_button_unchecked_rounded,
                                            color: isSelected
                                                ? AppColors.primary
                                                : textSecondary,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: textPrimary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(140, 48),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.roundedMd,
                              ),
                            ),
                            onPressed: selected.isEmpty
                                ? null
                                : () {
                                    Navigator.pop(ctx, selected.toList());
                                  },
                            child: Text('Add (${selected.length})'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
