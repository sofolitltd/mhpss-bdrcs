import 'package:cloud_firestore/cloud_firestore.dart';

class TaLeg {
  String from;
  String to;
  String mode;
  int fare;
  String remarks;

  TaLeg({
    this.from = '',
    this.to = '',
    this.mode = '',
    this.fare = 0,
    this.remarks = '',
  });

  Map<String, dynamic> toMap() => {
        'from': from,
        'to': to,
        'mode': mode,
        'fare': fare,
        'remarks': remarks,
      };

  factory TaLeg.fromMap(Map<String, dynamic> map) => TaLeg(
        from: map['from'] ?? '',
        to: map['to'] ?? '',
        mode: map['mode'] ?? '',
        fare: (map['fare'] ?? 0) as int,
        remarks: map['remarks'] ?? '',
      );
}

class TaDateGroup {
  DateTime date;
  List<TaLeg> legs;
  bool includeMobile;

  TaDateGroup({
    required this.date,
    List<TaLeg>? legs,
    this.includeMobile = false,
  }) : legs = legs ?? [];

  int get subTotal => legs.fold(0, (total, leg) => total + leg.fare);

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'legs': legs.map((l) => l.toMap()).toList(),
        'includeMobile': includeMobile,
      };

  factory TaDateGroup.fromMap(Map<String, dynamic> map) => TaDateGroup(
        date: (map['date'] as Timestamp).toDate(),
        legs: (map['legs'] as List?)
                ?.map((l) => TaLeg.fromMap(l as Map<String, dynamic>))
                .toList() ??
            [],
        includeMobile: map['includeMobile'] ?? false,
      );
}

class DaRow {
  String label;
  int days;
  int rate;
  int total;
  bool isOptional;

  DaRow({
    required this.label,
    this.days = 0,
    this.rate = 0,
    this.total = 0,
    this.isOptional = false,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'days': days,
        'rate': rate,
        'total': total,
        'isOptional': isOptional,
      };

  factory DaRow.fromMap(Map<String, dynamic> map) => DaRow(
        label: map['label'] ?? '',
        days: (map['days'] ?? 0) as int,
        rate: (map['rate'] ?? 0) as int,
        total: (map['total'] ?? 0) as int,
        isOptional: map['isOptional'] ?? false,
      );
}

class Bill {
  final String id;
  final String clientId;
  final String counselorId;
  final String organizationId;
  final String counselorName;
  final String designation;
  final String department;
  final String purpose;
  final DateTime fromDate;
  final DateTime toDate;
  final List<TaDateGroup> taGroups;
  final List<DaRow> daRows;
  final int totalTA;
  final int totalDA;
  final int grandTotal;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.clientId,
    required this.counselorId,
    required this.organizationId,
    this.counselorName = '',
    this.designation = '',
    this.department = 'Health',
    this.purpose = 'Home visit to provide psychosocial support',
    required this.fromDate,
    required this.toDate,
    this.taGroups = const [],
    this.daRows = const [],
    this.totalTA = 0,
    this.totalDA = 0,
    this.grandTotal = 0,
    required this.createdAt,
  });

  factory Bill.fromMap(Map<String, dynamic> map, String id) => Bill(
        id: id,
        clientId: map['clientId'] ?? '',
        counselorId: map['counselorId'] ?? '',
        organizationId: map['organizationId'] ?? '',
        counselorName: map['counselorName'] ?? '',
        designation: map['designation'] ?? '',
        department: map['department'] ?? 'Health',
        purpose: map['purpose'] ?? 'Home visit to provide psychosocial support',
        fromDate: (map['fromDate'] as Timestamp).toDate(),
        toDate: (map['toDate'] as Timestamp).toDate(),
        taGroups: (map['taGroups'] as List?)
                ?.map((g) => TaDateGroup.fromMap(g as Map<String, dynamic>))
                .toList() ??
            [],
        daRows: (map['daRows'] as List?)
                ?.map((r) => DaRow.fromMap(r as Map<String, dynamic>))
                .toList() ??
            [],
        totalTA: (map['totalTA'] ?? 0) as int,
        totalDA: (map['totalDA'] ?? 0) as int,
        grandTotal: (map['grandTotal'] ?? 0) as int,
        createdAt: (map['createdAt'] is Timestamp
                ? (map['createdAt'] as Timestamp).toDate()
                : DateTime.now()),
      );

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'counselorId': counselorId,
        'organizationId': organizationId,
        'counselorName': counselorName,
        'designation': designation,
        'department': department,
        'purpose': purpose,
        'fromDate': Timestamp.fromDate(fromDate),
        'toDate': Timestamp.fromDate(toDate),
        'taGroups': taGroups.map((g) => g.toMap()).toList(),
        'daRows': daRows.map((r) => r.toMap()).toList(),
        'totalTA': totalTA,
        'totalDA': totalDA,
        'grandTotal': grandTotal,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
