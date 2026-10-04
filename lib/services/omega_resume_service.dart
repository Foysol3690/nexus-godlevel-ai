import 'omega_architecture_service.dart';

class MayaOmegaResumeService {
  MayaOmegaResumeService({MayaOmegaArchitectureService? architecture})
      : architecture = architecture ?? MayaOmegaArchitectureService();

  final MayaOmegaArchitectureService architecture;

  Future<Map<String, dynamic>> snapshot() async {
    final graph = await architecture.activeTaskGraph();
    if (graph == null) {
      return {
        'success': true,
        'resumeAvailable': false,
        'message': 'No persisted task graph is available.',
      };
    }
    final status = graph['status']?.toString() ?? 'unknown';
    final nodes = graph['nodes'] as List? ?? const [];
    final completed = nodes
        .where((node) => node is Map && node['status'] == 'completed')
        .length;
    final pending = nodes
        .where(
          (node) =>
              node is Map &&
              (node['status'] == 'pending' || node['status'] == 'running'),
        )
        .length;
    return {
      'success': true,
      'resumeAvailable':
          status == 'running' || status == 'paused' || pending > 0,
      'taskId': graph['id'],
      'goal': graph['goal'],
      'status': status,
      'completedStages': completed,
      'pendingStages': pending,
      'policy':
          'Resume requires owner confirmation before executing pending stages.',
    };
  }
}
