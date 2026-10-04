import 'dart:ui';

import 'nexus_palette.dart';

enum NexusPhase { idle, listening, processing, thinking, speaking }

class AudioVisualState {
  double time = 0;
  double amplitude = 0;
  double bass = 0;
  double mid = 0;
  double treble = 0;
  double orbEnergy = .06;
  double waveEnergy = .02;
  double particleEnergy = .05;
  double flowDirection = 0;
  double flowStrength = .05;
  double flowTravel = 0;
  double orbitPhase = 0;
  double inwardPull = 0;
  double ambience = .1;
  double micFocus = .35;
  double thinkPulse = 0;
  double spectrumFocus = 0;
  double spectrumCenter = .4;
  Color accent = NexusPalette.blue;
  final List<double> weights = List<double>.filled(NexusPhase.values.length, 0)
    ..[NexusPhase.idle.index] = 1;
  int qualityTier = 2;
  double weight(NexusPhase phase) => weights[phase.index];
  double tint(double u) => mix(u, spectrumCenter, spectrumFocus);
}
