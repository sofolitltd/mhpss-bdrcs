import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class DistrictPickerDialog extends StatefulWidget {
  final String currentDistrict;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const DistrictPickerDialog({
    super.key,
    required this.currentDistrict,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  static Future<String?> show({
    required BuildContext context,
    required String currentDistrict,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => DistrictPickerDialog(
        currentDistrict: currentDistrict,
        surface: surface,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        isDark: isDark,
      ),
    );
  }

  @override
  State<DistrictPickerDialog> createState() => _DistrictPickerDialogState();
}

class _DistrictPickerDialogState extends State<DistrictPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  static const _districts = [
    'Bagerhat',
    'Bandarban',
    'Barguna',
    'Barisal',
    'Bhola',
    'Bogra',
    'Brahmanbaria',
    'Chandpur',
    'Chittagong',
    'Chuadanga',
    'Comilla',
    "Cox's Bazar",
    'Dhaka',
    'Dinajpur',
    'Faridpur',
    'Feni',
    'Gaibandha',
    'Gazipur',
    'Gopalganj',
    'Habiganj',
    'Jamalpur',
    'Jessore',
    'Jhalokati',
    'Jhenaidah',
    'Joypurhat',
    'Khagrachhari',
    'Khulna',
    'Kishoreganj',
    'Kurigram',
    'Kushtia',
    'Lakshmipur',
    'Lalmonirhat',
    'Madaripur',
    'Magura',
    'Manikganj',
    'Maulvibazar',
    'Meherpur',
    'Munshiganj',
    'Mymensingh',
    'Naogaon',
    'Narail',
    'Narayanganj',
    'Narsingdi',
    'Natore',
    'Nawabganj',
    'Netrokona',
    'Nilphamari',
    'Noakhali',
    'Pabna',
    'Panchagarh',
    'Patuakhali',
    'Pirojpur',
    'Rajbari',
    'Rajshahi',
    'Rangamati',
    'Rangpur',
    'Satkhira',
    'Shariatpur',
    'Sherpur',
    'Sirajganj',
    'Sunamganj',
    'Sylhet',
    'Tangail',
    'Thakurgaon',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
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
                const Icon(Icons.map_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Select District',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: widget.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: TextStyle(color: widget.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search district...',
                hintStyle: TextStyle(color: widget.textSecondary),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: widget.textSecondary,
                ),
                filled: true,
                fillColor: widget.isDark
                    ? AppColors.backgroundDark
                    : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _filter = v.toLowerCase()),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                shrinkWrap: true,
                children: _districts
                    .where(
                      (d) =>
                          _filter.isEmpty || d.toLowerCase().contains(_filter),
                    )
                    .map(
                      (d) => ListTile(
                        dense: true,
                        title: Text(
                          d,
                          style: TextStyle(color: widget.textPrimary),
                        ),
                        trailing: widget.currentDistrict == d
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, d),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
