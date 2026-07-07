import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../assessment_engine/domain/assessment_session.dart';
import '../widgets/session_info_card.dart';
import '../widgets/session_sections.dart';
import '../widgets/session_assessment_section.dart';
import '../widgets/session_counselors_section.dart';
import '../widgets/session_location_section.dart';

class SessionDetailBody extends StatelessWidget {
  final String fontFamily;
  final AsyncValue<List<AssessmentSession>> assessmentsAsync;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String clientAlias;
  final String status;
  final DateTime? followUpDate;
  final List<String> counselorIds;
  final double? latitude;
  final double? longitude;
  final DateTime? locationTimestamp;
  final bool isLocating;
  final MapController mapController;
  final TextEditingController notesController;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback? onClearStartTime;
  final VoidCallback? onClearEndTime;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onPickFollowUpDate;
  final VoidCallback? onClearFollowUpDate;
  final ValueChanged<String>? onRemoveCounselor;
  final VoidCallback? onAddCounselor;
  final VoidCallback onStartAssessment;
  final ValueChanged<String>? onNotesChanged;
  final VoidCallback onRecordLocation;
  final VoidCallback onRemoveLocation;
  final VoidCallback onOpenInMaps;

  const SessionDetailBody({
    super.key,
    required this.fontFamily,
    required this.assessmentsAsync,
    required this.date,
    this.startTime,
    this.endTime,
    required this.title,
    required this.clientAlias,
    required this.status,
    this.followUpDate,
    required this.counselorIds,
    this.latitude,
    this.longitude,
    this.locationTimestamp,
    required this.isLocating,
    required this.mapController,
    required this.notesController,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    this.onClearStartTime,
    this.onClearEndTime,
    required this.onStatusChanged,
    required this.onPickFollowUpDate,
    this.onClearFollowUpDate,
    this.onRemoveCounselor,
    this.onAddCounselor,
    required this.onStartAssessment,
    this.onNotesChanged,
    required this.onRecordLocation,
    required this.onRemoveLocation,
    required this.onOpenInMaps,
  });

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SessionInfoCard(
            fontFamily: fontFamily,
            date: date,
            startTime: startTime,
            endTime: endTime,
            title: title,
            clientAlias: clientAlias,
            onPickDate: onPickDate,
            onPickStartTime: onPickStartTime,
            onPickEndTime: onPickEndTime,
            onClearStartTime: onClearStartTime,
            onClearEndTime: onClearEndTime,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionStatusSection(
            fontFamily: fontFamily,
            status: status,
            onStatusChanged: onStatusChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionFollowUpSection(
            fontFamily: fontFamily,
            followUpDate: followUpDate,
            onPickDate: onPickFollowUpDate,
            onClearDate: onClearFollowUpDate,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionCounselorsSection(
            fontFamily: fontFamily,
            counselorIds: counselorIds,
            onRemoveCounselor: onRemoveCounselor,
            onAddCounselor: onAddCounselor,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionAssessmentSection(
            fontFamily: fontFamily,
            assessmentsAsync: assessmentsAsync,
            onStartAssessment: onStartAssessment,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionNotesSection(
            fontFamily: fontFamily,
            controller: notesController,
            onChanged: onNotesChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          SessionLocationSection(
            fontFamily: fontFamily,
            latitude: latitude,
            longitude: longitude,
            locationTimestamp: locationTimestamp,
            isLoading: isLocating,
            mapController: mapController,
            onRecord: onRecordLocation,
            onRemove: onRemoveLocation,
            onOpenInMaps: onOpenInMaps,
          ),
        ],
      ),
    );
  }
}
