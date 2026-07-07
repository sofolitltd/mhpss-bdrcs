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

  void _onTabTap(int index) {
    final base = '/clients/${widget.clientId}';
    final targetPath = switch (index) {
      0 => '$base/about',
      1 => '$base/sessions',
      2 => '$base/assessments',
      3 => '$base/docs',
      _ => '$base/bill',
    };
    context.go(targetPath);
  }

  Widget _buildTab(String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _tabIndex == index;

    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    final indicatorWidth = tp.width;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: indicatorWidth,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Client client) {
    final caseIdCtrl = TextEditingController(text: client.caseId);
    final nameCtrl = TextEditingController(text: client.name);
    final addressCtrl = TextEditingController(text: client.address);
    final phoneCtrl = TextEditingController(text: client.phone ?? '');
    final alternatePhoneCtrl = TextEditingController(text: client.alternatePhone ?? '');
    String gender = client.gender;
    String ageRange = client.ageRange;
    String district = client.district;
    String category = client.category;
    final noteCtrl = TextEditingController(text: client.note);
    DateTime joinDate = client.joinDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        final border = isDark ? AppColors.borderDark : AppColors.border;
        final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => MaxWidthContainer(
            maxWidth: 500,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dialog(
                backgroundColor: surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                insetPadding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Edit Client',
                              style: TextStyle(
                                fontSize: Theme.of(ctx).textTheme.titleLarge?.fontSize,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Case ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: caseIdCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          decoration: InputDecoration(
                            hintText: 'e.g. CAS-001',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          decoration: InputDecoration(
                            hintText: 'e.g. John Doe',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.person_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                                  const SizedBox(height: 8),
                                  ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: gender,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: AppRadius.roundedSm,
                                          borderSide: BorderSide(color: border),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: AppRadius.roundedSm,
                                          borderSide: BorderSide(color: border),
                                        ),
                                      ),
                                      items: ['Male', 'Female']
                                          .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black,
                                          ))))
                                          .toList(),
                                      onChanged: (v) => setDialogState(() => gender = v!),
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
                                  Text('Age Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                                  const SizedBox(height: 8),
                                  ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: ageRange,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: AppRadius.roundedSm,
                                          borderSide: BorderSide(color: border),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: AppRadius.roundedSm,
                                          borderSide: BorderSide(color: border),
                                        ),
                                      ),
                                      items: const ['0-5', '6-12', '13-17', '18-29', '30-39', '40-49', '50-59', '60-69', '70-89', '90-100+']
                                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                          .toList(),
                                      onChanged: (v) => setDialogState(() => ageRange = v!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: addressCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          decoration: InputDecoration(
                            hintText: 'e.g. 123 Main Street',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('District', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            const districts = [
                              'Bagerhat', 'Bandarban', 'Barguna', 'Barisal', 'Bhola', 'Bogra',
                              'Brahmanbaria', 'Chandpur', 'Chittagong', 'Chuadanga', 'Comilla',
                              "Cox's Bazar", 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni', 'Gaibandha',
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
                            showDialog(
                              context: ctx,
                              builder: (pickerCtx) {
                                final searchCtrl = TextEditingController();
                                String filter = '';
                                return StatefulBuilder(
                                  builder: (pickerCtx, setPickerState) => Dialog(
                                    backgroundColor: surface,
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
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textPrimary)),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close_rounded, color: textSecondary),
                                                onPressed: () => Navigator.pop(pickerCtx),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          TextField(
                                            controller: searchCtrl,
                                            autofocus: true,
                                            style: TextStyle(color: textPrimary),
                                            decoration: InputDecoration(
                                              hintText: 'Search district...',
                                              hintStyle: TextStyle(color: textSecondary),
                                              prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                                              filled: true,
                                              fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                                              border: OutlineInputBorder(
                                                borderRadius: AppRadius.roundedMd,
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (v) => setPickerState(() => filter = v.toLowerCase()),
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxHeight: 300),
                                            child: ListView(
                                              shrinkWrap: true,
                                              children: districts
                                                  .where((d) => filter.isEmpty || d.toLowerCase().contains(filter))
                                                  .map((d) => ListTile(
                                                        dense: true,
                                                        title: Text(d, style: TextStyle(color: textPrimary)),
                                                        trailing: district == d
                                                            ? Icon(Icons.check, color: AppColors.primary, size: 20)
                                                            : null,
                                                        onTap: () {
                                                          setDialogState(() => district = d);
                                                          Navigator.pop(pickerCtx);
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
                          },
                          borderRadius: AppRadius.roundedSm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: border),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.map_rounded, size: 20, color: textSecondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    district.isNotEmpty ? district : 'Select district',
                                    style: TextStyle(
                                      color: district.isNotEmpty ? textPrimary : textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down_rounded, size: 20, color: textSecondary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'e.g. +8801XXXXXXXXX',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Alternate Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: alternatePhoneCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'e.g. +8801XXXXXXXXX',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: joinDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              helpText: 'Select join date',
                            );
                            if (picked != null) {
                              setDialogState(() => joinDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: border),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_rounded, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${joinDate.day.toString().padLeft(2, '0')}/${joinDate.month.toString().padLeft(2, '0')}/${joinDate.year}',
                                    style: TextStyle(color: textPrimary, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        Row(
                          children: Client.categories.map((cat) {
                            final selected = category == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: selected,
                                onSelected: (_) => setDialogState(() => category = cat),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Note / Injury Remark', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: noteCtrl,
                          maxLines: 3,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          decoration: InputDecoration(
                            hintText: 'e.g. injury details, special notes',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: textPrimary)),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () async {
                                if (caseIdCtrl.text.trim().isEmpty) return;
                                final updated = Client(
                                  id: client.id,
                                  organizationId: client.organizationId,
                                  counselorIds: client.counselorIds,
                                  caseId: caseIdCtrl.text.trim(),
                                  name: nameCtrl.text.trim(),
                                  address: addressCtrl.text.trim(),
                                  district: district,
                                  gender: gender,
                                  ageRange: ageRange,
                                  category: category,
                                  note: noteCtrl.text.trim(),
                                  createdAt: client.createdAt,
                                  joinDate: joinDate,
                                  phone: phoneCtrl.text.trim(),
                                  alternatePhone: alternatePhoneCtrl.text.trim(),
                                );
                                await ref.read(clientRepositoryProvider).updateClient(updated);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 48),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                              ),
                              child: const Text('Save'),
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
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Client client) async {
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
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
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
              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                      elevation: 0,
                      pinned: true,
                      floating: true,
                      snap: true,
                      centerTitle: false,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTab('About', 0),
                              _buildTab('Sessions', 1),
                              _buildTab('Assessments', 2),
                              _buildTab('Docs', 3),
                              _buildTab('Bill', 4),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, client);
                            } else if (value == 'delete') {
                              _confirmDelete(context, client);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
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
                                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    SizedBox(width: 12),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
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
                  padding: EdgeInsets.only(bottom: 1),
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


