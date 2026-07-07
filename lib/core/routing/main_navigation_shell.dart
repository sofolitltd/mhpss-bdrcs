import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../design_system/app_design_system.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final activeIndex = widget.navigationShell.currentIndex;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.md;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: bg,
        body: Row(
          children: [
            _DesktopSidebar(
              activeIndex: activeIndex,
              onNavigate: (index) => widget.navigationShell.goBranch(index),
              ref: ref,
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            VerticalDivider(width: 1, thickness: 1, color: border),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: bg,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: (index) => widget.navigationShell.goBranch(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Clients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Bills',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_phone_outlined),
                activeIcon: Icon(Icons.contact_phone_rounded),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavigate;
  final WidgetRef ref;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _DesktopSidebar({
    required this.activeIndex,
    required this.onNavigate,
    required this.ref,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
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
                              style: TextStyle(fontSize: 11, color: textSecondary),
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
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: activeIndex == 0,
                  onTap: () => onNavigate(0),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people_rounded,
                  label: 'Clients',
                  isActive: activeIndex == 1,
                  onTap: () => onNavigate(1),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Bills',
                  isActive: activeIndex == 2,
                  onTap: () => onNavigate(2),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.contact_phone_outlined,
                  activeIcon: Icons.contact_phone_rounded,
                  label: 'Contacts',
                  isActive: activeIndex == 3,
                  onTap: () => onNavigate(3),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                _SidebarItem(
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              isCollapsed ? 4 : 16,
              8,
              isCollapsed ? 4 : 16,
              8,
            ),
            child: isCollapsed
                ? Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        tooltip: 'Log Out',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                'Sign Out',
                                style: TextStyle(color: textPrimary),
                              ),
                              content: Text(
                                'Are you sure you want to log out of your session?',
                                style: TextStyle(color: textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(authProvider.notifier).logout();
                                    if (ctx.mounted) {
                                      GoRouter.of(ctx).go('/login');
                                    }
                                  },
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authState.name ?? 'Dr. Rahman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              authState.email ?? 'Psychologist',
                              style: TextStyle(fontSize: 11, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        tooltip: 'Log Out',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                'Sign Out',
                                style: TextStyle(color: textPrimary),
                              ),
                              content: Text(
                                'Are you sure you want to log out of your session?',
                                style: TextStyle(color: textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(authProvider.notifier).logout();
                                    if (ctx.mounted) {
                                      GoRouter.of(ctx).go('/login');
                                    }
                                  },
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),

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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed;

  const _SidebarItem({
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
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
      return Tooltip(
        message: label,
        preferBelow: false,
        child: content,
      );
    }

    return content;
  }
}
