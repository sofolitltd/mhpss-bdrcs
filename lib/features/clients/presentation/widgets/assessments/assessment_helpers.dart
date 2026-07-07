import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import '../../../domain/session.dart';
import '../../../../assessment_engine/domain/scoring_engine.dart';

class SessionLink extends StatelessWidget {
  final String? linkedSessionId;
  final Map<String, Session> sessionMap;
  final bool isDark;

  const SessionLink({
    super.key,
    required this.linkedSessionId,
    required this.sessionMap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final session = linkedSessionId != null ? sessionMap[linkedSessionId] : null;
    final hasSession = session != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasSession
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? Colors.grey.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        hasSession ? session.title : 'Unlinked',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: hasSession ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class ScoreSummary extends StatelessWidget {
  final Map<String, ScoreResult> scores;

  const ScoreSummary({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final entries = scores.entries.toList();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: entries.map((e) {
        final score = e.value;
        final color = severityColor(score.severity);

        final label = score.scale == 'general'
            ? ''
            : score.scale == 'suicide_risk'
                ? 'Sui '
                : '${score.scale.substring(0, 3).toUpperCase()} ';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$label${score.rawScore}/${score.maxScore}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
