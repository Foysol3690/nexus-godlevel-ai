import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaVisualVerificationService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_visual_verification_v1';

  Future<Map<String, dynamic>> record({
    required String expected,
    required String observed,
    required String confidence,
    String source = 'camera',
  }) async {
    final record = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'expected': expected.trim(),
      'observed': observed.trim(),
      'confidence': confidence.trim().isEmpty ? 'uncertain' : confidence.trim(),
      'source': source,
      'verified': _matches(expected, observed),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    final records = await _read();
    records.insert(0, record);
    if (records.length > 100) records.removeRange(100, records.length);
    await _write(records);
    return {'success': true, 'verification': record};
  }

  Future<Map<String, dynamic>> history({int limit = 20}) async => {
        'success': true,
        'verifications': (await _read()).take(limit).toList(),
      };

  static bool _matches(String expected, String observed) {
    final cleanExpected = expected.trim().toLowerCase();
    final cleanObserved = observed.trim().toLowerCase();
    return cleanExpected.isNotEmpty &&
        cleanObserved.isNotEmpty &&
        (cleanObserved.contains(cleanExpected) ||
            cleanExpected.contains(cleanObserved));
  }

  Future<List<Map<String, dynamic>>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map>().map((item) {
          return item.map((key, value) => MapEntry(key.toString(), value));
        }).toList();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<void> _write(List<Map<String, dynamic>> value) =>
      _storage.write(key: _key, value: jsonEncode(value));
}
