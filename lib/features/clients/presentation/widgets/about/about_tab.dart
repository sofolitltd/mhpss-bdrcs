import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../contacts/domain/counselor.dart';
import '../../../../contacts/presentation/providers/contacts_providers.dart';
import '../../../data/client_repository.dart';
import '../../../domain/models/client.dart';
import 'add_counselor_dialog.dart';
import 'contact_tile.dart';
import 'info_card.dart';
import 'remove_counselor_dialog.dart';

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
      counselorIds: widget.client.counselorIds
          .where((id) => id != uid)
          .toList(),
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

  void _showAddCounselorDialog(
    BuildContext context,
    List<Counselor> counselors,
  ) {
    showAddCounselorDialog(
      context,
      counselors,
      widget.client.counselorIds.toSet(),
    ).then((selected) {
      if (selected != null && selected.isNotEmpty) {
        _addCounselors(selected);
      }
    });
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
    return showRemoveCounselorConfirmation(context, c);
  }

  @override
  Widget build(BuildContext context) {
    final counselorsAsync = ref.watch(allCounselorsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCard(
            title: 'General Information',
            children: [
              InfoRow(label: 'Case ID', value: widget.client.caseId),
              InfoRow(
                label: 'Name',
                value: widget.client.name.isNotEmpty
                    ? widget.client.capitalizedName
                    : 'N/A',
              ),
              if (widget.client.address.isNotEmpty)
                InfoRow(label: 'Address', value: widget.client.address),
              if (widget.client.district.isNotEmpty)
                InfoRow(label: 'District', value: widget.client.district),
              InfoRow(label: 'Gender', value: widget.client.gender),
              InfoRow(
                label: 'Age Range',
                value: widget.client.ageRange.isNotEmpty
                    ? '${widget.client.ageRange} years'
                    : 'N/A',
              ),
              if (widget.client.category.isNotEmpty)
                InfoRow(label: 'Category', value: widget.client.category),
              if (widget.client.note.isNotEmpty)
                InfoRow(
                  label: 'Note / Injury Remark',
                  value: widget.client.note,
                ),
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
          if ((widget.client.phone != null &&
                  widget.client.phone!.isNotEmpty) ||
              (widget.client.alternatePhone != null &&
                  widget.client.alternatePhone!.isNotEmpty))
            InfoCard(
              title: 'Contact',
              children: [
                if (widget.client.phone != null &&
                    widget.client.phone!.isNotEmpty)
                  ContactTile(
                    phone: widget.client.phone!,
                    label: 'Tap to call',
                    onTap: () => _launchCall(widget.client.phone!),
                  ),
                if (widget.client.alternatePhone != null &&
                    widget.client.alternatePhone!.isNotEmpty)
                  ContactTile(
                    phone: widget.client.alternatePhone!,
                    label: 'Alternate (tap to call)',
                    onTap: () => _launchCall(widget.client.alternatePhone!),
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
                      .map(
                        (uid) =>
                            allCounselors.where((c) => c.id == uid).firstOrNull,
                      )
                      .whereType<Counselor>()
                      .toList();

                  if (assignedCounselors.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        'No counselors assigned.',
                        style: TextStyle(color: textSecondary),
                      ),
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
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              child: Text(
                                c.name.isNotEmpty
                                    ? c.name[0].toUpperCase()
                                    : '?',
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
                                      final removed = await _confirmRemove(
                                        context,
                                        c,
                                      );
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
                  child: Text(
                    'Error loading counselors.',
                    style: TextStyle(color: textSecondary),
                  ),
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
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSm,
                    ),
                  ),
                  onPressed: () {
                    counselorsAsync.whenData(
                      (all) => _showAddCounselorDialog(context, all),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
