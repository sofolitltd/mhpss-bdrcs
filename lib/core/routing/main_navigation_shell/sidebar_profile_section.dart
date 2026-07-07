import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../design_system/app_design_system.dart';

class SidebarProfileSection extends StatelessWidget {
  final bool isCollapsed;
  final WidgetRef ref;

  const SidebarProfileSection({
    super.key,
    required this.isCollapsed,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 4 : 16,
        8,
        isCollapsed ? 4 : 16,
        8,
      ),
      child: isCollapsed
          ? Column(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 18),
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
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 20),
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
    );
  }
}
