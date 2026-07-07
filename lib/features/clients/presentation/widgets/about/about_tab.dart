import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../contacts/domain/counselor.dart';
import '../../../../contacts/presentation/providers/contacts_providers.dart';
import '../../../data/client_repository.dart';
import '../../../domain/models/client.dart';
import 'info_card.dart';

class AboutTab extends ConsumerStatefulWidget {
  final Client client;

  const AboutTab({super.key, required this.client});

  @override
  ConsumerState<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends ConsumerState<AboutTab> {
  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'\s+'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _removeCounselor(String uid) async {
    final updated = Client(
      id: widget.client.id,
      organizationId: widget.client.organizationId,
      counselorIds: widget.client.counselorIds.where((id) => id != uid).toList(),
      caseId: widget.client.caseId,
      name: widget.client.name,
      address: widget.client.address,
      district: widget.client.district,
      gender: widget.client.gender,
      ageRange: widget.client.ageRange,
      category: widget.client.category,
      note: widget.client.note,
      createdAt: widget.client.createdAt,
      joinDate: widget.client.joinDate,
      phone: widget.client.phone,
      alternatePhone: widget.client.alternatePhone,
    );
    await ref.read(clientRepositoryProvider).updateClient(updated);
  }

  void _showAddCounselorDialog(BuildContext context, List<Counselor> counselors) {
    final assigned = widget.client.counselorIds.toSet();
    final available = counselors.where((c) => !assigned.contains(c.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All counselors are already assigned.')),
      );
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
        final border = isDark ? AppColors.borderDark : AppColors.border;

        final selected = <String>{};

        return StatefulBuilder(
          builder: (ctx, setDialogState) => MaxWidthContainer(
            maxWidth: 500,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dialog(
                backgroundColor: surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                insetPadding: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 320,
                      maxHeight: screenHeight * 0.75,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_add_rounded, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Add Counselor',
                                style: TextStyle(
                                  fontSize: Theme.of(ctx).textTheme.titleLarge?.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: available.isEmpty
                              ? Center(
                                  child: Text('No counselors available to add.',
                                      style: TextStyle(color: textSecondary)),
                                )
                              : ListView(
                                  children: available.map((c) {
                                    final isSelected = selected.contains(c.id);
                                    return InkWell(
                                      borderRadius: AppRadius.roundedSm,
                                      onTap: () {
                                        setDialogState(() {
                                          if (isSelected) {
                                            selected.remove(c.id);
                                          } else {
                                            selected.add(c.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(color: border, width: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  AppColors.primary.withValues(alpha: 0.15),
                                              child: Text(
                                                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    c.name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: textPrimary,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${c.employeeId}${c.designation.isNotEmpty ? ' — ${c.designation}' : ''}',
                                                    style: TextStyle(
                                                        color: textSecondary, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isSelected
                                                  ? Icons.check_circle_rounded
                                                  : Icons.radio_button_unchecked_rounded,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : textSecondary,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: textPrimary)),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(140, 48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.roundedMd),
                              ),
                              onPressed: selected.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                      _addCounselors(selected.toList());
                                    },
                              child: Text('Add (${selected.length})'),
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

  Future<void> _addCounselors(List<String> uids) async {
    final updated = Client(
      id: widget.client.id,
      organizationId: widget.client.organizationId,
      counselorIds: [
        ...widget.client.counselorIds,
        ...uids.where((uid) => !widget.client.counselorIds.contains(uid)),
      ],
      caseId: widget.client.caseId,
      name: widget.client.name,
      address: widget.client.address,
      district: widget.client.district,
      gender: widget.client.gender,
      ageRange: widget.client.ageRange,
      category: widget.client.category,
      note: widget.client.note,
      createdAt: widget.client.createdAt,
      joinDate: widget.client.joinDate,
      phone: widget.client.phone,
      alternatePhone: widget.client.alternatePhone,
    );
    await ref.read(clientRepositoryProvider).updateClient(updated);
  }

  Future<bool> _confirmRemove(BuildContext context, Counselor c) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => MaxWidthContainer(
        maxWidth: 500,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Dialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
            insetPadding: const EdgeInsets.all(12),
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
                      const Icon(Icons.person_remove_rounded, color: Colors.red),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Remove Counselor',
                          style: TextStyle(
                            fontSize: Theme.of(ctx).textTheme.titleLarge?.fontSize,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Remove ${c.name} from this client?',
                    style: TextStyle(color: textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel', style: TextStyle(color: textPrimary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return confirm == true;
  }

  @override
  Widget build(BuildContext context) {
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: 'General Information',
            children: [
              InfoRow(label: 'Case ID', value: widget.client.caseId),
              InfoRow(label: 'Name', value: widget.client.name.isNotEmpty ? widget.client.name : 'N/A'),
              if (widget.client.address.isNotEmpty)
                InfoRow(label: 'Address', value: widget.client.address),
              if (widget.client.district.isNotEmpty)
                InfoRow(label: 'District', value: widget.client.district),
              InfoRow(label: 'Gender', value: widget.client.gender),
              InfoRow(label: 'Age Range', value: widget.client.ageRange.isNotEmpty ? '${widget.client.ageRange} years' : 'N/A'),
              if (widget.client.category.isNotEmpty)
                InfoRow(label: 'Category', value: widget.client.category),
              if (widget.client.note.isNotEmpty)
                InfoRow(label: 'Note / Injury Remark', value: widget.client.note),
              InfoRow(
                label: 'Join Date',
                value: widget.client.joinDate != null
                    ? DateFormat.yMMMd().format(widget.client.joinDate!)
                    : 'N/A',
              ),
              InfoRow(
                label: 'Registered On',
                value: DateFormat.yMMMd().format(widget.client.createdAt),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if ((widget.client.phone != null && widget.client.phone!.isNotEmpty) ||
              (widget.client.alternatePhone != null && widget.client.alternatePhone!.isNotEmpty))
            InfoCard(
              title: 'Contact',
              children: [
                if (widget.client.phone != null && widget.client.phone!.isNotEmpty)
                  InkWell(
                    onTap: () => _launchCall(widget.client.phone!),
                    borderRadius: AppRadius.roundedSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.client.phone!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Tap to call',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.call_made_rounded, size: 18, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                if (widget.client.alternatePhone != null && widget.client.alternatePhone!.isNotEmpty)
                  InkWell(
                    onTap: () => _launchCall(widget.client.alternatePhone!),
                    borderRadius: AppRadius.roundedSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.client.alternatePhone!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Alternate (tap to call)',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.call_made_rounded, size: 18, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            title: 'Counselors',
            children: [
              counselorsAsync.when(
                data: (allCounselors) {
                  final assignedCounselors = widget.client.counselorIds
                      .map((uid) => allCounselors.where((c) => c.id == uid).firstOrNull)
                      .whereType<Counselor>()
                      .toList();

                  if (assignedCounselors.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text('No counselors assigned.', style: TextStyle(color: textSecondary)),
                    );
                  }

                  return Column(
                    children: assignedCounselors.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (c.designation.isNotEmpty)
                                    Text(
                                      c.designation,
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: widget.client.counselorIds.length <= 1
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : Colors.red,
                              ),
                              onPressed: widget.client.counselorIds.length <= 1
                                  ? null
                                  : () async {
                                      final removed = await _confirmRemove(context, c);
                                      if (removed) _removeCounselor(c.id);
                                    },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LinearProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('Error loading counselors.', style: TextStyle(color: textSecondary)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Counselor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                  ),
                  onPressed: () {
                    counselorsAsync.whenData((all) => _showAddCounselorDialog(context, all));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
