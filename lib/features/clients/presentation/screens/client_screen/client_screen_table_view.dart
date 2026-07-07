import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';
import 'client_table.dart';

class ClientScreenTableView extends StatelessWidget {
  final AsyncValue<List<Client>> clientsAsyncValue;
  final bool isDark;
  final void Function(Client) onDelete;
  final VoidCallback onAddClient;
  final Widget Function() emptyState;

  const ClientScreenTableView({
    super.key,
    required this.clientsAsyncValue,
    required this.isDark,
    required this.onDelete,
    required this.onAddClient,
    required this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return clientsAsyncValue.when(
      data: (clients) {
        final sorted = List<Client>.from(clients)
          ..sort((a, b) {
            final aDate = a.joinDate ?? a.createdAt;
            final bDate = b.joinDate ?? b.createdAt;
            return bDate.compareTo(aDate);
          });
        return Column(
          children: [
            Expanded(
              child: sorted.isEmpty
                  ? emptyState()
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ClientTable(
                            clients: sorted,
                            onDelete: (Client client) => onDelete(client),
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              alignment: Alignment.centerRight,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Error loading clients: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}
