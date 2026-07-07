import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import 'ta_models.dart';
import 'ta_date_group_card.dart';
import 'section_card.dart';

class TaSection extends StatelessWidget {
  final List<TaGroupData> taGroups;
  final Color textColor;
  final bool isDark;
  final int totalTA;
  final VoidCallback? onAddTrip;
  final VoidCallback onChanged;

  const TaSection({
    super.key,
    required this.taGroups,
    required this.textColor,
    required this.isDark,
    required this.totalTA,
    this.onAddTrip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = taGroups.isNotEmpty;
    return SectionCard(
      title: 'Traveling Allowance',
      sectionColor: isDark ? const Color(0xFF2A2A3D) : Colors.white,
      textColor: textColor,
      child: hasSelection
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...taGroups.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final group = entry.value;
                  return TaDateGroupCard(
                    index: idx,
                    group: group,
                    textColor: textColor,
                    onChanged: onChanged,
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Trip',
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: onAddTrip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Sub-Total: $totalTA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Please select sessions to add TA',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
    );
  }
}
