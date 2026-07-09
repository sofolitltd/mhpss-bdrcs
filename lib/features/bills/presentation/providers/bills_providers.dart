import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../clients/data/client_repository.dart';
import '../../../clients/data/bill_repository.dart';
import '../../../clients/domain/models/bill.dart';
import '../../../clients/domain/models/client.dart';
import '../../../clients/domain/session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/providers/client_detail_providers.dart';

part 'bills_providers.g.dart';

// ─── Selected Month ───────────────────────────────────────────────────────────

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }

  void goToPrevious() {
    final m = state.month == 1 ? 12 : state.month - 1;
    final y = state.month == 1 ? state.year - 1 : state.year;
    state = DateTime(y, m, 1);
  }

  void goToNext() {
    final m = state.month == 12 ? 1 : state.month + 1;
    final y = state.month == 12 ? state.year + 1 : state.year;
    state = DateTime(y, m, 1);
  }

  void setAllTime() {
    state = DateTime(1970, 1, 1);
  }

  bool get isAllTime => state.year == 1970;
}

@Riverpod(keepAlive: true)
class SelectedBillsMonth extends _$SelectedBillsMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }

  void goToPrevious() {
    final m = state.month == 1 ? 12 : state.month - 1;
    final y = state.month == 1 ? state.year - 1 : state.year;
    state = DateTime(y, m, 1);
  }

  void goToNext() {
    final m = state.month == 12 ? 1 : state.month + 1;
    final y = state.month == 12 ? state.year + 1 : state.year;
    state = DateTime(y, m, 1);
  }

  void setAllTime() {
    state = DateTime(1970, 1, 1);
  }

  bool get isAllTime => state.year == 1970;
}

// ─── Selected Sessions ────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class SelectedBillsSessions extends _$SelectedBillsSessions {
  @override
  Set<String> build() => {};

  void toggle(String sessionId) {
    if (state.contains(sessionId)) {
      state = {...state}..remove(sessionId);
    } else {
      state = {...state, sessionId};
    }
  }

  void selectAll(List<String> ids) {
    state = ids.toSet();
  }

  void deselectAll() {
    state = {};
  }

  bool isSelected(String sessionId) => state.contains(sessionId);
}

// ─── Combined Model ───────────────────────────────────────────────────────────

class BillSessionRow {
  final Session session;
  final Client? client;
  final int sessionNumber;
  final int totalTA;
  final Bill? existingBill;

  const BillSessionRow({
    required this.session,
    required this.client,
    required this.sessionNumber,
    this.totalTA = 0,
    this.existingBill,
  });
}

// ─── Sessions For Billing ────────────────────────────────────────────────────

@riverpod
Future<List<BillSessionRow>> billsSessionRows(Ref ref) async {
  final authState = ref.watch(authProvider);
  final orgId = authState.organizationId;
  final uid = authState.uid;

  if (orgId == null || uid == null) return [];

  final selectedMonth = ref.watch(selectedBillsMonthProvider);
  final isAllTime = selectedMonth.year == 1970;

  final clientRepo = ref.read(clientRepositoryProvider);
  final sessionRepo = ref.read(sessionRepositoryProvider);

  final clients = await clientRepo.getClients(orgId, uid);
  final clientMap = <String, Client>{for (final c in clients) c.id: c};

  DateTime? startDate;
  DateTime? endDate;
  if (!isAllTime) {
    final m = selectedMonth.month;
    final y = selectedMonth.year;
    startDate = m == 1
        ? DateTime(y - 1, 12, 21)
        : DateTime(y, m - 1, 21);
    endDate = DateTime(y, m, 21);
  }

  final allSessions = <Session>[];
  for (final client in clients) {
    final sessions = await sessionRepo.getSessionsByClientId(client.id);
    allSessions.addAll(sessions);
  }

  allSessions.sort((a, b) => a.date.compareTo(b.date));

  final filtered = (isAllTime
          ? allSessions
          : allSessions.where((s) {
              return !s.date.isBefore(startDate!) && s.date.isBefore(endDate!);
            }))
      .where((s) => s.status == 'completed')
      .toList();

  final allSortedByClient = <String, List<Session>>{};
  for (final s in allSessions) {
    allSortedByClient.putIfAbsent(s.clientId, () => []).add(s);
  }
  final sessionNumberMap = <String, int>{};
  for (final entry in allSortedByClient.entries) {
    entry.value.sort((a, b) => a.date.compareTo(b.date));
    for (int i = 0; i < entry.value.length; i++) {
      sessionNumberMap[entry.value[i].id] = i + 1;
    }
  }

  // Build a dateKey → totalTA map and dateKey → Bill map from saved bills
  final clientIds = clients.map((c) => c.id).toSet();
  final billRepo = ref.read(billRepositoryProvider);
  final allBills = <Bill>[];
  for (final cid in clientIds) {
    final bills = await billRepo.getBillsByClientAndCounselor(cid, uid);
    allBills.addAll(bills);
  }
  final taMap = <String, int>{};
  final billMap = <String, Bill>{};
  for (final bill in allBills) {
    for (final group in bill.taGroups) {
      final key = '${bill.clientId}_${group.date.year}_${group.date.month}_${group.date.day}';
      taMap[key] = (taMap[key] ?? 0) + group.subTotal;
      billMap.putIfAbsent(key, () => bill);
    }
  }

  return filtered
      .map((s) {
        final key = '${s.clientId}_${s.date.year}_${s.date.month}_${s.date.day}';
        return BillSessionRow(
          session: s,
          client: clientMap[s.clientId],
          sessionNumber: sessionNumberMap[s.id] ?? 1,
          totalTA: taMap[key] ?? 0,
          existingBill: billMap[key],
        );
      })
      .toList();
}
