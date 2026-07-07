import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/providers/client_detail_providers.dart';
import '../../data/assessment_session_repository.dart';
import '../../domain/assessment_models.dart';
import '../../domain/assessment_session.dart';
import '../../domain/scoring_engine.dart';
import '../assessment_notifier.dart';
import 'assessment_header.dart';
import 'instruction_banner.dart';
import 'question_card.dart';

class AssessmentBody extends ConsumerStatefulWidget {
  final AssessmentTest test;
  final String? clientId;
  final String? sessionId;
  final String? returnPath;
  final String clientAlias;

  const AssessmentBody({
    super.key,
    required this.test,
    this.clientId,
    this.sessionId,
    this.returnPath,
    this.clientAlias = '',
  });

  @override
  ConsumerState<AssessmentBody> createState() => _AssessmentBodyState();
}

class _AssessmentBodyState extends ConsumerState<AssessmentBody> {
  bool _isSaving = false;
  final _scrollController = ScrollController();
  late final Map<int, GlobalKey> _questionKeyMap;

  @override
  void initState() {
    super.initState();
    _questionKeyMap = {
      for (final q in widget.test.questions) q.id: GlobalKey(),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TestQuestion> _getVisibleQuestions(Map<int, int> responses) {
    return widget.test.questions.where((q) {
      if (q.showIf == null) return true;
      return responses[q.showIf!.questionId] == q.showIf!.value;
    }).toList();
  }

  void _scrollToNextUnanswered(
    List<TestQuestion> visibleQuestions,
    Map<int, int> responses,
  ) {
    final nextQ = visibleQuestions.firstWhere(
      (q) => !responses.containsKey(q.id),
      orElse: () => visibleQuestions.last,
    );
    final ctx = _questionKeyMap[nextQ.id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  Future<void> _handleFinish(
    Map<int, int> responses,
    List<TestQuestion> questions,
  ) async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final engine = ScoringEngineFactory.getEngine(widget.test.testId);
      final results = engine.calculate(responses, questions);

      final auth = ref.read(authProvider);
      final orgId = widget.clientId != null
          ? (ref.read(clientByIdProvider(widget.clientId!))?.organizationId ??
                '')
          : '';
      final assessmentSession = AssessmentSession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        organizationId: orgId,
        psychologistId: auth.uid ?? 'unknown',
        clientId: widget.clientId ?? '',
        clientAlias: widget.clientAlias,
        testId: widget.test.testId,
        createdAt: DateTime.now(),
        linkedSessionId: widget.sessionId,
        rawResponses: Map<int, int>.from(responses),
        scores: results,
      );

      if (widget.clientId != null) {
        await ref
            .read(assessmentSessionRepositoryProvider)
            .saveSession(assessmentSession);
      }

      if (!mounted) return;
      context.push(
        '/assessment/${widget.test.testId}/result',
        extra: {
          'session': assessmentSession,
          'testName': widget.test.testName,
          'returnPath': widget.returnPath,
        },
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(assessmentProvider);
    final notifier = ref.read(assessmentProvider.notifier);
    final visibleQuestions = _getVisibleQuestions(state.responses);
    final progress = notifier.getProgress(visibleQuestions.length);
    final isComplete = notifier.isComplete(visibleQuestions.length);

    return SafeArea(
      child: Center(
        child: MaxWidthContainer(
          child: Column(
            children: [
              AssessmentHeader(
                testName: widget.test.testName,
                answeredCount: (progress * visibleQuestions.length).round(),
                totalCount: visibleQuestions.length,
                isDark: isDark,
                isSaving: _isSaving,
                onFinish: isComplete && !_isSaving
                    ? () =>
                          _handleFinish(state.responses, widget.test.questions)
                    : null,
                onClose: () {
                  if (widget.clientId != null) {
                    context.go('/clients/${widget.clientId}/assessments');
                  } else {
                    context.go('/dashboard');
                  }
                },
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                color: AppColors.primary,
                minHeight: 3,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount:
                      visibleQuestions.length +
                      (widget.test.instruction != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (widget.test.instruction != null && index == 0) {
                      return InstructionBanner(
                        instruction: widget.test.instruction!,
                        isDark: isDark,
                      );
                    }
                    final qIndex = widget.test.instruction != null
                        ? index - 1
                        : index;
                    final question = visibleQuestions[qIndex];
                    final selected = state.responses[question.id];
                    final displayNumber =
                        widget.test.questions.indexWhere(
                          (q) => q.id == question.id,
                        ) +
                        1;
                    return QuestionCard(
                      key: _questionKeyMap[question.id],
                      question: question,
                      options: widget.test.options,
                      selectedValue: selected,
                      questionNumber: displayNumber,
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setResponse(question.id, val);
                          for (final q in widget.test.questions) {
                            if (q.showIf?.questionId == question.id &&
                                q.showIf?.value != val) {
                              notifier.clearResponse(q.id);
                            }
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            final updatedResponses = ref
                                .read(assessmentProvider)
                                .responses;
                            final updatedVisible = _getVisibleQuestions(
                              updatedResponses,
                            );
                            _scrollToNextUnanswered(
                              updatedVisible,
                              updatedResponses,
                            );
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
