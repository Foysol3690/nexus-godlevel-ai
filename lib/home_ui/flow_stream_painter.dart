import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Strand {
  const _Strand(this.color, this.width, this.amp, this.freq, this.phase, this.speed);
  final Color color;
  final double width, amp, freq, phase, speed;
}

/// One continuous ribbon that starts on the orb's painted tail and pours
/// into the top of the mic ring, so the two artworks read as a single piece.
class FlowStreamPainter extends CustomPainter {
  FlowStreamPainter({required this.tail, required this.micTop, required this.micCenter, required this.micRadius, required this.t, required this.level, required this.active, required this.unit});

  final List<Offset> tail;
  final Offset micTop, micCenter;
  final double micRadius, t, level, unit;
  final bool active;

  static const _strands = [
    _Strand(Color(0xFF38BDF8), 2.6, 1.0, 2.2, 0.0, 2),
    _Strand(Color(0xFFA78BFA), 1.6, -0.8, 2.8, 1.3, 3),
    _Strand(Color(0xFFFB923C), 2.0, 0.65, 3.4, 2.4, 2),
    _Strand(Color(0xFF67E8F9), 1.1, -0.45, 1.8, 3.6, 4),
    _Strand(Color(0xFFF472B6), 0.9, 0.3, 4.0, 4.4, 3),
  ];

  Path _basePath() {
    final p = Path()..moveTo(tail.first.dx, tail.first.dy);
    for (var i = 1; i < tail.length; i++) {
      final prev = tail[i - 1], cur = tail[i];
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      p.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    final last = tail.last;
    final dir = last - tail[tail.length - 2];
    final dist = (micTop - last).distance;
    final c1 = last + dir / dir.distance * dist * 0.45;
    final c2 = micTop - Offset(0, dist * 0.55);
    p.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, micTop.dx, micTop.dy);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (tail.length < 2) return;
    final metric = _basePath().computeMetrics().first;
    final length = metric.length;
    const samples = 70;
    final phaseT = t * math.pi * 2;
    final energy = (active ? 0.55 : 0.25) + level * 0.75;
    final shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: const [Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
      stops: const [0, 0.28, 1],
    ).createShader(Rect.fromPoints(tail.first, micTop));
    for (final s in _strands) {
      final path = Path();
      for (var i = 0; i <= samples; i++) {
        final u = i / samples;
        final tan = metric.getTangentForOffset(length * u)!;
        final normal = Offset(-tan.vector.dy, tan.vector.dx);
        final envelope = math.sin(math.pi * u);
        final wobble = math.sin(u * s.freq * math.pi * 2 + s.phase + phaseT * s.speed);
        final offset = normal * (s.amp * envelope * wobble * unit * (5 + energy * 6));
        final pt = tan.position + offset;
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      final glow = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = s.width * unit * (2.6 + energy)..color = s.color.withValues(alpha: 0.35 + energy * 0.25)..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * unit);
      final core = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = s.width * unit..color = Color.lerp(s.color, Colors.white, 0.35)!;
      canvas.saveLayer(Offset.zero & size, Paint());
      canvas.drawPath(path, glow);
      canvas.drawPath(path, core);
      final strandMetric = path.computeMetrics().first;
      final dashLen = strandMetric.length * 0.12;
      final head = ((t * s.speed + s.phase / 6) % 1.0) * (strandMetric.length + dashLen);
      final dash = strandMetric.extractPath(math.max(0, head - dashLen), math.min(strandMetric.length, head));
      canvas.drawPath(dash, Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = s.width * unit * 1.3..color = Colors.white.withValues(alpha: 0.9)..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 * unit));
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader..blendMode = BlendMode.dstIn);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FlowStreamPainter old) => old.t != t || old.level != level || old.active != active || old.micTop != micTop || old.tail.first != tail.first;
}
