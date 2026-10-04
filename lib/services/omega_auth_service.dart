import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider connection-state hooks. Secret values are never accepted here;
/// actual OAuth/API-key entry remains in the secure provider setup flow.
class MayaOmegaAuthService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_provider_connections_v1';

  Future<Map<String, dynamic>> markConnected({
    required String provider,
    required String accountLabel,
  }) async {
    final clean = provider.trim();
    if (clean.isEmpty)
      return {'success': false, 'error': 'Provider is required.'};
    final connections = await _read();
    final record = {
      'provider': clean,
      'accountLabel': accountLabel.trim(),
      'status': 'connected',
      'connectedAt': DateTime.now().toUtc().toIso8601String(),
      'secretsStored': 'secure_provider_store',
    };
    connections[clean] = record;
    await _write(connections);
    return {'success': true, 'connection': record};
  }

  Future<Map<String, dynamic>> disconnect(String provider) async {
    final connections = await _read();
    connections.remove(provider.trim());
    await _write(connections);
    return {
      'success': true,
      'provider': provider.trim(),
      'status': 'disconnected',
    };
  }

  Future<Map<String, dynamic>> status() async => {
        'success': true,
        'connections': await _read(),
      };

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

  Future<void> _write(Map<String, dynamic> value) =>
      _storage.write(key: _key, value: jsonEncode(value));
}
