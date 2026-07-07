import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/app_design_system.dart';
import '../domain/assessment_session.dart';

import 'assessment_results_screen/assessment_scale_card.dart';

export 'assessment_results_screen/test_display_name.dart';
export 'assessment_results_screen/session_picker_dialog.dart';

class AssessmentResultsScreen extends ConsumerStatefulWidget {
  final AssessmentSession session;
  final String testName;
  final String? returnPath;

  const AssessmentResultsScreen({
    super.key,
    required this.session,
    required this.testName,
    this.returnPath,
  });

  @override
  ConsumerState<AssessmentResultsScreen> createState() =>
      _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState
    extends ConsumerState<AssessmentResultsScreen> {
  late AssessmentSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  Widget build(BuildContext context) {
    final scores = _session.scores.values.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = GoogleFonts.outfit().fontFamily;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.testName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Completed ${DateFormat.yMMMd().format(_session.createdAt)}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Assessment Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...scores.map(
                      (result) => AssessmentScaleCard(
                        result: result,
                        testId: _session.testId,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                    onPressed: () => context.go(
                      widget.returnPath ?? '/clients/${_session.clientId}',
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
