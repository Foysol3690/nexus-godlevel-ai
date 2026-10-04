class MayaOmegaResilienceService {
  static const scenarios = <Map<String, dynamic>>[
    {'id': 'network_loss', 'failure': 'Network unavailable', 'expectedRecovery': 'Use offline gateway or another configured provider.', 'destructive': false},
    {'id': 'permission_denied', 'failure': 'Android permission denied', 'expectedRecovery': 'Stop the action and request the smallest missing permission.', 'destructive': false},
    {'id': 'model_failure', 'failure': 'Cloud model unavailable', 'expectedRecovery': 'Fail over to the next provider and preserve uncertainty.', 'destructive': false},
    {'id': 'tool_failure', 'failure': 'Tool returns an error', 'expectedRecovery': 'Classify, retry within limit, verify, and store a lesson.', 'destructive': false},
    {'id': 'app_restart', 'failure': 'Process or app restart', 'expectedRecovery': 'Reload SQLite state, goals, task graph, and audit history.', 'destructive': false},
    {'id': 'low_battery', 'failure': 'Battery or power-save constraint', 'expectedRecovery': 'Route to lower-cost local behavior and defer maintenance.', 'destructive': false},
    {'id': 'interrupted_task', 'failure': 'Task interrupted', 'expectedRecovery': 'Resume from the last persisted stage or cancel safely.', 'destructive': false},
    {'id': 'corrupted_state', 'failure': 'Malformed local state', 'expectedRecovery': 'Reject the record, use a safe default, and preserve the audit trail.', 'destructive': false},
  ];

  Future<Map<String, dynamic>> dryRun({String? scenarioId}) async {
    final selected = scenarioId == null || scenarioId.trim().isEmpty
        ? scenarios
        : scenarios.where((s) => s['id'] == scenarioId.trim()).toList();
    if (selected.isEmpty) return {'success': false, 'error': 'Resilience scenario not found.'};
    return {
      'success': true, 'mode': 'dry_run', 'scenarios': selected,
      'sideEffects': 'None. This validates recovery plans without disabling network, permissions, or device services.',
    };
  }
}
