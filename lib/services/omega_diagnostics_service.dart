import 'omega_runtime_service.dart';

class MayaOmegaDiagnosticsService {
  MayaOmegaDiagnosticsService({required this.runtime});

  final MayaOmegaRuntime runtime;

  Future<Map<String, dynamic>> snapshot() async {
    final runtimeStatus = await runtime.status();
    final capabilities = runtimeStatus['capabilities'] as List? ?? const [];
    final ready = capabilities
        .where((item) => item is Map && item['state'] == 'ready')
        .length;
    final staged = capabilities.length - ready;
    return {
      'success': true,
      'runtime': runtimeStatus,
      'health': {
        'capabilitiesReady': ready,
        'capabilitiesStaged': staged,
        'eventCount':
            (runtimeStatus['persistedEvents'] as List? ?? const []).length,
        'agentMessageCount':
            (runtimeStatus['agentMessages'] as List? ?? const []).length,
        'taskActive': runtimeStatus['activeTaskId'] != null,
        'guardianHalted': runtimeStatus['halted'] == true,
      },
      'limitations': [
        'PC execution, encrypted Mesh transport, and external provider sync require their adapters.',
        'YOLO/CLIP/OCR, gaze estimation, generative video, and live-wallpaper rendering require tested model/provider adapters.',
        'Screen vision uses visible Android MediaProjection consent and cannot capture protected secure surfaces.',
        'Flutter/Dart build verification must run in a Flutter environment.',
      ],
    };
  }
}
