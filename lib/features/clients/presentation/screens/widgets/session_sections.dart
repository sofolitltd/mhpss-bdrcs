import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '/core/design_system/app_design_system.dart';

class SessionStatusSection extends StatelessWidget {
  final String fontFamily;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final String team;
  final String caseId;
  final String clientName;
  final String place;
  final DateTime sessionDate;
  final String title;

  const SessionStatusSection({
    super.key,
    required this.fontFamily,
    required this.status,
    required this.onStatusChanged,
    this.team = '',
    this.caseId = '',
    this.clientName = '',
    this.place = '',
    required this.sessionDate,
    this.title = '',
  });

  String _ordinal(String s) {
    final n = int.tryParse(s);
    if (n == null) return s;
    final i = n % 100;
    if (i >= 11 && i <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  String _shareText() {
    final dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final ordinalTitle = _ordinal(title);

    if (status == 'completed') {
      final doneDateStr = DateFormat('dd/MM/yyyy').format(sessionDate);
      return 'Team: $team\n'
          'Date: $dateStr\n'
          'Case ID: $caseId\n'
          "Respondent's Name: $clientName\n"
          '$ordinalTitle session Done: $doneDateStr\n'
          'Place: $place';
    }

    return 'Team: $team\n'
        'Date: $dateStr\n'
        'Case ID: $caseId\n'
        "Respondent's Name: $clientName\n"
        '$ordinalTitle session Will be taken: $dateStr\n'
        'Place: $place';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                tooltip: 'Copy to Clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _shareText()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.share_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                tooltip: 'Share Session',
                onPressed: () async {
                  try {
                    await SharePlus.instance
                        .share(ShareParams(text: _shareText()));
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Share failed: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: ['scheduled', 'completed', 'cancelled'].map((s) {
              final selected = status == s;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => onStatusChanged(s),
                backgroundColor: isDark ? AppColors.surfaceDark : null,
                selectedColor: s == 'completed'
                    ? Colors.green
                    : s == 'cancelled'
                    ? Colors.red
                    : AppColors.primary,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.white
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SessionFollowUpSection extends StatelessWidget {
  final String fontFamily;
  final DateTime? followUpDate;
  final VoidCallback onPickDate;
  final VoidCallback? onClearDate;

  const SessionFollowUpSection({
    super.key,
    required this.fontFamily,
    this.followUpDate,
    required this.onPickDate,
    this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-up Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: onPickDate,
            borderRadius: AppRadius.roundedSm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    followUpDate != null
                        ? DateFormat.yMMMd().format(followUpDate!)
                        : 'Set follow-up date (optional)',
                    style: TextStyle(
                      color: followUpDate != null
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                    ),
                  ),
                  if (followUpDate != null && onClearDate != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: onClearDate,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionNotesSection extends StatelessWidget {
  final String fontFamily;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SessionNotesSection({
    super.key,
    required this.fontFamily,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter session notes...',
              border: OutlineInputBorder(
                borderRadius: AppRadius.roundedSm,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
