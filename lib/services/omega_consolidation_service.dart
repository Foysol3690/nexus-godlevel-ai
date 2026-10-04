import 'memory_service.dart';
import 'omega_architecture_service.dart';
import 'omega_graph_memory_service.dart';
import 'omega_persistence_service.dart';

class MayaOmegaConsolidationService {
  MayaOmegaConsolidationService({
    MemoryService? memory,
    MayaOmegaArchitectureService? architecture,
    MayaOmegaGraphMemoryService? graph,
    MayaOmegaPersistenceService? persistence,
  })  : memory = memory ?? MemoryService(),
        architecture = architecture ?? MayaOmegaArchitectureService(),
        graph = graph ?? MayaOmegaGraphMemoryService.instance,
        persistence = persistence ?? MayaOmegaPersistenceService.instance;

  final MemoryService memory;
  final MayaOmegaArchitectureService architecture;
  final MayaOmegaGraphMemoryService graph;
  final MayaOmegaPersistenceService persistence;

  Future<Map<String, dynamic>> run({bool charging = false}) async {
    final removedMemory = await memory.consolidate();
    final lessons = await architecture.lessons(limit: 100);
    final graphSnapshot = await graph.snapshot(limit: 200);
    final summary = {
      'success': true,
      'charging': charging,
      'removedDuplicateOrExpiredMemory': removedMemory,
      'recoveryLessonCount': lessons.length,
      'graphEntityCount':
          (graphSnapshot['entities'] as List? ?? const []).length,
      'graphEdgeCount': (graphSnapshot['edges'] as List? ?? const []).length,
      'policy':
          'Consolidation summarizes and cleans bounded state; it never rewrites proven behavior automatically.',
    };
    try {
      await persistence.recordEvent({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'kind': 'consolidation_completed',
        'at': DateTime.now().toUtc().toIso8601String(),
        'payload': summary,
      });
    } catch (_) {}
    return summary;
  }
}
