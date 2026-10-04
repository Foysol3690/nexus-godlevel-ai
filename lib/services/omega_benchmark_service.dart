import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaBenchmarkService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_benchmarks_v1';

  Future<Map<String, dynamic>> record({
    required String name,
    required Map<String, dynamic> metrics,
    String outcome = 'observed',
  }) async {
    final runs = await _read();
    final record = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': name.trim(),
      'metrics': metrics,
      'outcome': outcome,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    runs.insert(0, record);
    if (runs.length > 100) runs.removeRange(100, runs.length);
    await _write(runs);
    return {'success': true, 'benchmark': record};
  }

  Future<Map<String, dynamic>> proposeImprovement({
    required String target,
    required String hypothesis,
    required List<dynamic> tests,
  }) async {
    final runs = await _read();
    final proposal = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'target': target.trim(),
      'hypothesis': hypothesis.trim(),
      'tests': tests,
      'status': 'needs_owner_approval',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'policy': 'No self-modification or deployment is performed automatically.',
    };
    runs.insert(0, proposal);
    if (runs.length > 100) runs.removeRange(100, runs.length);
    await _write(runs);
    return {'success': true, 'proposal': proposal};
  }

  Future<Map<String, dynamic>> list({int limit = 50}) async => {
        'success': true,
        'records': (await _read()).take(limit).toList(),
      };

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
