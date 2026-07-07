import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '/core/logger/app_logger.dart';
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

part 'session_detail_screen/session_detail_actions.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});
  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen>
    with SessionDetailActions {
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

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.outfit().fontFamily!;
    final assessmentsAsync = ref.watch(
      linkedAssessmentSessionsProvider(widget.session.id),
    );
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
      ),
    );
  }
}
