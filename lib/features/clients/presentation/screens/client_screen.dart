import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '/core/design_system/app_design_system.dart';
import '../../data/client_repository.dart';
import '../../domain/models/client.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../providers/client_detail_providers.dart';
import '../providers/clients_provider.dart';

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
                        Text('Clients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text('Manage and view all registered clients',
                            style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded,
                      color: textPrimary,
                    ),
                    tooltip: _isTableView ? 'Card view' : 'Table view',
                    onPressed: () => setState(() => _isTableView = !_isTableView),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MaxWidthContainer(
              child: _isTableView
                  ? _buildTableView(context, isDark, clientsAsyncValue)
                  : _buildCardView(context, isDark, clientsAsyncValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView(BuildContext context, bool isDark, AsyncValue<List<Client>> clientsAsyncValue) {
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
                        child: _buildEmptyState(isDark),
                      );
                    }
                    if (isWide) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childCount: sorted.length,
                          itemBuilder: (context, index) =>
                              _ClientListItem(client: sorted[index]),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final client = sorted[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _ClientListItem(client: client),
                            );
                          },
                          childCount: sorted.length,
                        ),
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
                          style: TextStyle(color: AppColors.accent),
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
                onPressed: () => _showAddClientDialog(context),
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

  Widget _buildTableView(BuildContext context, bool isDark, AsyncValue<List<Client>> clientsAsyncValue) {
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
                  ? _buildEmptyState(isDark)
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _ClientTable(
                        clients: sorted,
                        onDelete: (client) => _confirmTableDelete(client),
                      ),
                      ),
                    ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                onPressed: () => _showAddClientDialog(context),
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
            style: TextStyle(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmTableDelete(Client client) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : null,
        title: Text('Delete Client',
          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${client.caseId}"?\n\nThis will also delete all sessions and assessments for this client. This action cannot be undone.',
          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
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
      await ref.read(sessionRepositoryProvider).deleteSessionsByClientId(client.id);
      await ref.read(assessmentSessionRepositoryProvider).deleteSessionsByClientId(client.id);
      await ref.read(clientRepositoryProvider).deleteClient(client.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No clients registered yet',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.8) : AppColors.textPrimary.withValues(alpha: 0.8),
      builder: (context) => const AddClientDialog(),
    );
  }
}

class _ClientListItem extends StatelessWidget {
  final Client client;

  const _ClientListItem({required this.client});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go('/clients/${client.id}/about'),
        borderRadius: AppRadius.roundedMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name.isNotEmpty ? client.name : 'No name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.tag_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              client.caseId,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                client.address.isNotEmpty ? client.address : '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (client.address.isNotEmpty && client.district.isNotEmpty)
                              Text(', ', style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              )),
                            if (client.district.isNotEmpty)
                              Flexible(
                                child: Text(
                                  client.district,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: isDark ? AppColors.borderDark : AppColors.border),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              if (client.note.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(client.note,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.wc_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    client.gender,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    client.ageRange.isNotEmpty ? client.ageRange : 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  if (client.category.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(client.category, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    client.joinDate != null
                        ? 'Joined ${client.joinDate!.day.toString().padLeft(2, '0')}/${client.joinDate!.month.toString().padLeft(2, '0')}/${client.joinDate!.year}'
                        : 'Added ${client.createdAt.day.toString().padLeft(2, '0')}/${client.createdAt.month.toString().padLeft(2, '0')}/${client.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ClientTable extends StatelessWidget {
  final List<Client> clients;
  final void Function(Client client) onDelete;

  const _ClientTable({required this.clients, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.08)),
                border: TableBorder.all(color: border, borderRadius: AppRadius.roundedSm),
                columnSpacing: 16,
                columns: const [
            DataColumn(label: Text('Case ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('District', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Alt Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: clients.map((c) {
            return DataRow(
              cells: [
                DataCell(Text(c.caseId, style: TextStyle(color: textPrimary))),
                DataCell(
                  _HoverableNameCell(client: c),
                ),
                DataCell(Text(c.address, style: TextStyle(color: textPrimary))),
                DataCell(Text(c.district, style: TextStyle(color: textPrimary))),
                DataCell(Text(c.gender, style: TextStyle(color: textPrimary))),
                DataCell(Text(c.ageRange, style: TextStyle(color: textPrimary))),
                DataCell(c.category.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c.category, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                      )
                    : const Text('')),
                DataCell(Text(c.note, style: TextStyle(color: textPrimary, fontStyle: FontStyle.italic))),
                DataCell(Text(c.phone ?? '', style: TextStyle(color: textPrimary))),
                DataCell(Text(c.alternatePhone ?? '', style: TextStyle(color: textPrimary))),
                DataCell(Text(
                  c.joinDate != null
                      ? '${c.joinDate!.day.toString().padLeft(2, '0')}/${c.joinDate!.month.toString().padLeft(2, '0')}/${c.joinDate!.year}'
                      : '',
                  style: TextStyle(color: textPrimary),
                )),
                DataCell(PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: textPrimary),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        context.go('/clients/${c.id}/about');
                        break;
                      case 'edit':
                        context.go('/clients/${c.id}/about');
                        break;
                      case 'delete':
                        onDelete(c);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.visibility_outlined, size: 20),
                        title: Text('View Details'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_outlined, size: 20),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ],                     // closes DataRow cells
            );                       // closes DataRow
          }).toList(),               // closes rows.map
    );                               // closes DataTable
  }
}

class _HoverableNameCell extends StatefulWidget {
  final Client client;
  const _HoverableNameCell({required this.client});

  @override
  State<_HoverableNameCell> createState() => _HoverableNameCellState();
}

class _HoverableNameCellState extends State<_HoverableNameCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/clients/${widget.client.id}/about'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            widget.client.capitalizedName,
            style: TextStyle(
              color: _isHovered ? AppColors.primary : textPrimary,
              decoration: _isHovered ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }
}

class AddClientDialog extends ConsumerStatefulWidget {
  const AddClientDialog({super.key});

  @override
  ConsumerState<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends ConsumerState<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _caseIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _districtSearchController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _joinDate = DateTime.now();
  String _gender = 'Male';
  String _ageRange = '18-29';
  String _category = '';
  bool _isLoading = false;

  static const List<String> _ageRanges = [
    '0-5', '6-12', '13-17', '18-29', '30-39',
    '40-49', '50-59', '60-69', '70-89', '90-100+',
  ];

  static const List<String> _bangladeshDistricts = [
    'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogra',
    'Brahmanbaria', 'Chandpur', 'Chittagong', 'Chuadanga', 'Comilla',
    'Cox\'s Bazar', 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni', 'Gaibandha',
    'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur', 'Jessore', 'Jhalokati',
    'Jhenaidah', 'Joypurhat', 'Khagrachhari', 'Khulna', 'Kishoreganj',
    'Kurigram', 'Kushtia', 'Lakshmipur', 'Lalmonirhat', 'Madaripur',
    'Magura', 'Manikganj', 'Maulvibazar', 'Meherpur', 'Munshiganj',
    'Mymensingh', 'Naogaon', 'Narail', 'Narayanganj', 'Narsingdi',
    'Natore', 'Nawabganj', 'Netrokona', 'Nilphamari', 'Noakhali',
    'Pabna', 'Panchagarh', 'Patuakhali', 'Pirojpur', 'Rajbari',
    'Rajshahi', 'Rangamati', 'Rangpur', 'Satkhira', 'Shariatpur',
    'Sherpur', 'Sirajganj', 'Sunamganj', 'Sylhet', 'Tangail', 'Thakurgaon',
  ];

  @override
  void dispose() {
    _caseIdController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _districtSearchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Add Client',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DialogTextField(
                    controller: _caseIdController,
                    label: 'Case ID *',
                    hint: 'e.g. CAS-001',
                    prefixIcon: Icons.tag_rounded,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogTextField(
                    controller: _nameController,
                    label: 'Name *',
                    hint: 'e.g. John Doe',
                    prefixIcon: Icons.person_rounded,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _gender,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedSm,
                                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedSm,
                                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                ),
                                items: ['Male', 'Female']
                                    .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                    ))))
                                    .toList(),
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age Range *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _ageRange,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedSm,
                                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedSm,
                                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                ),
                                items: _ageRanges
                                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                    ))))
                                    .toList(),
                                onChanged: (v) => setState(() => _ageRange = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogTextField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'e.g. 123 Main Street',
                    prefixIcon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'District *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showDistrictPicker(context, isDark),
                    borderRadius: AppRadius.roundedSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.map_rounded, size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _districtSearchController.text.isNotEmpty
                                  ? _districtSearchController.text
                                  : '',
                              style: TextStyle(
                                color: _districtSearchController.text.isNotEmpty
                                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                                    : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded, size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'e.g. +8801XXXXXXXXX',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogTextField(
                    controller: _alternatePhoneController,
                    label: 'Alternate Phone',
                    hint: 'e.g. +8801XXXXXXXXX',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Join Date *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _joinDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        helpText: 'Select join date',
                      );
                      if (picked != null) {
                        setState(() => _joinDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_joinDate.day.toString().padLeft(2, '0')}/${_joinDate.month.toString().padLeft(2, '0')}/${_joinDate.year}',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: Client.categories.map((cat) {
                      final selected = _category == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) => setState(() => _category = cat),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DialogTextField(
                    controller: _noteController,
                    label: 'Note / Injury Remark',
                    hint: 'e.g. injury details, special notes',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDistrictPicker(BuildContext context, bool isDark) {
    final searchCtrl = TextEditingController();
    String filter = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text('Select District',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search district...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.roundedMd,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setDialogState(() => filter = v.toLowerCase()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView(
                      shrinkWrap: true,
                      children: _bangladeshDistricts
                          .where((d) => filter.isEmpty || d.toLowerCase().contains(filter))
                          .map((d) => ListTile(
                                dense: true,
                                title: Text(d, style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                trailing: _districtSearchController.text == d
                                    ? Icon(Icons.check, color: AppColors.primary, size: 20)
                                    : null,
                                onTap: () {
                                  setState(() => _districtSearchController.text = d);
                                  Navigator.pop(ctx);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(clientsProvider.notifier)
          .addClient(
            caseId: _caseIdController.text.trim(),
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            district: _districtSearchController.text.trim(),
            gender: _gender,
            ageRange: _ageRange,
            category: _category,
            note: _noteController.text.trim(),
            joinDate: _joinDate,
            phone: _phoneController.text.trim(),
            alternatePhone: _alternatePhoneController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
