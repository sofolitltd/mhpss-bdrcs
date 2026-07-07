import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/app_design_system.dart';
import '../data/assessment_repository.dart';
import '../domain/assessment_models.dart';
import 'assessment_notifier.dart';
import 'assessment_runner_screen/assessment_body.dart';

class AssessmentRunnerScreen extends ConsumerStatefulWidget {
  final String testId;
  final String? clientId;
  final String? sessionId;
  final String? returnPath;
  final String clientAlias;

  const AssessmentRunnerScreen({
    super.key,
    required this.testId,
    this.clientId,
    this.sessionId,
    this.returnPath,
    this.clientAlias = '',
  });

  @override
  ConsumerState<AssessmentRunnerScreen> createState() =>
      _AssessmentRunnerScreenState();
}

class _AssessmentRunnerScreenState
    extends ConsumerState<AssessmentRunnerScreen> {
  late final Future<AssessmentTest> _testFuture;

  @override
  void initState() {
    super.initState();
    _testFuture = ref
        .read(assessmentRepositoryProvider)
        .loadTest(widget.testId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(assessmentProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: FutureBuilder<AssessmentTest>(
        future: _testFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading test:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Test not found'));
          }

          final test = snapshot.data!;
          return AssessmentBody(
            test: test,
            clientId: widget.clientId,
            sessionId: widget.sessionId,
            returnPath: widget.returnPath,
            clientAlias: widget.clientAlias,
          );
        },
      ),
    );
  }
}
