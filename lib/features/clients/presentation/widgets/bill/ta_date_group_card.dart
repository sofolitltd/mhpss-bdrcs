import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/core/design_system/app_design_system.dart';
import 'ta_models.dart';

class TaDateGroupCard extends StatelessWidget {
  final int index;
  final TaGroupData group;
  final Color textColor;
  final VoidCallback onChanged;

  const TaDateGroupCard({
    super.key,
    required this.index,
    required this.group,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                dateFmt.format(group.date),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (group.legs.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth;
                final actualWidth = tableWidth < 840 ? 840.0 : tableWidth;
                final flexSpace = actualWidth - 66;
                double colFrom, colTo, colMode, colFare, colRemarks, colActions;
                colFrom = flexSpace * 13 / 80;
                colTo = flexSpace * 13 / 80;
                colMode = flexSpace * 11 / 80;
                colFare = flexSpace * 11 / 80;
                colRemarks = flexSpace * 20 / 80;
                colActions = flexSpace - colFrom - colTo - colMode - colFare - colRemarks;
                return ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: actualWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Text('', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(width: colFrom, child: Text('From', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                      SizedBox(width: colTo, child: Text('To', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                      SizedBox(width: colMode, child: Text('Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                      SizedBox(width: colFare, child: Text('Fare', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                      SizedBox(width: colRemarks, child: Text('Remarks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                      SizedBox(width: colActions, child: Text('', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor))),
                                    ],
                                  ),
                                ),
                                for (int lIdx = 0; lIdx < group.legs.length; lIdx++)
                                  _buildLegRow(context, group.legs[lIdx], lIdx, textColor, borderColor,
                                    colFrom: colFrom, colTo: colTo, colMode: colMode, colFare: colFare, colRemarks: colRemarks, colActions: colActions),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    border: Border(bottom: BorderSide(color: borderColor)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 32),
                                      const SizedBox(width: 8),
                                      SizedBox(width: colFrom),
                                      SizedBox(width: colTo),
                                      SizedBox(width: colMode),
                                      SizedBox(width: colFare, child: Text('${group.subTotal}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13))),
                                      SizedBox(width: colRemarks, child: Text('Subtotal', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 12))),
                                      SizedBox(width: colActions),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Click "Add Trip" to add a TA entry for this date',
                  style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegRow(
    BuildContext context,
    TaLegData leg,
    int index,
    Color textColor,
    Color borderColor, {
    required double colFrom,
    required double colTo,
    required double colMode,
    required double colFare,
    required double colRemarks,
    required double colActions,
  }) {
    return Container(
      key: ObjectKey(leg),
      decoration: BoxDecoration(
        color: index.isOdd ? AppColors.primary.withValues(alpha: 0.04) : null,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                  onPressed: index > 0
                      ? () {
                          final item = group.legs.removeAt(index);
                          group.legs.insert(index - 1, item);
                          onChanged();
                        }
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: index > 0 ? null : borderColor,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  onPressed: index < group.legs.length - 1
                      ? () {
                          final item = group.legs.removeAt(index);
                          group.legs.insert(index + 1, item);
                          onChanged();
                        }
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: index < group.legs.length - 1 ? null : borderColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: colFrom, child: Text(leg.from, style: const TextStyle(fontSize: 13))),
          SizedBox(width: colTo, child: Text(leg.to, style: const TextStyle(fontSize: 13))),
          SizedBox(width: colMode, child: Text(leg.mode, style: const TextStyle(fontSize: 13))),
          SizedBox(width: colFare, child: Text(leg.fare == 0 ? '' : leg.fare.toString(), style: const TextStyle(fontSize: 13))),
          SizedBox(width: colRemarks, child: Text(leg.remarks, style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: colActions,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 16),
                  tooltip: 'Duplicate',
                  onPressed: () => _showLegDialog(context, leg: leg),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => _showLegDialog(context, leg: leg, index: index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    group.legs.removeAt(index);
                    onChanged();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLegDialog(
    BuildContext context, {
    TaLegData? leg,
    int? index,
  }) async {
    final isEdit = leg != null;
    final fromCtrl = TextEditingController(text: leg?.from ?? '');
    final toCtrl = TextEditingController(text: leg?.to ?? '');
    final modeCtrl = TextEditingController(text: leg?.mode ?? '');
    final fareCtrl = TextEditingController(text: leg?.fare == 0 ? '' : leg?.fare.toString() ?? '');
    final remarksCtrl = TextEditingController(text: leg?.remarks ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(isEdit ? 'Edit Trip' : 'Add Trip'),
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
                decoration: const InputDecoration(labelText: 'From', isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: toCtrl,
                decoration: const InputDecoration(labelText: 'To', isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return [];
                        return ['Bus','Train','Rickshaw','Auto','CNG','Launch','Bike','Walk','Van','Taxi','Uber','Plane','Boat','Other']
                            .where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        controller.text = leg?.mode ?? '';
                        controller.addListener(() { modeCtrl.text = controller.text; });
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(labelText: 'Mode', isDense: true, border: OutlineInputBorder()),
                          onSubmitted: (_) => onSubmitted(),
                        );
                      },
                      onSelected: (value) { modeCtrl.text = value; },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fareCtrl,
                      decoration: const InputDecoration(labelText: 'Fare', isDense: true, border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks', isDense: true, border: OutlineInputBorder()),
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
            child: Text(isEdit ? (index != null ? 'Save' : 'Add') : 'Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final data = TaLegData(fromCtrl.text, toCtrl.text, modeCtrl.text, int.tryParse(fareCtrl.text) ?? 0, remarksCtrl.text);
      if (isEdit && index != null) {
        group.legs[index] = data;
      } else {
        group.legs.add(data);
      }
      onChanged();
    }

    fromCtrl.dispose();
    toCtrl.dispose();
    modeCtrl.dispose();
    fareCtrl.dispose();
    remarksCtrl.dispose();
  }
}
