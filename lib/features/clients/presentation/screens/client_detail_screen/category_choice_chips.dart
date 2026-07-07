import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';

class CategoryChoiceChips extends StatelessWidget {
  final String category;
  final ValueChanged<String> onChanged;

  const CategoryChoiceChips({
    super.key,
    required this.category,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Client.categories.map((cat) {
        final selected = category == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => onChanged(cat),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: selected ? Colors.white : null),
          ),
        );
      }).toList(),
    );
  }
}
