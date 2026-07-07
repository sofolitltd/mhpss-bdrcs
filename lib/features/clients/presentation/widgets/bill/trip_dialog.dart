import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ta_models.dart';

class TripDialog {
  static Future<bool?> show(BuildContext context, TaGroupData group) async {
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    final modeCtrl = TextEditingController();
    final fareCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Text('Add Trip'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fromCtrl,
                decoration: const InputDecoration(
                  labelText: 'From',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: toCtrl,
                decoration: const InputDecoration(
                  labelText: 'To',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return [];
                        return [
                          'Bus',
                          'Train',
                          'Rickshaw',
                          'Auto',
                          'CNG',
                          'Launch',
                          'Bike',
                          'Walk',
                          'Van',
                          'Taxi',
                          'Uber',
                          'Plane',
                          'Boat',
                          'Other',
                        ].where(
                          (option) => option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        );
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Mode',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => onSubmitted(),
                            );
                          },
                      onSelected: (value) {
                        modeCtrl.text = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fareCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fare',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksCtrl,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      group.legs.add(
        TaLegData(
          fromCtrl.text,
          toCtrl.text,
          modeCtrl.text,
          int.tryParse(fareCtrl.text) ?? 0,
          remarksCtrl.text,
        ),
      );
    }

    fromCtrl.dispose();
    toCtrl.dispose();
    modeCtrl.dispose();
    fareCtrl.dispose();
    remarksCtrl.dispose();

    return result;
  }
}
