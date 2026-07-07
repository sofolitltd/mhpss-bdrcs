import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_design_system.dart';
import '../../../clients/domain/session.dart';

class SessionPickerDialog extends StatefulWidget {
  final List<Session> sessions;
  final String? currentSessionId;
  final DateTime currentDate;

  const SessionPickerDialog({
    required this.sessions,
    this.currentSessionId,
    required this.currentDate,
  });

  @override
  State<SessionPickerDialog> createState() => SessionPickerDialogState();
}

class SessionPickerDialogState extends State<SessionPickerDialog> {
  String? _selected;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSessionId;
    _selectedDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.link_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Link to Session',
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
                    'Date',
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
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonFormField<String?>(
                      value: _selected,
                      isExpanded: true,
                      dropdownColor: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: textSecondary,
                      ),
                      style: TextStyle(color: textPrimary, fontSize: 14),
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
                            style: TextStyle(color: textPrimary, fontSize: 14),
                          ),
                        ),
                        ...widget.sessions.map((s) {
                          final label = s.title.isNotEmpty
                              ? s.title
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
                      onChanged: (val) => setState(() => _selected = val),
                    ),
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
                        onPressed: () =>
                            Navigator.pop(context, (_selected, _selectedDate)),
                        child: const Text('Save'),
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }
}
