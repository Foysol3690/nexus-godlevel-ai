import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController = StreamController.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool isOnline = true;

  Stream<bool> get onStatusChange => _statusController.stream;

  Future<void> init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _update(result);
      _subscription ??= _connectivity.onConnectivityChanged.listen(
        _update,
        onError: (_) {},
      );
    } catch (e) {
      isOnline = true;
    }
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
    if (online == isOnline) return;
    isOnline = online;
    if (!_statusController.isClosed) _statusController.add(online);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    try {
      _statusController.close();
    } catch (_) {}
  }
}
