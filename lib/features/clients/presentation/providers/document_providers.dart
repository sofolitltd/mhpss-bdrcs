import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/document_repository.dart';
import '../../domain/models/client_document.dart';

part 'document_providers.g.dart';

@riverpod
Stream<List<ClientDocument>> clientDocuments(ref, String clientId) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.watchDocumentsByClientId(clientId);
}
