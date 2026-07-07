import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '/core/design_system/app_design_system.dart';
import '/core/services/bill_pdf_generator.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/session.dart';
import '../../../data/bill_repository.dart';
import 'ta_date_group_card.dart';
import 'ta_models.dart';
import 'section_card.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final String clientId;
  final List<Session> allSessions;
  final Bill? existingBill;
  final Set<String>? preselectedSessionIds;

  const BillFormScreen({
    super.key,
    required this.clientId,
    required this.allSessions,
    this.existingBill,
    this.preselectedSessionIds,
  });

  @override
  ConsumerState<BillFormScreen> createState() => BillFormScreenState();
}

class BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _fromDate;
  late DateTime _toDate;
  late List<TaGroupData> _taGroups;
  int _daDays = 0;
  bool _saving = false;
  Set<String> _selectedSessionIds = {};

  List<Session> get _completedSessions =>
      widget.allSessions.where((s) => s.status == 'completed').toList();

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;

    if (b != null) {
      _fromDate = b.fromDate;
      _toDate = b.toDate;
      _taGroups = b.taGroups
          .map((g) => TaGroupData(
                g.date,
                g.legs.map((l) => TaLegData(l.from, l.to, l.mode, l.fare, l.remarks)).toList(),
                g.includeMobile,
              ))
          .toList();
      _daDays = b.daRows.isNotEmpty ? b.daRows.first.days : 0;
      final taDates = b.taGroups
          .map((g) => DateTime(g.date.year, g.date.month, g.date.day))
          .toSet();
      _selectedSessionIds = widget.allSessions
          .where((s) => taDates.contains(DateTime(s.date.year, s.date.month, s.date.day)))
          .map((s) => s.id)
          .toSet();
    } else {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      _taGroups = [];
      if (widget.preselectedSessionIds != null) {
        _selectedSessionIds = Set.from(widget.preselectedSessionIds!);
        _updateFromSelectedSessions();
      }
    }
  }

  void _updateFromSelectedSessions() {
    final selected = widget.allSessions
        .where((s) => _selectedSessionIds.contains(s.id))
        .toList();
    if (selected.isEmpty) {
      setState(() { _taGroups = []; _daDays = 0; });
      return;
    }
    final dates = selected
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet().toList()..sort();
    setState(() {
      _fromDate = dates.first;
      _toDate = dates.last;
      _taGroups = dates.map((d) => TaGroupData(d)).toList();
      _daDays = dates.length;
    });
  }

  String get _counselorName =>
      widget.existingBill?.counselorName.isNotEmpty == true
          ? widget.existingBill!.counselorName
          : (ref.read(authProvider).name ?? '');

  String get _designation =>
      widget.existingBill?.designation.isNotEmpty == true
          ? widget.existingBill!.designation
          : (ref.read(authProvider).designation ?? '');

  int get _totalTA => _taGroups.fold(0, (sum, g) => sum + g.subTotal);

  int get _totalDA {
    int t = 0;
    t += _daDays * 500;
    t += _daDays * 200;
    for (final g in _taGroups) {
      if (g.includeMobile) t += 300;
    }
    return t;
  }

  int get _grandTotal => _totalTA + _totalDA;

  List<DaRow> _buildDaRows() {
    return [
      DaRow(label: 'Pocket Money', days: _daDays, rate: 500, total: _daDays * 500),
      DaRow(label: 'Lunch Allowance', days: _daDays, rate: 200, total: _daDays * 200),
    ];
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_taGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one TA entry')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final bill = Bill(
        id: widget.existingBill?.id ?? '',
        clientId: widget.clientId,
        counselorId: ref.read(authProvider).uid ?? '',
        organizationId: '',
        counselorName: _counselorName,
        designation: _designation,
        department: 'Health',
        purpose: 'Home visit to provide psychosocial support',
        fromDate: _fromDate,
        toDate: _toDate,
        taGroups: _taGroups.map((g) => TaDateGroup(
          date: g.date,
          legs: g.legs.map((l) => TaLeg(from: l.from, to: l.to, mode: l.mode, fare: l.fare, remarks: l.remarks)).toList(),
          includeMobile: g.includeMobile,
        )).toList(),
        daRows: _buildDaRows(),
        totalTA: _totalTA,
        totalDA: _totalDA,
        grandTotal: _grandTotal,
        createdAt: widget.existingBill?.createdAt ?? DateTime.now(),
      );

      final repo = ref.read(billRepositoryProvider);
      if (widget.existingBill != null) {
        await repo.updateBill(bill);
      } else {
        await repo.saveBill(bill);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bill: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportPdf() async {
    final bill = Bill(
      id: widget.existingBill?.id ?? 'preview',
      clientId: widget.clientId,
      counselorId: ref.read(authProvider).uid ?? '',
      organizationId: '',
      counselorName: _counselorName.isNotEmpty ? _counselorName : 'Counselor',
      designation: _designation,
      department: 'Health',
      purpose: 'Home visit to provide psychosocial support',
      fromDate: _fromDate,
      toDate: _toDate,
      taGroups: _taGroups.map((g) => TaDateGroup(
        date: g.date,
        legs: g.legs.map((l) => TaLeg(from: l.from, to: l.to, mode: l.mode, fare: l.fare, remarks: l.remarks)).toList(),
        includeMobile: g.includeMobile,
      )).toList(),
      daRows: _buildDaRows(),
      totalTA: _totalTA,
      totalDA: _totalDA,
      grandTotal: _grandTotal,
      createdAt: DateTime.now(),
    );
    await BillPdfGenerator.preview(bill, showSummary: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final sectionColor = isDark ? const Color(0xFF2A2A3D) : Colors.white;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              child: MaxWidthContainer(
                padding: pagePadding(context),
                child: Row(
                  children: [
                    BackButton(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingBill != null ? 'Edit Bill' : 'New Bill',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(widget.clientId, style: TextStyle(fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: _exportPdf, child: const Text('Preview')),
                    FilledButton(
                      onPressed: _saving ? null : _saveBill,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: MaxWidthContainer(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      SectionCard(
                        title: 'Select Completed Sessions',
                        sectionColor: sectionColor,
                        textColor: textColor,
                        child: _completedSessions.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: 40,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text('Please add a completed session first',
                                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  ..._completedSessions.map((s) => CheckboxListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    title: Text('${DateFormat('dd/MM/yyyy').format(s.date)} — ${s.title.isNotEmpty ? s.title : 'Session'}',
                                      style: TextStyle(fontSize: 13, color: textColor)),
                                    value: _selectedSessionIds.contains(s.id),
                                    onChanged: widget.existingBill != null
                                        ? null
                                        : (v) {
                                            setState(() {
                                              if (v == true) {
                                                _selectedSessionIds.add(s.id);
                                              } else {
                                                _selectedSessionIds.remove(s.id);
                                              }
                                              _updateFromSelectedSessions();
                                            });
                                          },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  )),
                                  if (_selectedSessionIds.isNotEmpty && widget.existingBill == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('${_selectedSessionIds.length} session(s) selected — $_daDays day(s)',
                                          style: TextStyle(fontSize: 12,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SectionCard(
                        title: 'Traveling Allowance',
                        sectionColor: sectionColor,
                        textColor: textColor,
                        child: _selectedSessionIds.isNotEmpty || widget.existingBill != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ..._taGroups.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final group = entry.value;
                                    return TaDateGroupCard(
                                      index: idx,
                                      group: group,
                                      textColor: textColor,
                                      onChanged: () => setState(() {}),
                                    );
                                  }),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Add Trip', style: TextStyle(fontSize: 11)),
                                        onPressed: _taGroups.isNotEmpty
                                            ? () => _showLegDialogForGroup(context, _taGroups.last)
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text('Sub-Total: $_totalTA',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                    ],
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('Please select sessions to add TA',
                                    style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SectionCard(
                        title: 'Daily Allowance ($_daDays days)',
                        sectionColor: sectionColor,
                        textColor: textColor,
                        child: Column(
                          children: [
                            _daRow('Pocket Money', 500, _daDays, textColor),
                            _daRow('Lunch Allowance', 200, _daDays, textColor),
                            const Divider(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Mobile Allowance', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 2),
                                      Text('300 tk per day',
                                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _taGroups.any((g) => g.includeMobile),
                                  onChanged: (v) {
                                    setState(() {
                                      for (final g in _taGroups) {
                                        g.includeMobile = v;
                                      }
                                    });
                                  },
                                  activeThumbColor: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              _totalRow('Total TA', _totalTA, textColor),
                              _totalRow('Total DA', _totalDA, textColor),
                              const Divider(),
                              _totalRow('Grand Total', _grandTotal, textColor, bold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Preview PDF'),
                              onPressed: _exportPdf,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: FilledButton.icon(
                              icon: _saving
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.save),
                              label: Text(_saving ? 'Saving...' : 'Save Bill'),
                              onPressed: _saving ? null : _saveBill,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daRow(String label, int rate, int days, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor)),
          Text('$rate×$days = ${rate * days}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, int amount, Color textColor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: textColor)),
          Text('$amount',
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: bold ? 18 : 16, color: textColor)),
        ],
      ),
    );
  }

  Future<void> _showLegDialogForGroup(BuildContext context, TaGroupData group) async {
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
              TextField(controller: fromCtrl,
                decoration: const InputDecoration(labelText: 'From', isDense: true, border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: toCtrl,
                decoration: const InputDecoration(labelText: 'To', isDense: true, border: OutlineInputBorder())),
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
                        return TextField(
                          controller: controller, focusNode: focusNode,
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
              TextField(controller: remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks', isDense: true, border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Add')),
        ],
      ),
    );

    if (result == true) {
      group.legs.add(TaLegData(fromCtrl.text, toCtrl.text, modeCtrl.text, int.tryParse(fareCtrl.text) ?? 0, remarksCtrl.text));
      setState(() {});
    }

    fromCtrl.dispose();
    toCtrl.dispose();
    modeCtrl.dispose();
    fareCtrl.dispose();
    remarksCtrl.dispose();
  }
}
