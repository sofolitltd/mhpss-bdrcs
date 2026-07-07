import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../providers/bills_providers.dart';
import 'bills_screen/bills_actions.dart';
import 'bills_screen/bills_table_section.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    final selectedMonth = ref.watch(selectedBillsMonthProvider);
    final monthNotifier = ref.read(selectedBillsMonthProvider.notifier);
    final isAllTime = monthNotifier.isAllTime;
    final sessionRowsAsync = ref.watch(billsSessionRowsProvider);
    final selectedSessions = ref.watch(selectedBillsSessionsProvider);
    final selectionNotifier = ref.read(selectedBillsSessionsProvider.notifier);

    String monthLabel = isAllTime
        ? 'All Time'
        : DateFormat('MMMM yyyy').format(selectedMonth);

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
                          'Bills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage sessions and generate travel allowance PDFs',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (selectedSessions.isNotEmpty)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: Text('Preview All (${selectedSessions.length})'),
                      onPressed: () => onGeneratePdf(
                        context,
                        ref,
                        sessionRowsAsync.value ?? [],
                        selectedSessions,
                      ),
                    ),
                ],
              ),
            ),
          ),
          MaxWidthContainer(
            padding: pagePadding(context).copyWith(top: 8, bottom: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: isAllTime ? null : monthNotifier.goToPrevious,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.border,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSm,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showMonthPicker(context, ref, selectedMonth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: isAllTime ? null : monthNotifier.goToNext,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.border,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSm,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  icon: Icon(
                    isAllTime
                        ? Icons.date_range_rounded
                        : Icons.all_inclusive_rounded,
                    size: 16,
                    color: textSecondary,
                  ),
                  label: Text(
                    isAllTime ? 'By Month' : 'All Time',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  onPressed: () {
                    if (isAllTime) {
                      monthNotifier.setMonth(DateTime.now());
                    } else {
                      monthNotifier.setAllTime();
                    }
                    selectionNotifier.deselectAll();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.lg),
                child: sessionRowsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, s) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ),
                  data: (rows) => BillsTableSection(
                    rows: rows,
                    selectedSessions: selectedSessions,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    border: border,
                    surface: surface,
                    isDark: isDark,
                    isAllTime: isAllTime,
                    monthLabel: monthLabel,
                    onToggle: (id) => selectionNotifier.toggle(id),
                    onSelectAll: (ids) => selectionNotifier.selectAll(ids),
                    onDeselectAll: () => selectionNotifier.deselectAll(),
                    onCreateBill: (row) =>
                        createBillForSession(context, ref, row),
                    onPreviewBill: (row) =>
                        previewSingleBill(context, ref, row),
                    onGeneratePdf: () =>
                        onGeneratePdf(context, ref, rows, selectedSessions),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
