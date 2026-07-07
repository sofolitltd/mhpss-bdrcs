import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/bill.dart';

final billRepositoryProvider = Provider((ref) => BillRepository());

class BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _bills => _firestore.collection('bills');

  Future<void> saveBill(Bill bill) async {
    try {
      await _bills.add(bill.toMap());
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<void> updateBill(Bill bill) async {
    try {
      await _bills.doc(bill.id).update(bill.toMap());
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _bills.doc(billId).delete();
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<List<Bill>> getBillsByClientAndCounselor(
      String clientId, String counselorId) async {
    try {
      final snapshot = await _bills
          .where('clientId', isEqualTo: clientId)
          .where('counselorId', isEqualTo: counselorId)
          .get();
      return snapshot.docs
          .map((doc) => Bill.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Future<List<Bill>> getBillsByClientId(String clientId) async {
    try {
      final snapshot = await _bills
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Bill.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      _logIndexUrl(e);
      rethrow;
    }
  }

  Stream<List<Bill>> watchBillsByClientId(String clientId) {
    return _bills
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bill.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
