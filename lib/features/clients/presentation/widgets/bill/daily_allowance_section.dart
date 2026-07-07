import 'package:flutter/material.dart';
import '/core/design_system/app_design_system.dart';
import 'section_card.dart';

class DailyAllowanceSection extends StatelessWidget {
  final int daDays;
  final Color textColor;
  final bool isDark;
  final bool includeMobile;
  final ValueChanged<bool> onMobileToggle;

  const DailyAllowanceSection({
    super.key,
    required this.daDays,
    required this.textColor,
    required this.isDark,
    required this.includeMobile,
    required this.onMobileToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Daily Allowance ($daDays days)',
      sectionColor: isDark ? const Color(0xFF2A2A3D) : Colors.white,
      textColor: textColor,
      child: Column(
        children: [
          DaRowWidget(
            label: 'Pocket Money',
            rate: 500,
            days: daDays,
            textColor: textColor,
          ),
          DaRowWidget(
            label: 'Lunch Allowance',
            rate: 200,
            days: daDays,
            textColor: textColor,
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Allowance',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '300 tk per day',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: includeMobile,
                onChanged: onMobileToggle,
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DaRowWidget extends StatelessWidget {
  final String label;
  final int rate;
  final int days;
  final Color textColor;

  const DaRowWidget({
    super.key,
    required this.label,
    required this.rate,
    required this.days,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor)),
          Text(
            '$rate\u00d7$days = ${rate * days}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
