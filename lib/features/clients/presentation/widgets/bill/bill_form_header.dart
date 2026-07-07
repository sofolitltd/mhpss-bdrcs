import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class BillFormHeader extends StatelessWidget {
  final bool isDark;
  final String clientId;
  final bool isEditing;
  final VoidCallback onPreview;
  final bool isSaving;
  final VoidCallback onSave;

  const BillFormHeader({
    super.key,
    required this.isDark,
    required this.clientId,
    required this.isEditing,
    required this.onPreview,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: MaxWidthContainer(
        padding: pagePadding(context),
        child: Row(
          children: [
            BackButton(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Bill' : 'New Bill',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clientId,
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
            TextButton(onPressed: onPreview, child: const Text('Preview')),
            FilledButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
