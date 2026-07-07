import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';

import 'assessment_list_screen/available_tests.dart';
import 'assessment_list_screen/select_session_dialog.dart';

class AssessmentListScreen extends StatelessWidget {
  final String clientId;

  const AssessmentListScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final _isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = _isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = _isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = _isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = _isDark ? AppColors.borderDark : AppColors.border;

    final routerState = GoRouterState.of(context);
    final queryParams = routerState.uri.queryParameters;
    final clientAlias = queryParams['clientAlias'] ?? '';
    final from = queryParams['from'];
    final sessionId = queryParams['sessionId'];

    String? returnPath;
    if (from == 'session') {
      returnPath = '/clients/$clientId/sessions/$sessionId';
    } else {
      returnPath = '/clients/$clientId/assessments';
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                      onPressed: () {
                        context.go(
                          returnPath ?? '/clients/$clientId/assessments',
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'New Assessment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Text(
                      clientAlias.isNotEmpty
                          ? 'Select an assessment for $clientAlias'
                          : 'Select an assessment',
                      style: TextStyle(fontSize: 16, color: textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...availableTests.map((test) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: AppRadius.roundedMd,
                          onTap: () => _showStartAssessmentDialog(
                            context,
                            test['id']!,
                            test['name']!,
                            returnPath,
                            clientAlias,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        test['description']!,
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.roundedSm,
                                      ),
                                    ),
                                    onPressed: () => _showStartAssessmentDialog(
                                      context,
                                      test['id']!,
                                      test['name']!,
                                      returnPath,
                                      clientAlias,
                                    ),
                                    child: const Text('Start'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartAssessmentDialog(
    BuildContext context,
    String testId,
    String testName,
    String? returnPath,
    String clientAlias,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SelectSessionDialog(
        clientId: clientId,
        testId: testId,
        testName: testName,
        returnPath: returnPath,
        clientAlias: clientAlias,
      ),
    );
  }
}
