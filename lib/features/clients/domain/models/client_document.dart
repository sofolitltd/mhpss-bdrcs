import 'package:cloud_firestore/cloud_firestore.dart';

class ClientDocument {
  final String id;
  final String clientId;
  final String? sessionId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String publicId;
  final DateTime uploadedAt;

  ClientDocument({
    required this.id,
    required this.clientId,
    this.sessionId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.publicId,
    required this.uploadedAt,
  });

  factory ClientDocument.fromMap(Map<String, dynamic> map, String id) {
    return ClientDocument(
      id: id,
      clientId: map['clientId'] ?? '',
      sessionId: map['sessionId'] as String?,
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      publicId: map['publicId'] ?? '',
      uploadedAt: map['uploadedAt'] is Timestamp
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      if (sessionId != null) 'sessionId': sessionId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'publicId': publicId,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => fileType.startsWith('image/');
  bool get isPdf => fileType == 'application/pdf';
  bool get isDoc => fileType.contains('document');
}
