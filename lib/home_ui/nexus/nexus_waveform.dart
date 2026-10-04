import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'audio_visual_state.dart';
import 'glow_mesh.dart';
import 'nexus_layout.dart';
import 'nexus_palette.dart';
import 'visual_state_controller.dart';

class WaveformField implements NexusSimulation {
  final List<double> phases = List<double>.filled(3, 0);
  final List<double> trails = List<double>.filled(2, 0);

  @override
  void step(double dt, AudioVisualState s) {
    final drive = 1 + s.amplitude * 2.4;
    phases[0] += dt * (1.1 + s.bass * 1.6) * drive;
    phases[1] -= dt * (1.9 + s.mid * 2.2) * drive;
    phases[2] += dt * (3.2 + s.treble * 3.5) * drive;
    trails[0] += (s.waveEnergy - trails[0]) * (1 - math.exp(-dt * 5));
    trails[1] += (s.waveEnergy - trails[1]) * (1 - math.exp(-dt * 2.2));
  }
}

class NexusWaveformPainter extends CustomPainter {
  NexusWaveformPainter({
    required this.field, required this.state, required this.layout, required Listenable repaint,
  }) : super(repaint: repaint);

  final WaveformField field;
  final AudioVisualState state;
  final NexusLayout layout;

  static const int _maxSamples = 96;
  static final GlowMesh _mesh = GlowMesh(_maxSamples * 3 * 16);
  static final StrandScratch _scratch = StrandScratch(_maxSamples);

  @override
  void paint(Canvas canvas, Size size) {
    final s = state;
    final rect = layout.waveRect;
    final cx = layout.micCenter.dx; final cy = rect.center.dy;
    final w = rect.width; final halfH = rect.height / 2;
    final micR = layout.micRadius;
    final n = s.qualityTier == 0 ? 56 : _maxSamples;
    final energy = s.waveEnergy.clamp(0.0, 1.2);
    final xs = _scratch.xs; final ys = _scratch.ys; final ws = _scratch.widths; final cs = _scratch.colors;
    _mesh.reset();

    for (var i = 0; i < n; i++) {
      final x = rect.left + w * i / (n - 1);
      final env = math.exp(-math.pow((x - cx) / (w * .42), 2));
      xs[i] = x; ys[i] = cy;
      ws[i] = 1.2 + energy * 1.6;
      cs[i] = NexusPalette.spectral(s.tint(.05 + .9 * i / (n - 1)), env * (.05 + energy * .12 + s.micFocus * .03));
    }
    _mesh.addStrand(xs, ys, ws, cs, n);

    final bands = s.qualityTier == 0 ? 2 : 3;
    for (var band = 0; band < bands; band++) {
      final bandLevel = switch (band) { 0 => .55 + .45 * s.bass, 1 => .45 + .55 * s.mid, _ => .35 + .65 * s.treble };
      final heightScale = switch (band) { 0 => 1.0, 1 => .72, _ => .42 };
      final frequency = switch (band) { 0 => 1.8, 1 => 3.2, _ => 6.5 };
      final passes = s.qualityTier == 0 || band == 2 ? 1 : 3;
      for (var pass = 0; pass < passes; pass++) {
        final level = pass == 0 ? energy : field.trails[pass - 1];
        final passAlpha = pass == 0 ? 1.0 : (pass == 1 ? .38 : .2);
        final lag = pass * .35;
        final amp = halfH * heightScale * (.06 + level * bandLevel * .94);
        for (final mirror in const [1.0, -1.0]) {
          for (var i = 0; i < n; i++) {
            final u = i / (n - 1);
            final x = rect.left + w * u;
            final d = (x - cx) / (w * .5);
            final env = math.exp(-d * d * 2.6) * smoothstep(micR * .9, micR * 1.75, (x - cx).abs());
            final k = d * frequency * math.pi;
            final wave = math.sin(k + field.phases[band] - lag) * .65 + math.sin(k * 2.17 - field.phases[band] * 1.31 + band) * .35;
            xs[i] = x; ys[i] = cy - mirror * amp * env * wave;
            final alpha = env * passAlpha * (mirror > 0 ? 1 : .55) * (.3 + level * .8 + s.micFocus * .1) * (band == 2 ? .85 : 1);
            cs[i] = NexusPalette.spectral(s.tint(.03 + .95 * u), alpha);
            ws[i] = (band == 2 ? 1.3 : 2.4 + level * 3.4) * (pass == 0 ? 1 : .8);
          }
          _mesh.addStrand(xs, ys, ws, cs, n);
        }
      }
    }
    _mesh.draw(canvas);
  }

  @override
  bool shouldRepaint(NexusWaveformPainter old) => old.layout != layout;
}
