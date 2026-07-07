import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Color sectionColor;
  final Color textColor;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.sectionColor,
    required this.textColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: sectionColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
