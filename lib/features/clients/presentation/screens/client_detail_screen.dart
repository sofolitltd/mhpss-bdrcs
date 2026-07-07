import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../../data/client_repository.dart';
import '../../domain/models/client.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../providers/client_detail_providers.dart';
import '../widgets/about/about_tab.dart';
import '../widgets/assessments/assessments_tab.dart';
import '../widgets/bill_tab.dart';
import '../widgets/docs/docs_tab.dart';
import '../widgets/sessions/sessions_tab.dart';
import 'client_detail_screen/client_detail_tab_bar.dart';
import 'client_detail_screen/delete_client_dialog.dart';
import 'client_detail_screen/edit_client_dialog.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  int get _tabIndex {
    final path = GoRouterState.of(context).uri.path;
    if (path.endsWith('/sessions')) return 1;
    if (path.endsWith('/assessments')) return 2;
    if (path.endsWith('/docs')) return 3;
    if (path.endsWith('/bill')) return 4;
    return 0;
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await DeleteClientDialog.show(context, client);
    if (confirm != true) return;

    try {
      await ref
          .read(sessionRepositoryProvider)
          .deleteSessionsByClientId(client.id);
      await ref
          .read(assessmentSessionRepositoryProvider)
          .deleteSessionsByClientId(client.id);
      await ref.read(clientRepositoryProvider).deleteClient(client.id);
      if (mounted) Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientByIdProvider(widget.clientId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;

    if (client == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            'Client Details',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          backgroundColor: bg,
        ),
        body: MaxWidthContainer(
          child: Center(
            child: Text(
              'Client not found',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      title: Text(
                        '${client.caseId} - ${client.capitalizedName}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surface,
                      elevation: 0,
                      pinned: true,
                      floating: true,
                      snap: true,
                      centerTitle: false,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                          ),
                          child: ClientDetailTabBar(clientId: widget.clientId),
                        ),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              EditClientDialog.show(context, client);
                            } else if (value == 'delete') {
                              _deleteClient(client);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      AboutTab(client: client),
                      SessionsTab(
                        clientId: widget.clientId,
                        clientAlias: client.caseId,
                      ),
                      AssessmentsTab(
                        clientId: widget.clientId,
                        clientAlias: client.caseId,
                      ),
                      DocsTab(client: client),
                      BillTab(
                        clientId: widget.clientId,
                        clientCaseId: client.caseId,
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabIndex == 2)
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton.extended(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Assessment'),
                    onPressed: () => context.go(
                      '/clients/${widget.clientId}/new-assessment?clientAlias=${Uri.encodeComponent(client.caseId)}&from=assessments',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
