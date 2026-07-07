import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/developer_info.dart';
import 'widgets/profile_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/sign_out_section.dart';
import 'widgets/support_section.dart';
import 'widgets/theme_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: surface,
            child: MaxWidthContainer(
              padding: pagePadding(context),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text('Manage your account and preferences',
                            style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MaxWidthContainer(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: ProfileCard(authState: authState)),
                  SliverToBoxAdapter(child: SectionHeader(title: 'Account')),
                  SliverToBoxAdapter(child: SettingsCard(child: Column(children: [
                    SettingsListTile(
                      title: 'Change Password',
                      icon: Icons.lock_outline_rounded,
                      onTap: () => showDialog(context: context, builder: (_) => const ChangePasswordDialog()),
                    ),
                  ]))),
                  SliverToBoxAdapter(child: SectionHeader(title: 'Appearance')),
                  SliverToBoxAdapter(child: ThemeSection(ref: ref)),
                  SliverToBoxAdapter(child: SectionHeader(title: 'MHPSS Basics')),
                  SliverToBoxAdapter(child: const SupportSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
                  SliverToBoxAdapter(child: SignOutSection(ref: ref)),
                  SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
                  SliverToBoxAdapter(child: SectionHeader(title: 'Developer')),
                  SliverToBoxAdapter(child: const DeveloperInfo()),
                  SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
