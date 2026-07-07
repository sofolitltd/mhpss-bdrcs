import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_design_system.dart';
import '../../providers/bills_providers.dart';
import 'bills_data_table.dart';
import 'bills_helpers.dart';

class BillsTableSection extends StatelessWidget {
  final List<BillSessionRow> rows;
  final Set<String> selectedSessions;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final bool isDark;
  final bool isAllTime;
  final String monthLabel;
  final void Function(String id) onToggle;
  final void Function(List<String> ids) onSelectAll;
  final void Function() onDeselectAll;
  final void Function(BillSessionRow row) onCreateBill;
  final void Function(BillSessionRow row) onPreviewBill;
  final void Function() onGeneratePdf;

  const BillsTableSection({
    super.key,
    required this.rows,
    required this.selectedSessions,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.isDark,
    required this.isAllTime,
    required this.monthLabel,
    required this.onToggle,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onCreateBill,
    required this.onPreviewBill,
    required this.onGeneratePdf,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            const SizedBox(height: 16),
            Text(
              isAllTime ? 'No sessions found' : 'No sessions in $monthLabel',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BillsDataTable(
            rows: rows,
            selectedSessions: selectedSessions,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            border: border,
            isDark: isDark,
            onSelectAll: (allIds, selected) {
              if (selected) {
                onSelectAll(allIds);
              } else {
                onDeselectAll();
              }
            },
            onToggle: onToggle,
            onCreateBill: onCreateBill,
            onPreviewBill: onPreviewBill,
          ),
          if (selectedSessions.isNotEmpty) _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          buildTotalsRow(rows, selectedSessions, textPrimary, textSecondary),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${selectedSessions.length} session${selectedSessions.length == 1 ? '' : 's'} selected',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const Spacer(),
              TextButton(
                onPressed: onDeselectAll,
                child: const Text('Clear selection'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: const Text('Generate Bills'),
                onPressed: onGeneratePdf,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
