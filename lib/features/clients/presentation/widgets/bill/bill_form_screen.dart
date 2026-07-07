import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/design_system/app_design_system.dart';
import '/core/services/bill_pdf_generator.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/session.dart';
import '../../../data/bill_repository.dart';
import 'ta_models.dart';
import 'bill_form_header.dart';
import 'bill_form_body.dart';
import 'bill_builder.dart';
import 'trip_dialog.dart';

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
          .map(
            (g) => TaGroupData(
              g.date,
              g.legs
                  .map(
                    (l) => TaLegData(l.from, l.to, l.mode, l.fare, l.remarks),
                  )
                  .toList(),
              g.includeMobile,
            ),
          )
          .toList();
      _daDays = b.daRows.isNotEmpty ? b.daRows.first.days : 0;
      final taDates = b.taGroups
          .map((g) => DateTime(g.date.year, g.date.month, g.date.day))
          .toSet();
      _selectedSessionIds = widget.allSessions
          .where(
            (s) => taDates.contains(
              DateTime(s.date.year, s.date.month, s.date.day),
            ),
          )
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
      setState(() {
        _taGroups = [];
        _daDays = 0;
      });
      return;
    }
    final dates =
        selected
            .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
            .toSet()
            .toList()
          ..sort();
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

  String get _designation => widget.existingBill?.designation.isNotEmpty == true
      ? widget.existingBill!.designation
      : (ref.read(authProvider).designation ?? '');

  int get _totalTA => _taGroups.fold(0, (sum, g) => sum + g.subTotal);

  int get _totalDA {
    int t = 0;
    t += _daDays * 500;
    t += _daDays * 200;
    return t;
  }

  int get _totalMobile =>
      _taGroups.where((g) => g.includeMobile).length * 300;

  int get _grandTotal => _totalTA + _totalDA + _totalMobile;

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
      final bill = buildBill(
        id: widget.existingBill?.id ?? '',
        clientId: widget.clientId,
        counselorId: ref.read(authProvider).uid ?? '',
        counselorName: _counselorName,
        designation: _designation,
        fromDate: _fromDate,
        toDate: _toDate,
        taGroups: _taGroups,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bill saved successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving bill: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<DaRow> _buildDaRows() {
    return [
      DaRow(
        label: 'Pocket Money',
        days: _daDays,
        rate: 500,
        total: _daDays * 500,
      ),
      DaRow(
        label: 'Lunch Allowance',
        days: _daDays,
        rate: 200,
        total: _daDays * 200,
      ),
    ];
  }

  Future<void> _exportPdf() async {
    final bill = buildBill(
      id: widget.existingBill?.id ?? 'preview',
      clientId: widget.clientId,
      counselorId: ref.read(authProvider).uid ?? '',
      counselorName: _counselorName.isNotEmpty ? _counselorName : 'Counselor',
      designation: _designation,
      fromDate: _fromDate,
      toDate: _toDate,
      taGroups: _taGroups,
      daRows: _buildDaRows(),
      totalTA: _totalTA,
      totalDA: _totalDA,
      grandTotal: _grandTotal,
      createdAt: DateTime.now(),
    );
    await BillPdfGenerator.preview(bill, showSummary: false);
  }

  void _onSessionToggled(String sessionId, bool selected) {
    setState(() {
      if (selected) {
        _selectedSessionIds.add(sessionId);
      } else {
        _selectedSessionIds.remove(sessionId);
      }
      _updateFromSelectedSessions();
    });
  }

  Future<void> _handleAddTrip() async {
    if (_taGroups.isEmpty) return;
    final result = await TripDialog.show(context, _taGroups.last);
    if (result == true && mounted) setState(() {});
  }

  void _onMobileToggle(bool v) {
    setState(() {
      for (final g in _taGroups) {
        g.includeMobile = v;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            BillFormHeader(
              isDark: isDark,
              clientId: widget.clientId,
              isEditing: widget.existingBill != null,
              onPreview: _exportPdf,
              isSaving: _saving,
              onSave: _saveBill,
            ),
            Expanded(
              child: MaxWidthContainer(
                child: Form(
                  key: _formKey,
                  child: BillFormBody(
                    completedSessions: _completedSessions,
                    selectedSessionIds: _selectedSessionIds,
                    textColor: textColor,
                    isDark: isDark,
                    readOnly: widget.existingBill != null,
                    onSessionToggled: _onSessionToggled,
                    daDays: _daDays,
                    taGroups: _taGroups,
                    totalTA: _totalTA,
                    onAddTrip: _taGroups.isNotEmpty ? _handleAddTrip : null,
                    onTaChanged: () => setState(() {}),
                    includeMobile: _taGroups.any((g) => g.includeMobile),
                    onMobileToggle: _onMobileToggle,
                    totalDA: _totalDA,
                    grandTotal: _grandTotal,
                    isSaving: _saving,
                    onExportPdf: _exportPdf,
                    onSaveBill: _saveBill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
