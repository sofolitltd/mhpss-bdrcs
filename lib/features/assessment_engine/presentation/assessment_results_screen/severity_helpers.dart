import 'package:flutter/material.dart';

import '../../domain/scoring_engine.dart';

Color severityColor(String severity) {
  switch (severity.toLowerCase()) {
    case 'normal':
    case 'no risk indicated':
      return Colors.green;
    case 'mild':
    case 'low risk':
      return Colors.amber;
    case 'moderate':
    case 'probable mental distress':
    case 'moderate risk':
      return Colors.orange;
    case 'severe':
      return Colors.red;
    case 'extremely severe':
    case 'high risk':
      return const Color(0xFFB71C1C);
    default:
      return AppColors.textSecondary;
  }
}

Color severityColorFromThreshold(SeverityThreshold t, String currentSeverity) {
  if (t.label == currentSeverity) {
    return severityColor(t.label);
  }
  return severityColor(t.label).withValues(alpha: 0.35);
}
