import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/app_design_system.dart';
import 'main_navigation_shell/desktop_sidebar.dart';

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
            DesktopSidebar(
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
