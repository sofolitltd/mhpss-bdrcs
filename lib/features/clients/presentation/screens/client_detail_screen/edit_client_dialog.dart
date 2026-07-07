import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '../../data/client_repository.dart';
import '../../domain/models/client.dart';
import 'edit_client_form.dart';

class EditClientDialog extends ConsumerStatefulWidget {
  final Client client;

  const EditClientDialog({super.key, required this.client});

  static Future<void> show(BuildContext context, Client client) {
    return showDialog(
      context: context,
      builder: (_) => EditClientDialog(client: client),
    );
  }

  @override
  ConsumerState<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends ConsumerState<EditClientDialog> {
  late TextEditingController caseIdCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController alternatePhoneCtrl;
  late TextEditingController noteCtrl;
  late String gender;
  late String ageRange;
  late String district;
  late String category;
  late DateTime joinDate;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    caseIdCtrl = TextEditingController(text: c.caseId);
    nameCtrl = TextEditingController(text: c.name);
    addressCtrl = TextEditingController(text: c.address);
    phoneCtrl = TextEditingController(text: c.phone ?? '');
    alternatePhoneCtrl = TextEditingController(text: c.alternatePhone ?? '');
    gender = c.gender;
    ageRange = c.ageRange;
    district = c.district;
    category = c.category;
    noteCtrl = TextEditingController(text: c.note);
    joinDate = c.joinDate ?? DateTime.now();
  }

  @override
  void dispose() {
    caseIdCtrl.dispose();
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    alternatePhoneCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (caseIdCtrl.text.trim().isEmpty) return;
    final c = widget.client;
    final updated = Client(
      id: c.id,
      organizationId: c.organizationId,
      counselorIds: c.counselorIds,
      caseId: caseIdCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      district: district,
      gender: gender,
      ageRange: ageRange,
      category: category,
      note: noteCtrl.text.trim(),
      createdAt: c.createdAt,
      joinDate: joinDate,
      phone: phoneCtrl.text.trim(),
      alternatePhone: alternatePhoneCtrl.text.trim(),
    );
    await ref.read(clientRepositoryProvider).updateClient(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
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
                  EditClientForm(
                    caseIdCtrl: caseIdCtrl,
                    nameCtrl: nameCtrl,
                    addressCtrl: addressCtrl,
                    phoneCtrl: phoneCtrl,
                    alternatePhoneCtrl: alternatePhoneCtrl,
                    noteCtrl: noteCtrl,
                    gender: gender,
                    ageRange: ageRange,
                    district: district,
                    category: category,
                    joinDate: joinDate,
                    onGenderChanged: (v) => setState(() => gender = v),
                    onAgeRangeChanged: (v) => setState(() => ageRange = v),
                    onDistrictChanged: (v) => setState(() => district = v),
                    onCategoryChanged: (v) => setState(() => category = v),
                    onJoinDateChanged: (v) => setState(() => joinDate = v),
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    border: border,
                    surface: surface,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
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
    );
  }
}
