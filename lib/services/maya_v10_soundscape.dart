import 'package:audioplayers/audioplayers.dart';

/// Short local-only sonic feedback layer for the v10 HUD.
class MayaV10Soundscape {
  final AudioPlayer _player = AudioPlayer();
  String? _lastState;
  DateTime _lastPlayed = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> playState(String state) async {
    final normalized = switch (state) {
      'listening' => 'listen',
      'processing' || 'connecting' => 'process',
      'speaking' => 'speak',
      _ => 'idle',
    };
    final now = DateTime.now();
    if (normalized == _lastState &&
        now.difference(_lastPlayed) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastState = normalized;
    _lastPlayed = now;
    if (normalized == 'idle') return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(.34);
      await _player.play(AssetSource('audio/maya_v10_$normalized.wav'));
    } catch (_) {
      // Feedback is decorative. Never block or fail the assistant.
    }
  }

  Future<void> dispose() => _player.dispose();
}
