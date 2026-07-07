import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import 'register_screen/custom_text_field.dart';
import 'register_screen/info_banner.dart';
import 'register_screen/organization_search_field.dart';
import 'register_screen/register_header.dart';
import 'register_screen/sign_in_link.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _designationController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIdFocusNode = FocusNode();
  final _designationFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _selectedOrgId;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _employeeIdController.dispose();
    _designationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _employeeIdFocusNode.dispose();
    _designationFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: MaxWidthContainer(
            maxWidth: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RegisterHeader(isDark: isDark),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: AppRadius.roundedLg,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Organization Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: rfs(context, 14),
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OrganizationSearchField(
                          isDark: isDark,
                          orgNameController: _orgNameController,
                          employeeIdController: _employeeIdController,
                          selectedOrgId: _selectedOrgId,
                          onOrganizationSelected: (name, id, code) {
                            setState(() {
                              _orgNameController.text = name;
                              _selectedOrgId = id;
                              if (code != null) {
                                _employeeIdController.text = code;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _employeeIdController,
                          focusNode: _employeeIdFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Employee ID',
                          hint: 'Enter employee ID',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter employee ID' : null,
                          onFieldSubmitted: () =>
                              _designationFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _designationController,
                          focusNode: _designationFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Designation',
                          hint: 'e.g. Psychologist, Counselor',
                          prefixIcon: Icons.work_outline,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter designation' : null,
                          onFieldSubmitted: () => _nameFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Your Name',
                          hint: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter your name' : null,
                          onFieldSubmitted: () =>
                              _phoneFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Phone Number',
                          hint: 'Enter phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Enter phone number' : null,
                          onFieldSubmitted: () =>
                              _emailFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const InfoBanner(),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          label: 'Email Address',
                          hint: 'name@clinic.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Enter email';
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v!)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          onFieldSubmitted: () =>
                              _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          isDark: isDark,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          label: 'Password',
                          hint: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Enter password';
                            if (v!.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    ref
                                        .read(authProvider.notifier)
                                        .register(
                                          organizationId: _selectedOrgId!,
                                          employeeId:
                                              _employeeIdController.text,
                                          designation:
                                              _designationController.text,
                                          name: _nameController.text,
                                          phone: _phoneController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                  }
                                },
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SignInLink(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
