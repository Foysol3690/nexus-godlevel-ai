import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaCalendarService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_calendar_events_v1';

  Future<Map<String, dynamic>> create({
    required String title, required String start, String? end, String notes = '',
  }) async {
    final clean = title.trim();
    if (clean.isEmpty || start.trim().isEmpty) return {'success': false, 'error': 'Event title and start are required.'};
    final events = await _read();
    final event = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(), 'title': clean,
      'start': start.trim(), 'end': end?.trim(), 'notes': notes.trim(),
      'status': 'scheduled', 'createdAt': DateTime.now().toUtc().toIso8601String(),
      'provider': 'maya_local_calendar',
    };
    events.insert(0, event);
    if (events.length > 200) events.removeRange(200, events.length);
    await _write(events);
    return {'success': true, 'event': event};
  }

  Future<Map<String, dynamic>> list({String? status}) async {
    final events = await _read();
    final filtered = status == null || status.trim().isEmpty
        ? events : events.where((e) => e['status'] == status.trim()).toList();
    return {'success': true, 'events': filtered};
  }

  Future<Map<String, dynamic>> cancel(String id) async {
    final events = await _read();
    final index = events.indexWhere((e) => e['id']?.toString() == id);
    if (index < 0) return {'success': false, 'error': 'Calendar event not found.'};
    events[index]['status'] = 'cancelled';
    events[index]['cancelledAt'] = DateTime.now().toUtc().toIso8601String();
    await _write(events);
    return {'success': true, 'event': events[index]};
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
