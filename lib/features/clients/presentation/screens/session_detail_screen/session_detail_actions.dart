part of '../session_detail_screen.dart';

mixin SessionDetailActions on ConsumerState<SessionDetailScreen> {
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
      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _recordLocation() async {
    if (_isLocating) {
      AppLogger.warn('Record location skipped — already in progress');
      return;
    }
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
          AppLogger.info('Location recorded', {
            'sessionId': widget.session.id,
            'latitude': pos.latitude,
            'longitude': pos.longitude,
            'accuracy': pos.accuracy,
          });
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
    final ctx = context;
    final sessions = await ref
        .read(sessionRepositoryProvider)
        .getSessionsByClientId(widget.session.clientId);
    if (!mounted) return;
    Navigator.of(ctx).push(
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
}
