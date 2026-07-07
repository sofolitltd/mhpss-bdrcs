import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class DateField extends StatelessWidget {
  final DateTime date;
  final Color textPrimary;
  final Color border;
  final ValueChanged<DateTime> onChanged;

  const DateField({
    super.key,
    required this.date,
    required this.textPrimary,
    required this.border,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: 'Select join date',
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: AppRadius.roundedSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: TextStyle(color: textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
