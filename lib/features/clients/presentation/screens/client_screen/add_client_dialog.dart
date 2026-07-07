import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/design_system/app_design_system.dart';
import '../../providers/clients_provider.dart';
import 'dialog_text_field.dart';
import 'district_picker_dialog.dart';
import 'district_field.dart';
import 'add_client_dialog_fields.dart';

class AddClientDialog extends ConsumerStatefulWidget {
  const AddClientDialog({super.key});

  @override
  ConsumerState<AddClientDialog> createState() => AddClientDialogState();
}

class AddClientDialogState extends ConsumerState<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _caseIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _districtSearchController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _joinDate = DateTime.now();
  String _gender = 'Male';
  String _ageRange = '18-29';
  String _category = '';
  bool _isLoading = false;

  static const List<String> _ageRanges = [
    '0-5',
    '6-12',
    '13-17',
    '18-29',
    '30-39',
    '40-49',
    '50-59',
    '60-69',
    '70-89',
    '90-100+',
  ];

  @override
  void dispose() {
    _caseIdController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _districtSearchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                    _buildHeader(isDark),
                    const SizedBox(height: AppSpacing.lg),
                    DialogTextField(
                      controller: _caseIdController,
                      label: 'Case ID *',
                      hint: 'e.g. CAS-001',
                      prefixIcon: Icons.tag_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DialogTextField(
                      controller: _nameController,
                      label: 'Name *',
                      hint: 'e.g. John Doe',
                      prefixIcon: Icons.person_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    GenderAgeDropdownRow(
                      gender: _gender,
                      ageRange: _ageRange,
                      ageRanges: _ageRanges,
                      onGenderChanged: (v) => setState(() => _gender = v),
                      onAgeRangeChanged: (v) => setState(() => _ageRange = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DialogTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'e.g. 123 Main Street',
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DistrictField(
                      isDark: isDark,
                      districtText: _districtSearchController.text,
                      onTap: () => _showDistrictPicker(context, isDark),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DialogTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: 'e.g. +8801XXXXXXXXX',
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DialogTextField(
                      controller: _alternatePhoneController,
                      label: 'Alternate Phone',
                      hint: 'e.g. +8801XXXXXXXXX',
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Join Date *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DatePickerField(joinDate: _joinDate, onTap: _pickDate),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryChoiceChips(
                      category: _category,
                      onCategoryChanged: (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DialogTextField(
                      controller: _noteController,
                      label: 'Note / Injury Remark',
                      hint: 'e.g. injury details, special notes',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    DialogActionButtons(
                      isLoading: _isLoading,
                      onCancel: () => Navigator.pop(context),
                      onSave: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Add Client',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select join date',
    );
    if (picked != null) {
      setState(() => _joinDate = picked);
    }
  }

  void _showDistrictPicker(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => DistrictPickerDialog(
        currentDistrict: _districtSearchController.text,
        onDistrictSelected: (d) {
          setState(() => _districtSearchController.text = d);
        },
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(clientsProvider.notifier)
          .addClient(
            caseId: _caseIdController.text.trim(),
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            district: _districtSearchController.text.trim(),
            gender: _gender,
            ageRange: _ageRange,
            category: _category,
            note: _noteController.text.trim(),
            joinDate: _joinDate,
            phone: _phoneController.text.trim(),
            alternatePhone: _alternatePhoneController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
