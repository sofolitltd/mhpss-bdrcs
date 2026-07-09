import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class ClientScreenEmptyState extends StatelessWidget {
  final bool isDark;
  final String message;

  const ClientScreenEmptyState({
    super.key,
    required this.isDark,
    this.message = 'No clients registered yet',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
