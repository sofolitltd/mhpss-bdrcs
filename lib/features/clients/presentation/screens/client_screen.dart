import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '../../data/client_repository.dart';
import '../../domain/models/client.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../providers/client_detail_providers.dart';
import '../providers/clients_provider.dart';
import 'client_screen/client_screen_card_view.dart';
import 'client_screen/client_screen_table_view.dart';
import 'client_screen/client_screen_empty_state.dart';
import 'client_screen/add_client_dialog.dart';

class ClientScreen extends ConsumerStatefulWidget {
  const ClientScreen({super.key});

  @override
  ConsumerState<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends ConsumerState<ClientScreen> {
  bool _isTableView = false;

  @override
  Widget build(BuildContext context) {
    final clientsAsyncValue = ref.watch(clientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
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
                        Text(
                          'Clients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage and view all registered clients',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isTableView
                          ? Icons.grid_view_rounded
                          : Icons.table_chart_rounded,
                      color: textPrimary,
                    ),
                    tooltip: _isTableView ? 'Card view' : 'Table view',
                    onPressed: () =>
                        setState(() => _isTableView = !_isTableView),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MaxWidthContainer(
              child: _isTableView
                  ? ClientScreenTableView(
                      clientsAsyncValue: clientsAsyncValue,
                      isDark: isDark,
                      onDelete: (Client client) => _confirmTableDelete(client),
                      onAddClient: () => _showAddClientDialog(context),
                      emptyState: () => ClientScreenEmptyState(isDark: isDark),
                    )
                  : ClientScreenCardView(
                      clientsAsyncValue: clientsAsyncValue,
                      isDark: isDark,
                      onAddClient: () => _showAddClientDialog(context),
                      emptyState: () => ClientScreenEmptyState(isDark: isDark),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTableDelete(Client client) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : null,
        title: Text(
          'Delete Client',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${client.caseId}"?\n\nThis will also delete all sessions and assessments for this client. This action cannot be undone.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref
          .read(sessionRepositoryProvider)
          .deleteSessionsByClientId(client.id);
      await ref
          .read(assessmentSessionRepositoryProvider)
          .deleteSessionsByClientId(client.id);
      await ref.read(clientRepositoryProvider).deleteClient(client.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  void _showAddClientDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: isDark
          ? AppColors.textPrimaryDark.withValues(alpha: 0.8)
          : AppColors.textPrimary.withValues(alpha: 0.8),
      builder: (context) => const AddClientDialog(),
    );
  }
}
