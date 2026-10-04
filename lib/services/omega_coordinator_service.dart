import 'omega_agent_protocol_service.dart';
import 'omega_architecture_service.dart';

typedef MayaOmegaAgentRunner = Future<Map<String, dynamic>> Function(String agentId, String objective);

class MayaOmegaCoordinatorService {
  MayaOmegaCoordinatorService({MayaOmegaArchitectureService? architecture, MayaOmegaAgentProtocolService? protocol})
      : architecture = architecture ?? MayaOmegaArchitectureService(),
        protocol = protocol ?? MayaOmegaAgentProtocolService();

  final MayaOmegaArchitectureService architecture;
  final MayaOmegaAgentProtocolService protocol;

  Future<Map<String, dynamic>> plan(String goal) async {
    final clean = goal.trim();
    if (clean.isEmpty) return {'success': false, 'error': 'Goal is empty.'};
    final taskId = DateTime.now().microsecondsSinceEpoch.toString();
    return {
      'success': true, 'taskId': taskId, 'goal': clean,
      'assignments': [
        {'agentId': 'maya_prime', 'objective': 'Resolve the user goal and constraints.'},
        {'agentId': 'planner', 'objective': 'Decompose the goal into safe dependencies.'},
        {'agentId': 'critic', 'objective': 'Inspect risk, ambiguity, and unsupported assumptions.'},
        {'agentId': 'verifier', 'objective': 'Define measurable completion and verification criteria.'},
      ],
      'policy': 'Agents propose bounded work; Guardian approval is required before sensitive execution.',
    };
  }

  Future<Map<String, dynamic>> run({
    required String taskId, required String goal, required MayaOmegaAgentRunner runner,
  }) async {
    final assignments = [('maya_prime','Resolve the user goal.'),('planner','Decompose into safe steps.'),('critic','Inspect risk.'),('verifier','Define completion criteria.')];
    final outputs = <Map<String, dynamic>>[];
    for (final (agentId, objective) in assignments) {
      Map<String, dynamic> result;
      try { result = await runner(agentId, '$objective\n\nGOAL:\n$goal'); }
      catch (error) { result = {'success': false, 'error': error.toString()}; }
      final success = result['success'] == true;
      await protocol.send(MayaOmegaAgentMessage(
        taskId: taskId, agentId: agentId, objective: objective, inputs: {'goal': goal},
        outputs: result, confidence: success ? 'supported' : 'unknown',
        evidence: const [], errors: success ? const [] : [result['error']?.toString() ?? 'failed'],
        artifacts: const [], timestamp: DateTime.now().toUtc(),
      ));
      outputs.add({'agentId': agentId, ...result});
      if (!success) return {'success': false, 'taskId': taskId, 'failedAgent': agentId, 'outputs': outputs};
    }
    return {'success': true, 'taskId': taskId, 'outputs': outputs};
  }
}
