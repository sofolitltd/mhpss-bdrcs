import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';

class ClientDetailTabBar extends StatelessWidget {
  final String clientId;

  const ClientDetailTabBar({super.key, required this.clientId});

  int _tabIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.endsWith('/sessions')) return 1;
    if (path.endsWith('/assessments')) return 2;
    if (path.endsWith('/docs')) return 3;
    if (path.endsWith('/bill')) return 4;
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    final base = '/clients/$clientId';
    final targetPath = switch (index) {
      0 => '$base/about',
      1 => '$base/sessions',
      2 => '$base/assessments',
      3 => '$base/docs',
      _ => '$base/bill',
    };
    context.go(targetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(context, 'About', 0),
        _buildTab(context, 'Sessions', 1),
        _buildTab(context, 'Assessments', 2),
        _buildTab(context, 'Docs', 3),
        _buildTab(context, 'Bill', 4),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _tabIndex(context) == index;

    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    final indicatorWidth = tp.width;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(context, index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: indicatorWidth,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
