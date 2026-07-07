import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/app_design_system.dart';
import 'sidebar_item.dart';
import 'sidebar_profile_section.dart';

class DesktopSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavigate;
  final WidgetRef ref;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const DesktopSidebar({
    super.key,
    required this.activeIndex,
    required this.onNavigate,
    required this.ref,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 260,
      color: surface,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: isCollapsed ? 0 : 16,
            ),
            child: isCollapsed
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MHPSS BDRCS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Bangladesh Red Crescent Society',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Divider(color: border, height: 1),

          // Nav
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 18,
                horizontal: isCollapsed ? 4 : 16,
              ),
              children: [
                SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: activeIndex == 0,
                  onTap: () => onNavigate(0),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people_rounded,
                  label: 'Clients',
                  isActive: activeIndex == 1,
                  onTap: () => onNavigate(1),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                SidebarItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Bills',
                  isActive: activeIndex == 2,
                  onTap: () => onNavigate(2),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                SidebarItem(
                  icon: Icons.contact_phone_outlined,
                  activeIcon: Icons.contact_phone_rounded,
                  label: 'Contacts',
                  isActive: activeIndex == 3,
                  onTap: () => onNavigate(3),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isActive: activeIndex == 4,
                  onTap: () => onNavigate(4),
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),

          Divider(color: border, height: 8),

          // Profile + logout
          SidebarProfileSection(isCollapsed: isCollapsed, ref: ref),

          // Toggle
          Padding(
            padding: EdgeInsets.fromLTRB(
              isCollapsed ? 4 : 16,
              8,
              isCollapsed ? 4 : 16,
              16,
            ),
            child: Center(
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Icon(
                    isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
