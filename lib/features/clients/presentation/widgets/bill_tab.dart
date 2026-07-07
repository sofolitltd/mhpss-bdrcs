import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../data/bill_repository.dart';
import '../../domain/models/bill.dart';
import '../providers/bill_providers.dart';
import '../providers/client_detail_providers.dart';
import 'bill/bill_form_screen.dart';
import 'bill/bill_table_widgets.dart';

export 'bill/bill_form_screen.dart';
export 'bill/bill_table_widgets.dart';

class BillTab extends ConsumerStatefulWidget {
  final String clientId;
  final String clientCaseId;

  const BillTab({
    super.key,
    required this.clientId,
    required this.clientCaseId,
  });

  @override
  ConsumerState<BillTab> createState() => _BillTabState();
}

class _BillTabState extends ConsumerState<BillTab> {
  Future<void> _createBill() async {
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .getSessionsByClientId(widget.clientId);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BillFormScreen(clientId: widget.clientId, allSessions: sessions),
      ),
    );
  }

  Future<void> _viewBill(Bill bill) async {
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .getSessionsByClientId(widget.clientId);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillFormScreen(
          clientId: widget.clientId,
          allSessions: sessions,
          existingBill: bill,
        ),
      ),
    );
  }

  Future<void> _deleteBill(Bill bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Delete TA Bill from ${DateFormat('dd/MM/yyyy').format(bill.fromDate)} to ${DateFormat('dd/MM/yyyy').format(bill.toDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(billRepositoryProvider).deleteBill(bill.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bill deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting bill: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final billsAsync = ref.watch(clientBillsProvider(widget.clientId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_rounded, size: 64,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.md),
                  Text('No bills yet', style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final tableWidth = availableWidth < 520 ? 520.0 : availableWidth;
                final colIndex = 32.0;
                final paddingH = 24.0;
                final flexSpace = tableWidth - colIndex - 8 - paddingH - 2;
                final colDates = flexSpace * 22 / 80;
                final colTA = flexSpace * 11 / 80;
                final colDA = flexSpace * 11 / 80;
                final colMobile = flexSpace * 11 / 80;
                final colTotal = flexSpace * 11 / 80;
                final colActions = flexSpace - colDates - colTA - colDA - colMobile - colTotal;
                return ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BillTableHeader(
                            colDates: colDates, colTA: colTA, colDA: colDA,
                            colMobile: colMobile, colTotal: colTotal, colActions: colActions,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < bills.length; i++)
                                  BillListItem(
                                    index: i, bill: bills[i],
                                    colDates: colDates, colTA: colTA, colDA: colDA,
                                    colMobile: colMobile, colTotal: colTotal, colActions: colActions,
                                    onTap: () => _viewBill(bills[i]),
                                    onDelete: () => _deleteBill(bills[i]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Bill'),
        onPressed: _createBill,
      ),
    );
  }
}
