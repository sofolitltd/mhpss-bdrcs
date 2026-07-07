import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../assessment_engine/presentation/assessment_notifier.dart';
import '../../providers/client_detail_providers.dart';

class SelectSessionDialog extends ConsumerStatefulWidget {
  final String clientId;
  final String testId;
  final String testName;
  final String? returnPath;
  final String clientAlias;

  const SelectSessionDialog({
    super.key,
    required this.clientId,
    required this.testId,
    required this.testName,
    this.returnPath,
    this.clientAlias = '',
  });

  @override
  ConsumerState<SelectSessionDialog> createState() =>
      SelectSessionDialogState();
}

class SelectSessionDialogState extends ConsumerState<SelectSessionDialog> {
  String? _selectedSessionId;
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(clientSessionsProvider(widget.clientId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Start ${widget.testName}',
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.titleMedium?.fontSize,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Assessment Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadius.roundedSm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: border),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                            style: TextStyle(fontSize: 14, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Link to Session:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  sessionsAsync.when(
                    data: (sessions) {
                      return ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedSessionId,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.surfaceDark
                              : Colors.white,
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: textSecondary,
                          ),
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Unlinked',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ...sessions.map((s) {
                              final label = s.title.isNotEmpty
                                  ? '${s.title} — ${DateFormat.yMMMd().format(s.date)}'
                                  : DateFormat.yMMMd().format(s.date);
                              return DropdownMenuItem<String?>(
                                value: s.id,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedSessionId = val);
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        onPressed: () {
                          ref.read(assessmentProvider.notifier).reset();

                          final testId = widget.testId;
                          final extra = {
                            'clientId': widget.clientId,
                            'sessionId': _selectedSessionId,
                            'clientAlias': widget.clientAlias,
                            'assessmentDate': _selectedDate.toIso8601String(),
                            'returnPath': widget.returnPath,
                          };

                          Navigator.pop(context);

                          context.go('/assessment/$testId', extra: extra);
                        },
                        child: const Text('Proceed'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
