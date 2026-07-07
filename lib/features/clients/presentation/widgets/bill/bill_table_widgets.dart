import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/models/bill.dart';

class BillTableHeader extends StatelessWidget {
  final double colDates;
  final double colTA;
  final double colDA;
  final double colMobile;
  final double colTotal;
  final double colActions;

  const BillTableHeader({
    super.key,
    required this.colDates,
    required this.colTA,
    required this.colDA,
    required this.colMobile,
    required this.colTotal,
    required this.colActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32),
          const SizedBox(width: 8),
          SizedBox(
            width: colDates,
            child: Text(
              'Session Dates',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            width: colTA,
            child: Text(
              'TA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            width: colDA,
            child: Text(
              'DA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            width: colMobile,
            child: Text(
              'Mobile',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            width: colTotal,
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            width: colActions,
            child: Text(
              '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillListItem extends StatelessWidget {
  final int index;
  final Bill bill;
  final double colDates;
  final double colTA;
  final double colDA;
  final double colMobile;
  final double colTotal;
  final double colActions;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BillListItem({
    super.key,
    required this.index,
    required this.bill,
    required this.colDates,
    required this.colTA,
    required this.colDA,
    required this.colMobile,
    required this.colTotal,
    required this.colActions,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd-MM-yy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final sessionDates = bill.taGroups
        .map((g) => dateFmt.format(g.date))
        .join(', ');
    final mobileAllowance =
        bill.taGroups.where((g) => g.includeMobile).length * 300;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: index.isOdd ? AppColors.primary.withValues(alpha: 0.04) : null,
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: colDates,
              child: Text(
                sessionDates,
                style: TextStyle(fontSize: 12, color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: colTA,
              child: Text(
                '${bill.totalTA}',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ),
            SizedBox(
              width: colDA,
              child: Text(
                '${bill.totalDA}',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ),
            SizedBox(
              width: colMobile,
              child: Text(
                mobileAllowance > 0 ? '$mobileAllowance' : '-',
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ),
            SizedBox(
              width: colTotal,
              child: Text(
                '${bill.grandTotal}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(
              width: colActions,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
