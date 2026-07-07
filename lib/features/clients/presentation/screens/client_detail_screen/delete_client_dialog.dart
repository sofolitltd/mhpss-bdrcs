import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';

class DeleteClientDialog extends StatelessWidget {
  final Client client;

  const DeleteClientDialog({super.key, required this.client});

  static Future<bool?> show(BuildContext context, Client client) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteClientDialog(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : null,
      title: Text(
        'Delete Client',
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${client.caseId}"?\n\nThis will also delete all sessions and assessments for this client. This action cannot be undone.',
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
