import 'package:flutter/material.dart';

import '../../providers/bills_providers.dart';

String sessionLabel(int number) {
  final suffixes = ['th', 'st', 'nd', 'rd'];
  final suffix = (number >= 11 && number <= 13)
      ? 'th'
      : suffixes[number % 10 < 4 ? number % 10 : 0];
  return '$number$suffix';
}

String ordinalSuffix(int n) {
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

Widget buildTotalsRow(
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
  final mobileTotal = selected.fold(0, (int sum, r) {
    if (r.existingBill == null) return sum;
    final count = r.existingBill!.taGroups
        .where((g) => g.includeMobile)
        .length;
    return sum + count * 300;
  });
  final grandTotal = taTotal + daTotal + mobileTotal;

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
      if (mobileTotal > 0) ...[
        const SizedBox(width: 16),
        Text(
          'Mobile: $mobileTotal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
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
