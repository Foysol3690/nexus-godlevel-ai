import 'dart:async';

import 'package:flutter/foundation.dart';

import 'audio_visual_state.dart';

/// Maps the assistant's existing state strings onto visual phases.
class NexusStateController extends ChangeNotifier {
  NexusStateController({
    String initialState = 'idle',
    this.thinkingAfter = const Duration(milliseconds: 1400),
  }) : _phase = _map(initialState) {
    _armThinking();
  }

  final Duration thinkingAfter;
  NexusPhase _phase;
  Timer? _thinkingTimer;

  NexusPhase get phase => _phase;
  bool get isActive => _phase != NexusPhase.idle;

  void update(String assistantState) {
    final next = _map(assistantState);
    if (next == _phase ||
        (next == NexusPhase.processing && _phase == NexusPhase.thinking)) {
      return;
    }
    _phase = next;
    _armThinking();
    notifyListeners();
  }

  void _armThinking() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
    if (_phase != NexusPhase.processing) return;
    _thinkingTimer = Timer(thinkingAfter, () {
      if (_phase != NexusPhase.processing) return;
      _phase = NexusPhase.thinking;
      notifyListeners();
    });
  }

  static NexusPhase _map(String state) => switch (state) {
        'listening' => NexusPhase.listening,
        'processing' || 'connecting' => NexusPhase.processing,
        'thinking' => NexusPhase.thinking,
        'speaking' => NexusPhase.speaking,
        _ => NexusPhase.idle,
      };

  static String titleFor(NexusPhase phase) => switch (phase) {
        NexusPhase.idle => 'NEXUS READY',
        NexusPhase.listening => 'LISTENING',
        NexusPhase.processing => 'PROCESSING',
        NexusPhase.thinking => 'THINKING',
        NexusPhase.speaking => 'SPEAKING',
      };

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    super.dispose();
  }
}
