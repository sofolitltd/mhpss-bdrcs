import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/bill_pdf_generator.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../clients/domain/models/bill.dart';
import '../../../../clients/presentation/providers/client_detail_providers.dart';
import '../../../../clients/presentation/widgets/bill/bill_form_screen.dart';
import '../../providers/bills_providers.dart';

Future<void> createBillForSession(
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

Future<void> showMonthPicker(
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
    helpText: 'Select Period',
  );
  if (picked != null) {
    final targetMonth = picked.day >= 21
        ? picked.month == 12
            ? DateTime(picked.year + 1, 1, 1)
            : DateTime(picked.year, picked.month + 1, 1)
        : DateTime(picked.year, picked.month, 1);
    ref.read(selectedBillsMonthProvider.notifier).setMonth(targetMonth);
    ref.read(selectedBillsSessionsProvider.notifier).deselectAll();
  }
}

Future<void> previewSingleBill(
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
          backgroundColor: Color(0xFFF43F5E),
        ),
      );
    }
  }
}

Future<void> onGeneratePdf(
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

  final hasMobileAllowance = selectedRows.any(
    (r) => r.existingBill?.taGroups.any((g) => g.includeMobile) == true,
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
          backgroundColor: Color(0xFFF43F5E),
          ),
        );
      }
      return;
    }
  }

  selectedRows.sort((a, b) => a.session.date.compareTo(b.session.date));

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
    Bill? existingBill;
    for (final r in entry.value) {
      if (r.existingBill != null) {
        existingBill = r.existingBill;
        break;
      }
    }

    final existingGroup = existingBill?.taGroups.where(
      (g) =>
          g.date.year == entry.key.year &&
          g.date.month == entry.key.month &&
          g.date.day == entry.key.day,
    );

    if (existingGroup != null && existingGroup.isNotEmpty) {
      return TaDateGroup(
        date: entry.key,
        legs: existingGroup.first.legs,
        includeMobile: existingGroup.first.includeMobile,
      );
    }

    final legList = entry.value.map((row) {
      return TaLeg(
        from: '',
        to: '',
        mode: '',
        fare: 0,
        remarks: '',
      );
    }).toList();
    return TaDateGroup(date: entry.key, legs: legList);
  }).toList()..sort((a, b) => a.date.compareTo(b.date));

  final fromDate = taGroups.first.date;
  final toDate = taGroups.last.date;

  const taTotal = 0;
  final daDays = taGroups.length;
  final pocketTotal = daDays * 500;
  final lunchTotal = daDays * 200;
  final daTotal = pocketTotal + lunchTotal;

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
      DaRow(label: 'Pocket Money', days: daDays, rate: 500, total: pocketTotal),
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
          backgroundColor: const Color(0xFFF43F5E),
        ),
      );
    }
  }
}
