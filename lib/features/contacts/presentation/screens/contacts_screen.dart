import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '../providers/contacts_providers.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final isWide = MediaQuery.of(context).size.width >= AppBreakpoints.lg;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Text('Contacts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text('View counselor contact information',
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
              counselorsAsync.when(
                data: (counselors) {
                  if (counselors.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No counselors found.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }
                  if (isWide) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childCount: counselors.length,
                        itemBuilder: (context, index) =>
                            _CounselorCard(counselor: counselors[index]),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final c = counselors[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CounselorCard(counselor: c),
                          );
                        },
                        childCount: counselors.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Error loading counselors.')),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
    );
  }
}

class _CounselorCard extends StatelessWidget {
  final dynamic counselor;

  const _CounselorCard({required this.counselor});

  @override
  Widget build(BuildContext context) {
    final c = counselor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.designation} | ${c.employeeId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _launch('tel:${c.phone}'),
            borderRadius: AppRadius.roundedSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    c.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.call_made_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => _launch('mailto:${c.email}'),
            borderRadius: AppRadius.roundedSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    c.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
