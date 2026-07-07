import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

class OrganizationSearchField extends ConsumerWidget {
  final bool isDark;
  final TextEditingController orgNameController;
  final TextEditingController employeeIdController;
  final String? selectedOrgId;
  final void Function(String name, String id, String? code)
  onOrganizationSelected;

  const OrganizationSearchField({
    super.key,
    required this.isDark,
    required this.orgNameController,
    required this.employeeIdController,
    required this.selectedOrgId,
    required this.onOrganizationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return organizationsAsync.when(
      data: (orgs) => SearchAnchor(
        builder: (context, controller) {
          return TextFormField(
            controller: orgNameController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select organization',
              prefixIcon: Icon(
                Icons.business_outlined,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.background,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onTap: () => controller.openView(),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Please select an organization';
              if (selectedOrgId == null) return 'Invalid selection';
              return null;
            },
          );
        },
        suggestionsBuilder: (context, controller) {
          final keyword = controller.text.toLowerCase();
          final filteredOrgs = orgs
              .where((org) => org.name.toLowerCase().contains(keyword))
              .toList();

          if (filteredOrgs.isEmpty) {
            return [
              ListTile(
                title: Text(
                  'No organization found',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ];
          }

          return filteredOrgs.map(
            (org) => ListTile(
              title: Text(org.name),
              onTap: () {
                onOrganizationSelected(org.name, org.id, org.code);
                controller.closeView(org.name);
              },
            ),
          );
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (err, _) => Text(
        'Error loading organizations',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
