import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class ContactTile extends StatelessWidget {
  final String phone;
  final String label;
  final VoidCallback onTap;

  const ContactTile({
    super.key,
    required this.phone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: AppRadius.roundedSm,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phone,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.call_made_rounded, size: 18, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
