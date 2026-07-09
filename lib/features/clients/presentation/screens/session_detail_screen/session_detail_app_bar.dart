import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';

class SessionDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String fontFamily;
  final Color textPrimary;
  final Color backgroundColor;
  final String title;
  final bool hasChanges;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onCreateBill;
  final VoidCallback? onSave;

  const SessionDetailAppBar({
    super.key,
    required this.fontFamily,
    required this.textPrimary,
    required this.backgroundColor,
    required this.title,
    required this.hasChanges,
    required this.isSaving,
    required this.onBack,
    required this.onCreateBill,
    this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      elevation: 0,
      title: MaxWidthContainer(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: onBack,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title.isNotEmpty ? title : 'Session Details',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),

            
            //
            IconButton(
              icon: Icon(Icons.receipt_rounded, color: textPrimary),
              tooltip: 'Create Bill',
              onPressed: onCreateBill,
            ),
            if (hasChanges)
              ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedSm,
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }
}
