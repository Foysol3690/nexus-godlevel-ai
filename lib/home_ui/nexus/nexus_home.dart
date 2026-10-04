import 'package:flutter/material.dart';

import 'audio_analyzer.dart';
import 'audio_visual_state.dart';
import 'energy_ribbons.dart';
import 'nexus_background.dart';
import 'nexus_layout.dart';
import 'nexus_microphone.dart';
import 'nexus_orb.dart';
import 'nexus_palette.dart';
import 'nexus_state_controller.dart';
import 'nexus_status.dart';
import 'nexus_waveform.dart';
import 'particle_field.dart';
import 'visual_state_controller.dart';

class NexusHome extends StatefulWidget {
  const NexusHome({super.key, required this.assistantState, required this.audioLevel, required this.statusText, required this.connected, required this.overlayActive, required this.onCoreTap, this.onStopTap, this.onListenTap, this.onProcessTap, this.onSpeakTap, required this.onGodModeTap, required this.onVisionTap, required this.onOverlayTap, this.analyzer});
  final String assistantState;
  final double audioLevel;
  final String statusText;
  final bool connected, overlayActive;
  final VoidCallback onCoreTap;
  final VoidCallback? onStopTap, onListenTap, onProcessTap, onSpeakTap;
  final VoidCallback onGodModeTap, onVisionTap, onOverlayTap;
  final NexusAudioAnalyzer? analyzer;
  @override State<NexusHome> createState() => _NexusHomeState();
}

class _NexusHomeState extends State<NexusHome> with SingleTickerProviderStateMixin {
  late final NexusStateController _phase = NexusStateController(initialState: widget.assistantState);
  late final VisualStateController _visual = VisualStateController(vsync: this, analyzer: widget.analyzer);
  final RibbonField _ribbons = RibbonField();
  final ParticleField _particles = ParticleField();
  final WaveformField _waveform = WaveformField();

  @override
  void initState() {
    super.initState();
    _visual..addSimulation(_ribbons)..addSimulation(_particles)..addSimulation(_waveform)..setPhase(_phase.phase)..fallbackLevel = widget.audioLevel..start();
    _phase.addListener(_onPhaseChanged);
  }

  void _onPhaseChanged() => _visual.setPhase(_phase.phase);

  @override
  void didUpdateWidget(NexusHome oldWidget) { super.didUpdateWidget(oldWidget); _phase.update(widget.assistantState); _visual.fallbackLevel = widget.audioLevel; }

  @override
  void dispose() { _phase..removeListener(_onPhaseChanged)..dispose(); _visual.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final AudioVisualState state = _visual.state;
    return Scaffold(
      backgroundColor: NexusPalette.ink,
      body: LayoutBuilder(
        builder: (context, box) {
          final layout = NexusLayout.compute(box.biggest, MediaQuery.paddingOf(context));
          final stageTop = layout.topBarTop + layout.topBarHeight;
          final micDiameter = layout.micRadius * 2;
          return Stack(
            children: [
              Positioned.fill(child: NexusBackground(state: state, layout: layout, repaint: _visual)),
              Positioned.fill(top: stageTop, child: ListenableBuilder(listenable: _phase, builder: (context, _) => Semantics(button: true, label: 'Maya core. ${NexusStateController.titleFor(_phase.phase)}. ${widget.statusText}. Tap to talk.', child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onCoreTap)))),
              Positioned.fill(child: NexusOrb(state: state, layout: layout, ribbons: _ribbons, particles: _particles, repaint: _visual, qualityTier: _visual.qualityTier)),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: NexusWaveformPainter(field: _waveform, state: state, layout: layout, repaint: _visual)))),
              Positioned(left: 28, right: 28, top: layout.textTop, height: layout.textBottom - layout.textTop, child: IgnorePointer(child: RepaintBoundary(child: NexusReadout(phase: _phase, statusText: widget.statusText)))),
              Positioned(left: layout.micCenter.dx - layout.micRadius, top: layout.micCenter.dy - layout.micRadius, width: micDiameter, height: micDiameter, child: ListenableBuilder(listenable: _phase, builder: (context, _) => NexusMicrophone(state: state, repaint: _visual, qualityTier: _visual.qualityTier, active: _phase.isActive, onTap: widget.onCoreTap))),
              Positioned(left: 16, right: 16, top: layout.topBarTop, height: layout.topBarHeight, child: RepaintBoundary(child: NexusStatusBar(phase: _phase, connected: widget.connected, overlayActive: widget.overlayActive, qualityTier: _visual.qualityTier, onOverlayTap: widget.onOverlayTap, onGodModeTap: widget.onGodModeTap, onVisionTap: widget.onVisionTap))),
            ],
          );
        },
      ),
    );
  }
}
