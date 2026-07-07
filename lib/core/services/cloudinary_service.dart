import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final String url;
  final String publicId;
  final int bytes;

  CloudinaryUploadResult({
    required this.url,
    required this.publicId,
    required this.bytes,
  });
}

class CloudinaryService {
  static const _folder = 'mhpss-bdrcs';

  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  bool get isConfigured =>
      _cloudName.isNotEmpty && _apiKey.isNotEmpty && _apiSecret.isNotEmpty;

  String _generateSignature(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final signatureStr = sortedKeys
        .map((k) => '$k=${params[k]}')
        .join('&');
    final hash = sha1.convert(utf8.encode('$signatureStr$_apiSecret'));
    return hash.toString();
  }

  Future<CloudinaryUploadResult> uploadFile({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    if (!isConfigured) {
      throw Exception(
        'Cloudinary not configured. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in .env',
      );
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    final params = <String, String>{
      'timestamp': timestamp,
      'folder': _folder,
    };

    final signature = _generateSignature(params);

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/auto/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp;
    request.fields['folder'] = _folder;
    request.fields['signature'] = signature;

    if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'file',
      ));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else {
      throw Exception('Either filePath or fileBytes must be provided');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      debugPrint('\n══════════════ CLOUDINARY ERROR ══════════════');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('══════════════════════════════════════════════\n');
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CloudinaryUploadResult(
      url: data['secure_url'] as String,
      publicId: data['public_id'] as String,
      bytes: data['bytes'] as int,
    );
  }

  Future<void> deleteFile(String publicId) async {
    if (!isConfigured) {
      throw Exception('Cloudinary not configured');
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    final params = <String, String>{
      'public_id': publicId,
      'timestamp': timestamp,
    };

    final signature = _generateSignature(params);

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/upload/destroy');
    final request = http.MultipartRequest('POST', uri);

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp;
    request.fields['public_id'] = publicId;
    request.fields['signature'] = signature;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      debugPrint('\n══════════════ CLOUDINARY DELETE ERROR ══════════════');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('══════════════════════════════════════════════════════\n');
      throw Exception('Cloudinary delete failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['result'] != 'ok') {
      debugPrint('\n══════════════ CLOUDINARY DELETE RESULT ══════════════');
      debugPrint('Result: ${data['result']}');
      debugPrint('══════════════════════════════════════════════════════\n');
      throw Exception('Cloudinary delete returned: ${data['result']}');
    }
  }
}
