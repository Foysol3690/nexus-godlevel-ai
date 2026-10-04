import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaWorldModelService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_world_model_v1';

  Future<Map<String, dynamic>> observe({
    required String entity, required String attribute, required dynamic value,
    required String source, String confidence = 'supported', String scope = 'local',
  }) async {
    final cleanEntity = entity.trim();
    final cleanAttribute = attribute.trim();
    if (cleanEntity.isEmpty || cleanAttribute.isEmpty) return {'success': false, 'error': 'Entity and attribute are required.'};
    final model = await _read();
    final facts = (model['facts'] as List? ?? const []).whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value))).toList();
    final conflicts = facts.where((fact) =>
        fact['entity'] == cleanEntity && fact['attribute'] == cleanAttribute &&
        fact['value'].toString() != value.toString());
    final fact = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'entity': cleanEntity, 'attribute': cleanAttribute, 'value': value,
      'source': source, 'confidence': confidence, 'scope': scope,
      'observedAt': DateTime.now().toUtc().toIso8601String(),
      'status': conflicts.isEmpty ? 'active' : 'conflicting',
    };
    facts.insert(0, fact);
    if (facts.length > 500) facts.removeRange(500, facts.length);
    model['facts'] = facts;
    model['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _write(model);
    return {'success': true, 'fact': fact, 'conflictCount': conflicts.length, 'conflicts': conflicts.toList()};
  }

  Future<Map<String, dynamic>> query({String? entity, String? attribute}) async {
    final model = await _read();
    final facts = (model['facts'] as List? ?? const []).whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .where((fact) =>
            (entity == null || entity.trim().isEmpty || fact['entity'] == entity.trim()) &&
            (attribute == null || attribute.trim().isEmpty || fact['attribute'] == attribute.trim())).toList();
    return {'success': true, 'facts': facts, 'conflicts': facts.where((f) => f['status'] == 'conflicting').toList()};
  }

  Future<Map<String, dynamic>> snapshot() => _read();

  Future<Map<String, dynamic>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{'facts': <dynamic>[]};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {}
    return <String, dynamic>{'facts': <dynamic>[]};
  }

  Future<void> _write(Map<String, dynamic> value) =>
      _storage.write(key: _key, value: jsonEncode(value));
}
