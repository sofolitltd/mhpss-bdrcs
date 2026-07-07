import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class TotalsCard extends StatelessWidget {
  final int totalTA;
  final int totalDA;
  final int grandTotal;
  final Color textColor;

  const TotalsCard({
    super.key,
    required this.totalTA,
    required this.totalDA,
    required this.grandTotal,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TotalRowWidget(
              label: 'Total TA',
              amount: totalTA,
              textColor: textColor,
            ),
            TotalRowWidget(
              label: 'Total DA',
              amount: totalDA,
              textColor: textColor,
            ),
            const Divider(),
            TotalRowWidget(
              label: 'Grand Total',
              amount: grandTotal,
              textColor: textColor,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class TotalRowWidget extends StatelessWidget {
  final String label;
  final int amount;
  final Color textColor;
  final bool bold;

  const TotalRowWidget({
    super.key,
    required this.label,
    required this.amount,
    required this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            '$amount',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: bold ? 18 : 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
