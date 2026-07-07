import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/core/widgets/card_action_button.dart';
import '../../../domain/session.dart';

class SessionListItem extends StatelessWidget {
  final Session session;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SessionListItem({
    super.key,
    required this.session,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = session.title.isNotEmpty
        ? session.title
        : 'Session $index';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateText = DateFormat.yMMMd().format(session.date);

    String? timeText;
    if (session.startTime != null && session.endTime != null) {
      final duration = session.endTime!.difference(session.startTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final durStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      timeText = '${DateFormat('hh:mm a').format(session.startTime!)} - ${DateFormat('hh:mm a').format(session.endTime!)} ($durStr)';
    } else if (session.startTime != null) {
      timeText = DateFormat('hh:mm a').format(session.startTime!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: session.status == 'completed'
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session.status.capitalizeFirst(),
                      style: TextStyle(
                        fontSize: 10,
                        color: session.status == 'completed'
                            ? Colors.green
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              if (session.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  session.notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                spacing: 4,
                children: [
                  if (timeText != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  CardActionButton(
                    icon: Icons.edit,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 4),
                  CardActionButton(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
