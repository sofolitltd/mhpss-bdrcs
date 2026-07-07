import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/contact.dart';
import '../../domain/counselor.dart';
import '../../data/contact_repository.dart';
import '../../data/counselor_repository.dart';

part 'contacts_providers.g.dart';

@riverpod
ContactRepository contactRepository(Ref ref) {
  return ContactRepository();
}

@riverpod
Stream<List<Contact>> clientContacts(Ref ref, String clientId) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchContactsByClientId(clientId).handleError((_) => <Contact>[]);
}

@riverpod
Stream<List<Contact>> allContacts(Ref ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchAllContacts().handleError((_) => <Contact>[]);
}

@riverpod
CounselorRepository counselorRepository(Ref ref) {
  return CounselorRepository();
}

@riverpod
Stream<List<Counselor>> allCounselors(Ref ref) {
  final repository = ref.watch(counselorRepositoryProvider);
  return repository.watchAllCounselors().handleError((_) => <Counselor>[]);
}
