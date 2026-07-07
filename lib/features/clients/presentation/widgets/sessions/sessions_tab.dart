import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../domain/session.dart';
import '../../providers/client_detail_providers.dart';
import '../dialogs/session_dialog.dart';
import 'session_list_item.dart';

class SessionsTab extends ConsumerWidget {
  final String clientId;
  final String clientAlias;

  const SessionsTab({
    super.key,
    required this.clientId,
    required this.clientAlias,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(clientSessionsProvider(clientId));

    return Stack(
      children: [
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Center(
                child: Text(
                  'No sessions yet',
                  style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: 80,
              ),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionListItem(
                  session: session,
                  index: sessions.length - index,
                  onTap: () => context.go(
                    '/clients/${session.clientId}/sessions/${session.id}',
                    extra: {'session': session},
                  ),
                  onEdit: () => _showEditSessionDialog(context, ref, session),
                  onDelete: () => _deleteSession(context, ref, session),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddSessionDialog(context, ref),
            label: const Text('Add Session'),
            icon: const Icon(Icons.add_task_rounded),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary).withValues(alpha: 0.8),
      builder: (_) => AddSessionDialog(clientId: clientId, clientAlias: clientAlias),
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary).withValues(alpha: 0.8),
      builder: (context) =>
          AddSessionDialog(clientId: clientId, clientAlias: clientAlias, session: session),
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : null,
          title: Text('Delete Session',
            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          content: Text(
            'Delete "${session.title.isNotEmpty ? session.title : 'Session'}" from ${DateFormat.yMMMd().format(session.date)}?',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      await ref.read(sessionRepositoryProvider).deleteSession(session.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }
}
