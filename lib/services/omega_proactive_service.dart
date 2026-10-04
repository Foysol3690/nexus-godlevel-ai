import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaProactiveService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_user_model_v1';

  Future<void> recordFocus(String focus) async {
    final model = await _read();
    final clean = focus.trim();
    if (clean.isEmpty) return;
    model['currentFocus'] = clean;
    model['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _write(model);
  }

  Future<void> recordInteractionPreference(String preference) async {
    final model = await _read();
    final clean = preference.trim();
    if (clean.isEmpty) return;
    model['interactionPreference'] = clean;
    model['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await _write(model);
  }

  Future<Map<String, dynamic>> suggestions({
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> recentEvents,
  }) async {
    final model = await _read();
    final suggestions = <Map<String, dynamic>>[];
    for (final goal in goals.take(5)) {
      if (goal['status']?.toString() == 'active') {
        suggestions.add({'type': 'goal', 'priority': goal['priority']?.toString() ?? 'normal',
            'message': 'Review or advance goal: ${goal['title'] ?? 'Untitled goal'}',
            'requiresConfirmation': false});
      }
    }
    final failures = recentEvents.where((e) => e['kind']?.toString().contains('Failed') == true);
    if (failures.isNotEmpty) {
      suggestions.add({'type': 'recovery', 'message': 'Review the latest failed task before retrying.', 'requiresConfirmation': false});
    }
    if (model['currentFocus'] != null) {
      suggestions.add({'type': 'focus', 'message': 'Current focus: ${model['currentFocus']}', 'requiresConfirmation': false});
    }
    return {'success': true, 'suggestions': suggestions,
        'policy': 'Suggestions only. No sensitive action is executed automatically.', 'userModel': model};
  }

  Future<Map<String, dynamic>> snapshot() => _read();

  Future<Map<String, dynamic>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _write(Map<String, dynamic> model) =>
      _storage.write(key: _key, value: jsonEncode(model));
}
