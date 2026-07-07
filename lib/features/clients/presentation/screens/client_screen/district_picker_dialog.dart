import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';

const List<String> bangladeshDistricts = [
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
  'Cox\'s Bazar',
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

class DistrictPickerDialog extends StatefulWidget {
  final String currentDistrict;
  final ValueChanged<String> onDistrictSelected;

  const DistrictPickerDialog({
    super.key,
    required this.currentDistrict,
    required this.onDistrictSelected,
  });

  @override
  State<DistrictPickerDialog> createState() => _DistrictPickerDialogState();
}

class _DistrictPickerDialogState extends State<DistrictPickerDialog> {
  late final TextEditingController _searchCtrl;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search district...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.background,
                border: const OutlineInputBorder(
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
                children: bangladeshDistricts
                    .where(
                      (d) =>
                          _filter.isEmpty || d.toLowerCase().contains(_filter),
                    )
                    .map(
                      (d) => ListTile(
                        dense: true,
                        title: Text(
                          d,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: widget.currentDistrict == d
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          widget.onDistrictSelected(d);
                          Navigator.pop(context);
                        },
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
