import 'dart:math' as math;

import 'package:flutter/painting.dart';

class NexusLayout {
  const NexusLayout._({
    required this.size, required this.topBarTop, required this.topBarHeight,
    required this.orbCenter, required this.orbRadius, required this.sphereRadius,
    required this.micCenter, required this.micRadius, required this.waveRect,
    required this.textTop, required this.textBottom,
  });

  factory NexusLayout.compute(Size size, EdgeInsets padding) {
    final w = size.width;
    final topBarTop = padding.top + 10;
    const topBarHeight = 44.0;
    final stageTop = topBarTop + topBarHeight;
    final stageBottom = size.height - padding.bottom;
    final stageHeight = math.max(1.0, stageBottom - stageTop);

    final micRadius = (math.min(w, stageHeight) * .105).clamp(30.0, 46.0).toDouble();
    final bottomGap = math.max(14.0, stageHeight * .03);
    final micCenter = Offset(w / 2, stageBottom - bottomGap - micRadius * 1.25);
    final waveHalf = micRadius * 1.7;
    final waveRect = Rect.fromLTRB(0, micCenter.dy - waveHalf, w, micCenter.dy + waveHalf);

    const textBlock = 66.0;
    final textBottom = waveRect.top - 4;
    final textTop = textBottom - textBlock;

    final orbSpace = textTop - stageTop;
    final orbRadius = math.min(w * .335, orbSpace * .4).clamp(70.0, 190.0).toDouble();
    final orbCenterY = stageTop + math.max(orbRadius * 1.28, orbSpace * .47);

    return NexusLayout._(
      size: size, topBarTop: topBarTop, topBarHeight: topBarHeight,
      orbCenter: Offset(w / 2, orbCenterY), orbRadius: orbRadius,
      sphereRadius: orbRadius * .52, micCenter: micCenter,
      micRadius: micRadius, waveRect: waveRect, textTop: textTop, textBottom: textBottom,
    );
  }

  final Size size;
  final double topBarTop;
  final double topBarHeight;
  final Offset orbCenter;
  final double orbRadius;
  final double sphereRadius;
  final Offset micCenter;
  final double micRadius;
  final Rect waveRect;
  final double textTop;
  final double textBottom;

  Rect get sphereRect => Rect.fromCircle(center: orbCenter, radius: sphereRadius);

  @override
  bool operator ==(Object other) =>
      other is NexusLayout &&
      other.size == size &&
      other.orbCenter == orbCenter &&
      other.micCenter == micCenter;

  @override
  int get hashCode => Object.hash(size, orbCenter, micCenter);
}
