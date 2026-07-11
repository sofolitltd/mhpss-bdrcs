import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import 'ta_models.dart';
import 'ta_date_group_card.dart';
import 'section_card.dart';

class TaSection extends StatefulWidget {
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
  State<TaSection> createState() => _TaSectionState();
}

class _TaSectionState extends State<TaSection> {
  bool _isTableView = true;

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.taGroups.isNotEmpty;
    return SectionCard(
      title: 'Traveling Allowance',
      sectionColor: widget.isDark ? const Color(0xFF2A2A3D) : Colors.white,
      textColor: widget.textColor,
      titleTrailing: IconButton(
        icon: Icon(
          _isTableView
              ? Icons.grid_view_rounded
              : Icons.table_rows_rounded,
          size: 20,
        ),
        tooltip: _isTableView
            ? 'Switch to Card View'
            : 'Switch to Table View',
        onPressed: () =>
            setState(() => _isTableView = !_isTableView),
        visualDensity: VisualDensity.compact,
      ),
      child: hasSelection
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.taGroups.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final group = entry.value;
                  return TaDateGroupCard(
                    index: idx,
                    group: group,
                    textColor: widget.textColor,
                    onChanged: widget.onChanged,
                    isTableView: _isTableView,
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
                      onPressed: widget.onAddTrip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Sub-Total: ${widget.totalTA}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
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
                    color: widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
    );
  }
}
