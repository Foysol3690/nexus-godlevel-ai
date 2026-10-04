import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'omega_consolidation_service.dart';

class MayaOmegaMaintenanceService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_maintenance_v1';

  MayaOmegaMaintenanceService({MayaOmegaConsolidationService? consolidation})
      : consolidation = consolidation ?? MayaOmegaConsolidationService();

  final MayaOmegaConsolidationService consolidation;

  Future<Map<String, dynamic>> status() async {
    final state = await _read();
    final lastRun = DateTime.tryParse(state['lastRun']?.toString() ?? '');
    final due = lastRun == null ||
        DateTime.now().toUtc().difference(lastRun) >= const Duration(hours: 24);
    return {
      'success': true,
      'due': due,
      'lastRun': state['lastRun'],
      'lastResult': state['lastResult'],
      'policy': 'Run only during charging or explicit owner request.',
    };
  }

  Future<Map<String, dynamic>> run({required bool charging}) async {
    if (!charging) {
      return {
        'success': false,
        'chargingRequired': true,
        'message':
            'Maintenance deferred until charging or explicit owner request.',
      };
    }
    final result = await consolidation.run(charging: true);
    final state = {
      'lastRun': DateTime.now().toUtc().toIso8601String(),
      'lastResult': result,
    };
    await _storage.write(key: _key, value: jsonEncode(state));
    return result;
  }

  Future<Map<String, dynamic>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }
}
