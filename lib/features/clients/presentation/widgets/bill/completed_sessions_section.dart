import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/session.dart';
import 'section_card.dart';

class CompletedSessionsSection extends StatelessWidget {
  final List<Session> completedSessions;
  final Set<String> selectedSessionIds;
  final Color textColor;
  final bool isDark;
  final bool readOnly;
  final void Function(String sessionId, bool selected) onSessionToggled;
  final int daDays;

  const CompletedSessionsSection({
    super.key,
    required this.completedSessions,
    required this.selectedSessionIds,
    required this.textColor,
    required this.isDark,
    required this.readOnly,
    required this.onSessionToggled,
    required this.daDays,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Select Completed Sessions',
      sectionColor: isDark ? const Color(0xFF2A2A3D) : Colors.white,
      textColor: textColor,
      child: completedSessions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 40,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Please add a completed session first',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                ...completedSessions.map(
                  (s) => CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      '${DateFormat('dd/MM/yyyy').format(s.date)} — ${s.title.isNotEmpty ? s.title : 'Session'}',
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                    value: selectedSessionIds.contains(s.id),
                    onChanged: readOnly
                        ? null
                        : (v) => onSessionToggled(s.id, v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (selectedSessionIds.isNotEmpty && !readOnly)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${selectedSessionIds.length} session(s) selected — $daDays day(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
