import 'dart:async';
import 'dart:typed_data';

import '../nexus_home/audio/feature_extractor.dart';
import '../nexus_home/core/audio_visual_state.dart';
import '../nexus_home/nexus_home.dart';

/// Stand-in for a real assistant so the screen can be exercised end to end
/// without an AI backend. It records the analysed features of what you say,
/// then "answers" by replaying that real envelope on the output channel, so
/// the SPEAKING state is still driven by genuine audio data.
///
/// Replace this with a bridge that calls your existing STT / AI / TTS.
class EchoDemoBridge extends NexusVoiceBridge {
  final List<Float32List> _recording = <Float32List>[];
  Timer? _sampler;
  Timer? _player;
  final List<Timer> _pending = <Timer>[];
  bool _heardSpeech = false;
  int _silentTicks = 0;

  static const Duration _tick = Duration(milliseconds: 33);

  @override
  Future<void> onListeningStarted() async {
    _cancelAll();
    _recording.clear();
    _heardSpeech = false;
    _silentTicks = 0;
    _sampler = Timer.periodic(_tick, (_) => _sample());
  }

  void _sample() {
    final input = controller.analyzer.input;
    final frame = Float32List(FeatureIndex.length)
      ..[FeatureIndex.level] = input.level
      ..[FeatureIndex.bass] = input.bass
      ..[FeatureIndex.mid] = input.mid
      ..[FeatureIndex.treble] = input.treble;
    frame.setRange(FeatureIndex.bands, FeatureIndex.bands + kNexusBandCount, input.bands);
    _recording.add(frame);

    if (input.level > 0.35) {
      _heardSpeech = true;
      _silentTicks = 0;
    } else if (_heardSpeech && input.level < 0.12) {
      _silentTicks++;
    }
    final endOfUtterance = _heardSpeech && _silentTicks * _tick.inMilliseconds > 1400;
    final tooLong = _recording.length * _tick.inMilliseconds > 15000;
    if (endOfUtterance || tooLong) controller.stopListening();
  }

  @override
  Future<void> onListeningStopped() async {
    _sampler?.cancel();
    _sampler = null;
    if (!_heardSpeech) {
      _later(const Duration(milliseconds: 900), controller.setIdle);
      return;
    }
    _later(const Duration(milliseconds: 750), controller.setThinking);
    _later(const Duration(milliseconds: 2300), _speak);
  }

  void _speak() {
    controller.beginSpeaking();
    var index = 0;
    _player = Timer.periodic(_tick, (timer) {
      if (index >= _recording.length) {
        timer.cancel();
        controller.endSpeaking();
        return;
      }
      controller.analyzer.output.applyFeatures(_recording[index++]);
    });
  }

  @override
  Future<void> onInterrupted() async => _cancelAll();

  void _later(Duration delay, void Function() action) => _pending.add(Timer(delay, action));

  void _cancelAll() {
    _sampler?.cancel();
    _player?.cancel();
    for (final t in _pending) {
      t.cancel();
    }
    _pending.clear();
  }

  @override
  void dispose() => _cancelAll();
}
