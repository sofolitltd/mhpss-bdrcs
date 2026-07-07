import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';

class SignInLink extends StatelessWidget {
  final bool isDark;

  const SignInLink({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          children: const [
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
