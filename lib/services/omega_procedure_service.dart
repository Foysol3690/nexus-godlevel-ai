import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaProcedureService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_procedures_v1';

  Future<Map<String, dynamic>> save({
    required String name, required List<dynamic> steps,
    String source = 'owner', String outcome = 'unverified',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || steps.isEmpty) {
      return {'success': false, 'error': 'Procedure name and steps are required.'};
    }
    final procedures = await _read();
    final same = procedures.where((item) => item['name']?.toString().toLowerCase() == cleanName.toLowerCase());
    final version = same.length + 1;
    final record = {
      'id': '${DateTime.now().microsecondsSinceEpoch}', 'name': cleanName,
      'version': version, 'steps': steps, 'source': source, 'outcome': outcome,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    procedures.insert(0, record);
    if (procedures.length > 100) procedures.removeRange(100, procedures.length);
    await _write(procedures);
    return {'success': true, 'procedure': record};
  }

  Future<Map<String, dynamic>> list({String? name}) async {
    final procedures = await _read();
    final filtered = name == null || name.trim().isEmpty
        ? procedures
        : procedures.where((item) => item['name']?.toString().toLowerCase() == name.trim().toLowerCase()).toList();
    return {'success': true, 'procedures': filtered};
  }

  Future<Map<String, dynamic>> recordOutcome({required String id, required String outcome}) async {
    final procedures = await _read();
    final index = procedures.indexWhere((item) => item['id']?.toString() == id);
    if (index < 0) return {'success': false, 'error': 'Procedure not found.'};
    procedures[index]['outcome'] = outcome;
    procedures[index]['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _write(procedures);
    return {'success': true, 'procedure': procedures[index]};
  }

  Future<List<Map<String, dynamic>>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<Map>().map((item) => item.map((key, value) => MapEntry(key.toString(), value))).toList();
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<void> _write(List<Map<String, dynamic>> value) =>
      _storage.write(key: _key, value: jsonEncode(value));
}
