import 'omega_persistence_service.dart';

class MayaOmegaAgentMessage {
  final String taskId;
  final String agentId;
  final String objective;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final String confidence;
  final List<Map<String, dynamic>> evidence;
  final List<String> errors;
  final List<String> artifacts;
  final DateTime timestamp;

  const MayaOmegaAgentMessage({
    required this.taskId, required this.agentId, required this.objective,
    required this.inputs, required this.outputs, required this.confidence,
    required this.evidence, required this.errors, required this.artifacts,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': '${taskId}_${agentId}_${timestamp.microsecondsSinceEpoch}',
        'taskId': taskId, 'agentId': agentId, 'objective': objective,
        'inputs': _redact(inputs), 'outputs': _redact(outputs),
        'confidence': confidence, 'evidence': evidence.map(_redact).toList(),
        'errors': errors, 'artifacts': artifacts,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  static Map<String, dynamic> _redact(Map<dynamic, dynamic> value) {
    final output = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      output[key] = lower.contains('token') || lower.contains('secret') ||
              lower.contains('password') || lower.contains('api_key')
          ? '[REDACTED]'
          : entry.value;
    }
    return output;
  }
}

class MayaOmegaAgentProtocolService {
  MayaOmegaAgentProtocolService({MayaOmegaPersistenceService? persistence})
      : persistence = persistence ?? MayaOmegaPersistenceService.instance;

  final MayaOmegaPersistenceService persistence;

  Future<Map<String, dynamic>> send(MayaOmegaAgentMessage message) async {
    final payload = message.toJson();
    await persistence.recordAgentMessage(payload);
    return {
      'success': true,
      'messageId': payload['id'],
      'taskId': message.taskId,
      'agentId': message.agentId,
    };
  }

  Future<List<Map<String, dynamic>>> history({int limit = 50}) =>
      persistence.recentAgentMessages(limit: limit);
}
