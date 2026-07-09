import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '/core/logger/app_logger.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/session.dart';
import '../providers/client_detail_providers.dart';
import '../widgets/bill_tab.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';
import '../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'session_detail_screen/add_counselor_dialog.dart';
import 'session_detail_screen/session_detail_app_bar.dart';
import 'session_detail_screen/session_detail_body.dart';
import 'session_detail_screen/location_helper.dart';

export 'widgets/session_detail_loader.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});
  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  late final TextEditingController _notesController;
  late String _status;
  late DateTime _date;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _followUpDate;
  late List<String> _counselorIds;
  double? _latitude;
  double? _longitude;
  DateTime? _locationTimestamp;
  bool _isSaving = false;
  bool _isLocating = false;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session.notes);
    _status = widget.session.status;
    _date = widget.session.date;
    _startTime = widget.session.startTime;
    _endTime = widget.session.endTime;
    _followUpDate = widget.session.followUpDate;
    _counselorIds = List.from(widget.session.counselorIds);
    _latitude = widget.session.latitude;
    _longitude = widget.session.longitude;
    _locationTimestamp = widget.session.locationTimestamp;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _notesController.text != widget.session.notes ||
      _status != widget.session.status ||
      _date != widget.session.date ||
      _startTime != widget.session.startTime ||
      _endTime != widget.session.endTime ||
      _followUpDate != widget.session.followUpDate ||
      !listEquals(_counselorIds, widget.session.counselorIds) ||
      _latitude != widget.session.latitude ||
      _longitude != widget.session.longitude ||
      _locationTimestamp != widget.session.locationTimestamp;

  Future<void> _save() async {
    if (!_hasChanges) return;
    setState(() => _isSaving = true);
    try {
      final updated = widget.session.copyWith(
        notes: _notesController.text.trim(),
        status: _status,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        followUpDate: _followUpDate,
        counselorIds: _counselorIds,
        latitude: _latitude,
        longitude: _longitude,
        locationTimestamp: _locationTimestamp,
      );
      await ref.read(sessionRepositoryProvider).updateSession(updated);
      ref.invalidate(allSessionsProvider);
      ref.invalidate(dashboardDataProvider);
      AppLogger.info('Session saved', {
        'sessionId': widget.session.id,
        'clientId': widget.session.clientId,
        'hasLocation': _latitude != null,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Session saved')));
      }
    } catch (e, stack) {
      AppLogger.error(
        'Failed to save session',
        {'sessionId': widget.session.id},
        e,
        stack,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _recordLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final pos = await getGpsPosition(widget.session.id);
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        if (pos != null) {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
          _locationTimestamp = DateTime.now();
        }
      });
      if (pos == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get GPS fix. Try stepping outside.'),
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error('GPS error', {'sessionId': widget.session.id}, e, stack);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _showAddCounselorDialog() async {
    final client = ref.read(clientByIdProvider(widget.session.clientId));
    if (client == null) return;
    final allCounselors = ref.read(allCounselorsProvider).value;
    if (allCounselors == null) return;
    final clientIds = client.counselorIds.toSet();
    final assigned = _counselorIds.toSet();
    final available = allCounselors
        .where((c) => clientIds.contains(c.id) && !assigned.contains(c.id))
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _counselorIds.isEmpty
                ? 'No counselors assigned to this client.'
                : 'All client counselors are already assigned.',
          ),
        ),
      );
      return;
    }
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => AddCounselorDialog(available: available),
    );
    if (result != null && result.isNotEmpty) {
      setState(
        () => _counselorIds = [
          ..._counselorIds,
          ...result.where((id) => !_counselorIds.contains(id)),
        ],
      );
    }
  }

  void _startAssessment() {
    context.go(
      '/clients/${widget.session.clientId}/new-assessment'
      '?clientAlias=${Uri.encodeComponent(widget.session.clientAlias)}'
      '&from=session&sessionId=${widget.session.id}',
    );
  }

  Future<void> _createBill() async {
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .getSessionsByClientId(widget.session.clientId);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillFormScreen(
          clientId: widget.session.clientId,
          allSessions: sessions,
          preselectedSessionIds: {widget.session.id},
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime != null
          ? TimeOfDay.fromDateTime(_startTime!)
          : const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select start time',
    );
    if (time == null) return;
    setState(
      () => _startTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime != null
          ? TimeOfDay.fromDateTime(_endTime!)
          : _startTime != null
              ? TimeOfDay.fromDateTime(_startTime!.add(const Duration(hours: 1)))
              : const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Select end time',
    );
    if (time == null) return;
    setState(
      () => _endTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _followUpDate = d);
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.outfit().fontFamily!;
    final assessmentsAsync = ref.watch(
      linkedAssessmentSessionsProvider(widget.session.id),
    );
    final authState = ref.watch(authProvider);
    final client = ref.watch(clientByIdProvider(widget.session.clientId));
    final team = authState.team ?? '';
    final caseId = client?.caseId ?? '';
    final clientName = client?.capitalizedName ?? '';
    final place = client != null ? '${client.address}, ${client.district}' : '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: SessionDetailAppBar(
        fontFamily: fontFamily,
        textPrimary: textPrimary,
        backgroundColor: bg,
        title: widget.session.title,
        hasChanges: _hasChanges,
        isSaving: _isSaving,
        onBack: () => Navigator.of(context).pop(),
        onCreateBill: _createBill,
        onSave: _save,
      ),
      body: SessionDetailBody(
        fontFamily: fontFamily,
        assessmentsAsync: assessmentsAsync,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        title: widget.session.title,
        clientAlias: widget.session.clientAlias,
        status: _status,
        followUpDate: _followUpDate,
        counselorIds: _counselorIds,
        latitude: _latitude,
        longitude: _longitude,
        locationTimestamp: _locationTimestamp,
        isLocating: _isLocating,
        mapController: _mapController,
        notesController: _notesController,
        onPickDate: _pickDate,
        onPickStartTime: _pickStartTime,
        onPickEndTime: _pickEndTime,
        onClearStartTime: () => setState(() => _startTime = null),
        onClearEndTime: () => setState(() => _endTime = null),
        onStatusChanged: (s) => setState(() => _status = s),
        onPickFollowUpDate: _pickFollowUpDate,
        onClearFollowUpDate: () => setState(() => _followUpDate = null),
        onRemoveCounselor: _counselorIds.length <= 1
            ? null
            : (uid) => setState(() => _counselorIds.remove(uid)),
        onAddCounselor: _showAddCounselorDialog,
        onStartAssessment: _startAssessment,
        onNotesChanged: (_) => setState(() {}),
        onRecordLocation: _recordLocation,
        onRemoveLocation: () => setState(() {
          _latitude = null;
          _longitude = null;
          _locationTimestamp = null;
        }),
        onOpenInMaps: () => launchUrl(
          Uri.parse('https://www.google.com/maps?q=$_latitude,$_longitude'),
          mode: LaunchMode.externalApplication,
        ),
        team: team,
        caseId: caseId,
        clientName: clientName,
        place: place,
      ),
    );
  }
}
