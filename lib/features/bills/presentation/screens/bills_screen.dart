import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../../../../core/services/bill_pdf_generator.dart';
import '../../../clients/domain/models/bill.dart';
import '../../../clients/presentation/widgets/bill_tab.dart';
import '../../../clients/presentation/providers/client_detail_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bills_providers.dart';

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
          // ─── Top Bar ────────────────────────────────────────────────
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
                      onPressed: () => _onGeneratePdf(
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
          // ─── Month Picker Bar ─────────────────────────────────────────
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
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSm,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showMonthPicker(context, ref, selectedMonth),
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
                    shape: RoundedRectangleBorder(
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
          // ─── Table ──────────────────────────────────────────────────
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
                  data: (rows) {
                    if (rows.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isAllTime
                                  ? 'No sessions found'
                                  : 'No sessions in ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final ids = rows.map((r) => r.session.id).toList();

                    return Expanded(
                      child: SingleChildScrollView(
                        padding: pagePadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Table ─────────────────────────────────────
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final tableWidth = constraints.maxWidth;
                                return ScrollConfiguration(
                                  behavior: MyCustomScrollBehavior(),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: tableWidth,
                                      ),
                                      child: DataTable(
                                        showCheckboxColumn: true,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                              AppColors.primary.withValues(
                                                alpha: 0.08,
                                              ),
                                            ),
                                        border: TableBorder.all(
                                          color: border,
                                          borderRadius: AppRadius.roundedSm,
                                        ),
                                        columnSpacing: 12,
                                        onSelectAll: (v) {
                                          if (v == true) {
                                            selectionNotifier.selectAll(ids);
                                          } else {
                                            selectionNotifier.deselectAll();
                                          }
                                        },
                                        columns: const [
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'ID',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Name',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Date',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Session',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'TA',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'DA',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Mobile',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: rows.map((row) {
                                          final isSelected = selectedSessions
                                              .contains(row.session.id);
                                          return DataRow(
                                            selected: isSelected,
                                            onSelectChanged: (_) =>
                                                selectionNotifier.toggle(
                                                  row.session.id,
                                                ),
                                            cells: [
                                              DataCell(
                                                Text(
                                                  row.client?.caseId ?? '–',
                                                  style: TextStyle(
                                                    color: textPrimary,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  row.client?.capitalizedName ??
                                                      '–',
                                                  style: TextStyle(
                                                    color: textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  DateFormat(
                                                    'dd-MM-yyyy',
                                                  ).format(row.session.date),
                                                  style: TextStyle(
                                                    color: textPrimary,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    _sessionLabel(
                                                      row.sessionNumber,
                                                    ),
                                                    style: TextStyle(
                                                      color: textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: row.totalTA > 0
                                                      ? Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              '${row.totalTA}',
                                                              style: TextStyle(
                                                                color:
                                                                    textPrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 16,
                                                              color:
                                                                  const Color(
                                                                    0xFF999999,
                                                                  ),
                                                            ),
                                                          ],
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 8,
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .add_circle_outline_rounded,
                                                            size: 18,
                                                            color: const Color(
                                                              0xFF999999,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                onTap: () =>
                                                    _createBillForSession(
                                                      context,
                                                      ref,
                                                      row,
                                                    ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    '700',
                                                    style: TextStyle(
                                                      color: textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: () {
                                                    final mobileRow = row
                                                        .existingBill
                                                        ?.daRows
                                                        .where(
                                                          (d) => d.isOptional,
                                                        )
                                                        .firstOrNull;
                                                    final hasMobile =
                                                        mobileRow != null &&
                                                        mobileRow.days > 0;
                                                    return Text(
                                                      hasMobile
                                                          ? '${mobileRow.total}'
                                                          : '–',
                                                      style: TextStyle(
                                                        color: textPrimary,
                                                      ),
                                                    );
                                                  }(),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: () {
                                                    final mobileTotal =
                                                        (row.existingBill?.taGroups
                                                                .where(
                                                                  (g) =>
                                                                      g.includeMobile,
                                                                )
                                                                .length ??
                                                            0) *
                                                        300;
                                                    final total =
                                                        row.totalTA +
                                                        700 +
                                                        mobileTotal;
                                                    return Text(
                                                      '$total',
                                                      style: TextStyle(
                                                        color: textPrimary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    );
                                                  }(),
                                                ),
                                              ),
                                              DataCell(
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            _previewSingleBill(
                                                              context,
                                                              ref,
                                                              row,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          size: 16,
                                                          color: const Color(
                                                            0xFF999999,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      InkWell(
                                                        onTap: () =>
                                                            _createBillForSession(
                                                              context,
                                                              ref,
                                                              row,
                                                            ),
                                                        child: Icon(
                                                          Icons.edit_outlined,
                                                          size: 16,
                                                          color: const Color(
                                                            0xFF999999,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // ─── Footer ───────────────────────────────────
                            if (selectedSessions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: surface,
                                  border: Border(
                                    top: BorderSide(color: border),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildTotalsRow(
                                      rows,
                                      selectedSessions,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          '${selectedSessions.length} session${selectedSessions.length == 1 ? '' : 's'} selected',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed:
                                              selectionNotifier.deselectAll,
                                          child: const Text('Clear selection'),
                                        ),
                                        const SizedBox(width: 12),
                                        FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                          ),
                                          icon: const Icon(
                                            Icons.picture_as_pdf_rounded,
                                            size: 16,
                                          ),
                                          label: const Text('Generate Bills'),
                                          onPressed: () => _onGeneratePdf(
                                            context,
                                            ref,
                                            rows,
                                            selectedSessions,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sessionLabel(int number) {
    final suffixes = ['th', 'st', 'nd', 'rd'];
    final suffix = (number >= 11 && number <= 13)
        ? 'th'
        : suffixes[number % 10 < 4 ? number % 10 : 0];
    return '$number$suffix';
  }

  Widget _buildTotalsRow(
    List<BillSessionRow> rows,
    Set<String> selectedSessions,
    Color textPrimary,
    Color textSecondary,
  ) {
    final selected = rows.where((r) => selectedSessions.contains(r.session.id));
    final uniqueDates = selected
        .map(
          (r) => DateTime(
            r.session.date.year,
            r.session.date.month,
            r.session.date.day,
          ),
        )
        .toSet()
        .length;
    final pocketMoney = uniqueDates * 500;
    final lunchAllowance = uniqueDates * 200;
    final daTotal = pocketMoney + lunchAllowance;
    final taTotal = selected.fold(0, (int sum, r) {
      if (r.existingBill == null) return sum;
      return sum + r.existingBill!.totalTA;
    });
    final grandTotal = taTotal + daTotal;

    return Row(
      children: [
        Text(
          'TA: $taTotal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'DA: $daTotal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '($pocketMoney + $lunchAllowance)',
          style: TextStyle(fontSize: 11, color: textSecondary),
        ),
        const Spacer(),
        Text(
          'Total: $grandTotal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  void _createBillForSession(
    BuildContext context,
    WidgetRef ref,
    BillSessionRow row,
  ) async {
    final clientId = row.client?.id;
    if (clientId == null) return;
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .getSessionsByClientId(clientId);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillFormScreen(
          clientId: clientId,
          allSessions: sessions,
          existingBill: row.existingBill,
          preselectedSessionIds: row.existingBill != null
              ? null
              : {row.session.id},
        ),
      ),
    );
    if (!context.mounted) return;
    ref.invalidate(billsSessionRowsProvider);
  }

  Future<void> _showMonthPicker(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current.year == 1970 ? DateTime.now() : current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select Month',
    );
    if (picked != null) {
      ref.read(selectedBillsMonthProvider.notifier).setMonth(picked);
      ref.read(selectedBillsSessionsProvider.notifier).deselectAll();
    }
  }

  Future<void> _previewSingleBill(
    BuildContext context,
    WidgetRef ref,
    BillSessionRow row,
  ) async {
    if (row.existingBill != null) {
      await BillPdfGenerator.preview(row.existingBill!, showSummary: false);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No bill data to preview. Add TA data first.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _onGeneratePdf(
    BuildContext context,
    WidgetRef ref,
    List<BillSessionRow> rows,
    Set<String> selectedIds,
  ) async {
    final authState = ref.read(authProvider);
    final selectedRows = rows
        .where((r) => selectedIds.contains(r.session.id))
        .toList();
    if (selectedRows.isEmpty) return;

    // Validate: at least one bill has Mobile Allowance checked
    final hasMobileAllowance = selectedRows.any(
      (r) =>
          r.existingBill?.taGroups.any((g) => g.includeMobile) == true,
    );
    if (!hasMobileAllowance) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Mobile Allowance Required'),
            content: const Text(
              'At least one bill must have Mobile Allowance checked.\n\n'
              'Please edit a bill and enable "Include Mobile Allowance" '
              'under Daily Allowance before generating the PDF.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Validate: no duplicate dates
    final dateSet = <DateTime>{};
    for (final r in selectedRows) {
      final key = DateTime(
        r.session.date.year,
        r.session.date.month,
        r.session.date.day,
      );
      if (!dateSet.add(key)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Duplicate dates are not allowed'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
        return;
      }
    }

    selectedRows.sort((a, b) => a.session.date.compareTo(b.session.date));

    // Group into TaDateGroups
    final groupMap = <DateTime, List<BillSessionRow>>{};
    for (final row in selectedRows) {
      final dayKey = DateTime(
        row.session.date.year,
        row.session.date.month,
        row.session.date.day,
      );
      groupMap.putIfAbsent(dayKey, () => []).add(row);
    }

    final taGroups = groupMap.entries.map((entry) {
      // Check if any row in this date group has an existing bill with TA legs
      Bill? existingBill;
      for (final r in entry.value) {
        if (r.existingBill != null) {
          existingBill = r.existingBill;
          break;
        }
      }

      // Find matching TaDateGroup from existing bill for this date
      final existingGroup = existingBill?.taGroups.where(
        (g) =>
            g.date.year == entry.key.year &&
            g.date.month == entry.key.month &&
            g.date.day == entry.key.day,
      );

      if (existingGroup != null && existingGroup.isNotEmpty) {
        // Use the actual TA data from the existing bill
        return TaDateGroup(
          date: entry.key,
          legs: existingGroup.first.legs,
          includeMobile: existingGroup.first.includeMobile,
        );
      }

      final legList = entry.value.map((row) {
        final clientName = row.client?.capitalizedName ?? '';
        return TaLeg(
          from: 'Office',
          to: clientName,
          mode: 'CNG/Rickshaw',
          fare: 0,
          remarks:
              '${row.sessionNumber}${_ordinalSuffix(row.sessionNumber)} visit',
        );
      }).toList();
      return TaDateGroup(date: entry.key, legs: legList);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    final fromDate = taGroups.first.date;
    final toDate = taGroups.last.date;

    final taTotal = 0;
    final daDays = taGroups.length;
    final pocketTotal = daDays * 500;
    final lunchTotal = daDays * 200;
    final mobileTotal = taGroups.where((g) => g.includeMobile).length * 300;
    final daTotal = pocketTotal + lunchTotal + mobileTotal;

    final bill = Bill(
      id: '',
      clientId: 'multi',
      counselorId: authState.uid ?? '',
      organizationId: authState.organizationId ?? '',
      counselorName: authState.name ?? '',
      designation: authState.designation ?? 'Counselor',
      department: 'Health',
      purpose: 'Home visit to provide psychosocial support',
      fromDate: fromDate,
      toDate: toDate,
      taGroups: taGroups,
      daRows: [
        DaRow(
          label: 'Pocket Money',
          days: daDays,
          rate: 500,
          total: pocketTotal,
        ),
        DaRow(
          label: 'Lunch Allowance',
          days: daDays,
          rate: 200,
          total: lunchTotal,
        ),
      ],
      totalTA: taTotal,
      totalDA: daTotal,
      grandTotal: taTotal + daTotal,
      createdAt: DateTime.now(),
    );

    try {
      await BillPdfGenerator.preview(bill, showSummary: true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  String _ordinalSuffix(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
