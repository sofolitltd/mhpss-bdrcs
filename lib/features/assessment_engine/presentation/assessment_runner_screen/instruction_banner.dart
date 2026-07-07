import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_design_system.dart';

class InstructionBanner extends StatelessWidget {
  final String instruction;
  final bool isDark;

  const InstructionBanner({
    super.key,
    required this.instruction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : Colors.amber.withValues(alpha: 0.1),
          borderRadius: AppRadius.roundedSm,
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                instruction,
                style: GoogleFonts.tiroBangla(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
