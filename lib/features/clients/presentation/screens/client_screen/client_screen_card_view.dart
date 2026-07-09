import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';
import 'client_list_item.dart';

class ClientScreenCardView extends StatelessWidget {
  final AsyncValue<List<Client>> clientsAsyncValue;
  final bool isDark;
  final VoidCallback onAddClient;
  final Widget Function() emptyState;

  const ClientScreenCardView({
    super.key,
    required this.clientsAsyncValue,
    required this.isDark,
    required this.onAddClient,
    required this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.lg;
        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                clientsAsyncValue.when(
                  data: (clients) {
                    final sorted = List<Client>.from(clients)
                      ..sort((a, b) {
                        final aDate = a.joinDate ?? a.createdAt;
                        final bDate = b.joinDate ?? b.createdAt;
                        return bDate.compareTo(aDate);
                      });
                    if (sorted.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: emptyState(),
                      );
                    }
                    if (isWide) {
                      return SliverPadding(
                               padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 4, AppSpacing.md,  AppSpacing.md),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childCount: sorted.length,
                          itemBuilder: (context, index) =>
                              ClientListItem(client: sorted[index]),
                        ),
                      );
                    }
                    return SliverPadding(
       padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 4, AppSpacing.md,  AppSpacing.md),                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final client = sorted[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ClientListItem(client: client),
                          );
                        }, childCount: sorted.length),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Error loading clients: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
            Positioned(
              right: 0,
              bottom: AppSpacing.md,
              child: FloatingActionButton.extended(
                onPressed: onAddClient,
                label: const Text('Add Client'),
                icon: const Icon(Icons.person_add_rounded),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
