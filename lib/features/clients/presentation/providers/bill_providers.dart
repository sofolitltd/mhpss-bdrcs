import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/bill_repository.dart';
import '../../domain/models/bill.dart';

part 'bill_providers.g.dart';

@riverpod
Stream<List<Bill>> clientBills(Ref ref, String clientId) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.watchBillsByClientId(clientId);
}
