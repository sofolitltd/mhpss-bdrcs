import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloudinary_service.dart';
import '../domain/models/client_document.dart';

final documentRepositoryProvider = Provider((ref) => DocumentRepository());

class DocumentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference get _docs => _firestore.collection('client_documents');

  Future<void> addDocument(ClientDocument doc) async {
    try {
      await _docs.add(doc.toMap());
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<void> deleteDocument(String docId, String publicId) async {
    try {
      if (publicId.isNotEmpty) {
        await _cloudinary.deleteFile(publicId);
      }
      await _docs.doc(docId).delete();
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<List<ClientDocument>> getDocumentsByClientId(String clientId) async {
    try {
      final snapshot = await _docs
          .where('clientId', isEqualTo: clientId)
          .orderBy('uploadedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ClientDocument.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Stream<List<ClientDocument>> watchDocumentsByClientId(String clientId) {
    return _docs
        .where('clientId', isEqualTo: clientId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClientDocument.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList())
        .handleError((error) {
          if (error is FirebaseException) {
            _logIndexUrl(error);
          }
          throw error;
        });
  }

  void _logIndexUrl(FirebaseException e) {
    if (e.code == 'failed-precondition' || e.message?.contains('index') == true) {
      final url = _extractUrl(e.message ?? '');
      if (url != null) {
        debugPrint('\n═══════════════════════════════════════════════════');
        debugPrint('  FIRESTORE: Missing composite index');
        debugPrint('  Create it here:');
        debugPrint('  $url');
        debugPrint('═══════════════════════════════════════════════════\n');
      }
    }
  }

  String? _extractUrl(String message) {
    final regex = RegExp(r'(https?://[^\s]+)');
    final match = regex.firstMatch(message);
    return match?.group(1);
  }
}
