import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../domain/session.dart';
import '../../../../assessment_engine/data/assessment_session_repository.dart';
import '../../../../assessment_engine/domain/assessment_session.dart';
import '../../../../assessment_engine/presentation/assessment_results_screen.dart';
import '../../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import '/core/widgets/card_action_button.dart';
import '../../providers/client_detail_providers.dart';
import 'assessment_helpers.dart';

class AssessmentsTab extends ConsumerWidget {
  final String clientId;
  final String clientAlias;

  const AssessmentsTab({
    super.key,
    required this.clientId,
    required this.clientAlias,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(
      clientAssessmentSessionsProvider(clientId),
    );
    final sessionsAsync = ref.watch(clientSessionsProvider(clientId));

    return assessmentsAsync.when(
      data: (assessments) {
        final sorted = List<AssessmentSession>.from(assessments)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final sessions = sessionsAsync.value ?? <Session>[];
        final sessionMap = <String, Session>{for (final s in sessions) s.id: s};
        if (sorted.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No past assessments yet.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final assessment = sorted[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () {
                  context.push(
                    '/assessment/${assessment.testId}/result',
                    extra: {
                      'session': assessment,
                      'testName': getTestDisplayName(assessment.testId),
                    },
                  );
                },
                borderRadius: AppRadius.roundedMd,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    boxShadow: const [
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat.yMMMd().format(assessment.createdAt),
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SessionLink(
                                      linkedSessionId: assessment.linkedSessionId,
                                      sessionMap: sessionMap,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getTestDisplayName(assessment.testId),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: ScoreSummary(scores: assessment.scores),
                          ),
                          CardActionButton(
                            icon: Icons.edit,
                            onTap: () async {
                              final sessions = await ref
                                  .read(sessionRepositoryProvider)
                                  .watchSessionsByClientId(clientId)
                                  .first;
                              if (!context.mounted) return;
                              final result = await showDialog<(String?, DateTime)>(
                                context: context,
                                builder: (ctx) => SessionPickerDialog(
                                  sessions: sessions,
                                  currentSessionId: assessment.linkedSessionId,
                                  currentDate: assessment.createdAt,
                                ),
                              );
                              if (result != null && context.mounted) {
                                final (selectedId, selectedDate) = result;
                                final updated = AssessmentSession(
                                  sessionId: assessment.sessionId,
                                  organizationId: assessment.organizationId,
                                  psychologistId: assessment.psychologistId,
                                  clientId: assessment.clientId,
                                  clientAlias: assessment.clientAlias,
                                  testId: assessment.testId,
                                  createdAt: selectedDate,
                                  rawResponses: assessment.rawResponses,
                                  scores: assessment.scores,
                                  linkedSessionId: selectedId == null || selectedId.isEmpty ? null : selectedId,
                                );
                                await ref
                                    .read(assessmentSessionRepositoryProvider)
                                    .saveSession(updated);
                                ref.invalidate(clientAssessmentSessionsProvider(clientId));
                              }
                            },
                          ),
                          const SizedBox(width: 2),
                          CardActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.red,
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  final dk = Theme.of(ctx).brightness == Brightness.dark;
                                  return AlertDialog(
                                    backgroundColor: dk ? AppColors.surfaceDark : null,
                                    title: Text('Delete Assessment',
                                      style: TextStyle(color: dk ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                    content: Text('Are you sure?',
                                      style: TextStyle(color: dk ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmed == true && context.mounted) {
                                await ref
                                    .read(assessmentSessionRepositoryProvider)
                                    .deleteSession(assessment.sessionId);
                                ref.invalidate(clientAssessmentSessionsProvider(clientId));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
