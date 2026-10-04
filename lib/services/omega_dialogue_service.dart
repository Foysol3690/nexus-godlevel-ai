import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MayaOmegaDialogueService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'maya_omega_dialogue_state_v1';

  Future<Map<String, dynamic>> recordTurn({
    required String userText, String assistantText = '', String persona = 'maya',
  }) async {
    final state = await _read();
    final cleanUser = userText.trim();
    final cleanAssistant = assistantText.trim();
    final topics = _topics(cleanUser);
    state['turnCount'] = ((state['turnCount'] as num?)?.toInt() ?? 0) + 1;
    state['lastUserText'] = cleanUser;
    if (cleanAssistant.isNotEmpty) state['lastAssistantText'] = cleanAssistant;
    state['persona'] = persona;
    state['topics'] = topics;
    state['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    await _write(state);
    return state;
  }

  Future<String> context() async {
    final state = await _read();
    final topics = (state['topics'] as List? ?? const []).join(', ');
    final lastUser = state['lastUserText']?.toString() ?? '';
    final lastAssistant = state['lastAssistantText']?.toString() ?? '';
    if (topics.isEmpty && lastUser.isEmpty) return '';
    return [
      'Dialogue state:',
      if (topics.isNotEmpty) 'Active topics: $topics',
      if (lastUser.isNotEmpty) 'Last user turn: $lastUser',
      if (lastAssistant.isNotEmpty) 'Last assistant turn: $lastAssistant',
      'Resolve short references using this state, but ask when ambiguity remains.',
    ].join('\n');
  }

  Future<Map<String, dynamic>> snapshot() => _read();
  Future<void> clear() => _storage.delete(key: _key);

  static List<String> _topics(String text) {
    final stop = {'this','that','with','from','what','when','where','please','could','would','should','about'};
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3 && !stop.contains(word))
        .toSet().take(8).toList();
  }

  Future<Map<String, dynamic>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _write(Map<String, dynamic> value) =>
      _storage.write(key: _key, value: jsonEncode(value));
}
