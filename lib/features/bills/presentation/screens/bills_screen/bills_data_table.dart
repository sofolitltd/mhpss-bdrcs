import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/design_system/app_design_system.dart';
import '../../providers/bills_providers.dart';
import 'bills_helpers.dart';

Widget _header(String name) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

class BillsDataTable extends StatelessWidget {
  final List<BillSessionRow> rows;
  final Set<String> selectedSessions;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final bool isDark;
  final void Function(List<String> ids, bool selected) onSelectAll;
  final void Function(String id) onToggle;
  final void Function(BillSessionRow row) onCreateBill;
  final void Function(BillSessionRow row) onPreviewBill;

  const BillsDataTable({
    super.key,
    required this.rows,
    required this.selectedSessions,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.isDark,
    required this.onSelectAll,
    required this.onToggle,
    required this.onCreateBill,
    required this.onPreviewBill,
  });

  @override
  Widget build(BuildContext context) {
    final ids = rows.map((r) => r.session.id).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        return ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: tableWidth),
              child: DataTable(
                showCheckboxColumn: true,
                headingRowColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.08),
                ),
                border: TableBorder.all(
                  color: border,
                  borderRadius: AppRadius.roundedSm,
                ),
                columnSpacing: 12,
                onSelectAll: (v) {
                  onSelectAll(ids, v ?? false);
                },
                columns: [
                  DataColumn(label: _header('ID')),
                  DataColumn(label: _header('Name')),
                  DataColumn(label: _header('Date')),
                  DataColumn(label: _header('Session')),
                  DataColumn(label: _header('TA')),
                  DataColumn(label: _header('DA')),
                  DataColumn(label: _header('Mobile')),
                  DataColumn(label: _header('Total')),
                  DataColumn(label: _header('')),
                ],
                rows: rows.map((row) {
                  final isSelected = selectedSessions.contains(row.session.id);
                  return DataRow(
                    selected: isSelected,
                    onSelectChanged: (_) => onToggle(row.session.id),
                    cells: [
                      _idCell(row, textPrimary),
                      _nameCell(row, textPrimary),
                      _dateCell(row, textPrimary),
                      _sessionCell(row, textPrimary),
                      _taCell(row, textPrimary, () => onCreateBill(row)),
                      _daCell(row, textPrimary),
                      _mobileCell(row, textPrimary),
                      _totalCell(row, textPrimary),
                      _actionsCell(
                        () => onPreviewBill(row),
                        () => onCreateBill(row),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataCell _idCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Text(row.client?.caseId ?? '–', style: TextStyle(color: textPrimary)),
    );
  }

  DataCell _nameCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Text(
        row.client?.capitalizedName ?? '–',
        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _dateCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Text(
        DateFormat('dd-MM-yyyy').format(row.session.date),
        style: TextStyle(color: textPrimary),
      ),
    );
  }

  DataCell _sessionCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Center(
        child: Text(
          sessionLabel(row.sessionNumber),
          style: TextStyle(color: textPrimary),
        ),
      ),
    );
  }

  DataCell _taCell(BillSessionRow row, Color textPrimary, VoidCallback onEdit) {
    return DataCell(
      Center(
        child: row.totalTA > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${row.totalTA}', style: TextStyle(color: textPrimary)),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF999999),
                  ),
                ],
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18,
                  color: Color(0xFF999999),
                ),
              ),
      ),
      onTap: onEdit,
    );
  }

  DataCell _daCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Center(
        child: Text('700', style: TextStyle(color: textPrimary)),
      ),
    );
  }

  DataCell _mobileCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Center(
        child: () {
          final mobileRow = row.existingBill?.daRows
              .where((d) => d.isOptional)
              .firstOrNull;
          final hasMobile = mobileRow != null && mobileRow.days > 0;
          return Text(
            hasMobile ? '${mobileRow.total}' : '–',
            style: TextStyle(color: textPrimary),
          );
        }(),
      ),
    );
  }

  DataCell _totalCell(BillSessionRow row, Color textPrimary) {
    return DataCell(
      Center(
        child: () {
          final mobileTotal =
              (row.existingBill?.taGroups
                      .where((g) => g.includeMobile)
                      .length ??
                  0) *
              300;
          final total = row.totalTA + 700 + mobileTotal;
          return Text(
            '$total',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          );
        }(),
      ),
    );
  }

  DataCell _actionsCell(VoidCallback onPreview, VoidCallback onEdit) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onPreview,
              child: const Icon(
                Icons.remove_red_eye_outlined,
                size: 16,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onEdit,
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
