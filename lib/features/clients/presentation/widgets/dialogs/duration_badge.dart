import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

class DurationBadge extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const DurationBadge({super.key, required this.startTime, required this.endTime});

  @override
  Widget build(BuildContext context) {
    final start = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    final end = DateTime(2000, 1, 1, endTime.hour, endTime.minute);
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    String text;
    if (hours > 0 && minutes > 0) {
      text = '${hours}h ${minutes}m';
    } else if (hours > 0) {
      text = '${hours}h';
    } else {
      text = '${minutes}m';
    }

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
      ],
    );
  }
}
