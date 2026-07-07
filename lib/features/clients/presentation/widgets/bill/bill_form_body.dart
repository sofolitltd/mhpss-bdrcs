import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/session.dart';
import 'ta_models.dart';
import 'completed_sessions_section.dart';
import 'ta_section.dart';
import 'daily_allowance_section.dart';
import 'bill_summary_widgets.dart';

class BillFormBody extends StatelessWidget {
  final List<Session> completedSessions;
  final Set<String> selectedSessionIds;
  final Color textColor;
  final bool isDark;
  final bool readOnly;
  final void Function(String sessionId, bool selected) onSessionToggled;
  final int daDays;
  final List<TaGroupData> taGroups;
  final int totalTA;
  final VoidCallback? onAddTrip;
  final VoidCallback onTaChanged;
  final bool includeMobile;
  final ValueChanged<bool> onMobileToggle;
  final int totalDA;
  final int grandTotal;
  final bool isSaving;
  final VoidCallback onExportPdf;
  final VoidCallback onSaveBill;

  const BillFormBody({
    super.key,
    required this.completedSessions,
    required this.selectedSessionIds,
    required this.textColor,
    required this.isDark,
    required this.readOnly,
    required this.onSessionToggled,
    required this.daDays,
    required this.taGroups,
    required this.totalTA,
    this.onAddTrip,
    required this.onTaChanged,
    required this.includeMobile,
    required this.onMobileToggle,
    required this.totalDA,
    required this.grandTotal,
    required this.isSaving,
    required this.onExportPdf,
    required this.onSaveBill,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        CompletedSessionsSection(
          completedSessions: completedSessions,
          selectedSessionIds: selectedSessionIds,
          textColor: textColor,
          isDark: isDark,
          readOnly: readOnly,
          onSessionToggled: onSessionToggled,
          daDays: daDays,
        ),
        const SizedBox(height: AppSpacing.md),
        TaSection(
          taGroups: taGroups,
          textColor: textColor,
          isDark: isDark,
          totalTA: totalTA,
          onAddTrip: onAddTrip,
          onChanged: onTaChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        DailyAllowanceSection(
          daDays: daDays,
          textColor: textColor,
          isDark: isDark,
          includeMobile: includeMobile,
          onMobileToggle: onMobileToggle,
        ),
        const SizedBox(height: AppSpacing.md),
        TotalsCard(
          totalTA: totalTA,
          totalDA: totalDA,
          grandTotal: grandTotal,
          textColor: textColor,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Preview PDF'),
                onPressed: onExportPdf,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Saving...' : 'Save Bill'),
                onPressed: isSaving ? null : onSaveBill,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
