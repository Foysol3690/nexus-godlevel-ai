import 'dart:io';

import 'package:path/path.dart' as path;

class MayaOmegaVerificationService {
  const MayaOmegaVerificationService();

  Map<String, dynamic> verifyToolResult(Map<String, dynamic> result, {String expected = ''}) {
    final success = result['success'] == true;
    if (!success) return {'verified': false, 'confidence': 'unknown', 'reason': result['error']?.toString() ?? 'The tool reported failure.'};
    final explicitVerification = result['verified'];
    if (explicitVerification == false) return {'verified': false, 'confidence': 'uncertain', 'reason': 'The tool completed but reported failed verification.'};
    return {
      'verified': true,
      'confidence': explicitVerification == true ? 'confirmed' : 'supported',
      'reason': expected.trim().isEmpty ? 'The tool reported success.' : 'The tool reported success for: ${expected.trim()}',
    };
  }

  Future<Map<String, dynamic>> verifyFile(String absolutePath, {String? expectedContents}) async {
    try {
      final file = File(path.normalize(absolutePath));
      if (!await file.exists()) return {'verified': false, 'confidence': 'unknown', 'reason': 'File does not exist.'};
      final contents = await file.readAsString();
      final matches = expectedContents == null || contents == expectedContents;
      return {
        'verified': matches, 'confidence': matches ? 'confirmed' : 'conflicting',
        'bytes': contents.codeUnits.length,
        'reason': matches ? 'File exists and read-back matches.' : 'File exists but read-back differs from the expected contents.',
      };
    } catch (error) {
      return {'verified': false, 'confidence': 'unknown', 'reason': 'File verification failed: $error'};
    }
  }

  Map<String, dynamic> verifyTaskGraph(Map<String, dynamic>? graph) {
    if (graph == null) return {'verified': false, 'confidence': 'unknown', 'reason': 'No task graph is available.'};
    final nodes = graph['nodes'];
    if (nodes is! List || nodes.isEmpty) return {'verified': false, 'confidence': 'unknown', 'reason': 'Task graph has no nodes.'};
    final statuses = nodes.whereType<Map>().map((node) => node['status']?.toString() ?? 'unknown').toList();
    final failed = statuses.contains('failed');
    final pending = statuses.contains('pending') || statuses.contains('running');
    final complete = !failed && !pending && statuses.isNotEmpty;
    return {
      'verified': complete,
      'confidence': failed ? 'conflicting' : complete ? 'confirmed' : 'uncertain',
      'reason': failed ? 'At least one task stage failed.' : pending ? 'Task stages are still pending or running.' : 'All task stages completed.',
      'status': graph['status'],
    };
  }
}
