import 'package:flutter/material.dart';

import 'audio_visual_state.dart';
import 'energy_conduit.dart';
import 'energy_ribbons.dart';
import 'nexus_glass_layer.dart';
import 'nexus_layout.dart';
import 'orb_energy_field.dart';
import 'particle_field.dart';

class NexusOrb extends StatelessWidget {
  const NexusOrb({
    super.key, required this.state, required this.layout,
    required this.ribbons, required this.particles,
    required this.repaint, required this.qualityTier,
  });

  final AudioVisualState state;
  final NexusLayout layout;
  final RibbonField ribbons;
  final ParticleField particles;
  final Listenable repaint;
  final ValueNotifier<int> qualityTier;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: EnergyConduitPainter(state: state, layout: layout, repaint: repaint),
            foregroundPainter: EnergyRibbonsPainter(field: ribbons, state: state, layout: layout, layer: NexusDepthLayer.back, repaint: repaint),
          ),
          CustomPaint(
            painter: ParticleFieldPainter(field: particles, state: state, layout: layout, layer: NexusDepthLayer.back, repaint: repaint),
          ),
          Positioned.fromRect(
            rect: layout.sphereRect,
            child: NexusGlass(circle: true, blur: 4.5, surface: false, qualityTier: qualityTier),
          ),
          CustomPaint(
            painter: OrbEnergyFieldPainter(state: state, layout: layout, repaint: repaint),
            foregroundPainter: EnergyRibbonsPainter(field: ribbons, state: state, layout: layout, layer: NexusDepthLayer.front, repaint: repaint),
          ),
          CustomPaint(
            painter: ParticleFieldPainter(field: particles, state: state, layout: layout, layer: NexusDepthLayer.front, repaint: repaint),
          ),
        ],
      ),
    );
  }
}
