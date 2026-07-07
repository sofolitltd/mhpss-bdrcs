import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import '../../../contacts/domain/contact.dart';

class AddCounselorDialog extends StatefulWidget {
  final List<Contact> available;

  const AddCounselorDialog({super.key, required this.available});

  @override
  State<AddCounselorDialog> createState() => _AddCounselorDialogState();
}

class _AddCounselorDialogState extends State<AddCounselorDialog> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return MaxWidthContainer(
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
                minHeight: 300,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                              context,
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
                    child: widget.available.isEmpty
                        ? Center(
                            child: Text(
                              'No counselors available.',
                              style: TextStyle(color: textSecondary),
                            ),
                          )
                        : ListView(
                            children: widget.available.map((c) {
                              final isSelected = _selected.contains(c.id);
                              return InkWell(
                                borderRadius: AppRadius.roundedSm,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selected.remove(c.id);
                                    } else {
                                      _selected.add(c.id);
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
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        onPressed: _selected.isEmpty
                            ? null
                            : () => Navigator.pop(context, _selected.toSet()),
                        child: Text('Add (${_selected.length})'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
