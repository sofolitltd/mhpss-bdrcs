import 'package:flutter/material.dart';

import '../../design_system/app_design_system.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedSm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: AppRadius.roundedSm,
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: isCollapsed
              ? Center(
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? AppColors.primary : inactiveColor,
                    size: 20,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? AppColors.primary : inactiveColor,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? AppColors.primary : inactiveColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(message: label, preferBelow: false, child: content);
    }

    return content;
  }
}
