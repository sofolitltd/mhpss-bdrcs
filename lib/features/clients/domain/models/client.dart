import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String organizationId;
  final List<String> counselorIds;
  final String caseId;
  final String name;

  String get capitalizedName => name.split(' ').map((w) =>
    w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : ''
  ).join(' ');
  final String address;
  final String district;
  final String gender;
  final String ageRange;
  final String category;
  final String note;
  final DateTime createdAt;
  final DateTime? joinDate;
  final String? phone;
  final String? alternatePhone;

  static const List<String> categories = ['A', 'B', 'C', 'D'];

  Client({
    required this.id,
    required this.organizationId,
    required this.counselorIds,
    required this.caseId,
    required this.name,
    this.address = '',
    this.district = '',
    required this.gender,
    required this.ageRange,
    this.category = '',
    this.note = '',
    required this.createdAt,
    this.joinDate,
    this.phone,
    this.alternatePhone,
  });

  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      organizationId: map['organizationId'] ?? '',
      counselorIds: List<String>.from(map['counselorIds'] ?? []),
      caseId: map['caseId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      gender: map['gender'] ?? '',
      ageRange: map['ageRange'] ?? '',
      category: map['category'] ?? '',
      note: map['note'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      joinDate: map['joinDate'] is Timestamp
          ? (map['joinDate'] as Timestamp).toDate()
          : map['joinDate'] is String
              ? DateTime.parse(map['joinDate'] as String)
              : null,
      phone: map['phone'] as String?,
      alternatePhone: map['alternatePhone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'counselorIds': counselorIds,
      'caseId': caseId,
      'name': name,
      'address': address,
      'district': district,
      'gender': gender,
      'ageRange': ageRange,
      'category': category,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      if (joinDate != null) 'joinDate': Timestamp.fromDate(joinDate!),
      if (phone != null) 'phone': phone,
      if (alternatePhone != null) 'alternatePhone': alternatePhone,
    };
  }
}
