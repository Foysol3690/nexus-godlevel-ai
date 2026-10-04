import 'dart:math' as math;
import 'dart:ui';

class ArtSpec {
  static const orbSize = Size(880, 1170);
  static const orbCore = Offset(440, 505);
  static const tail = [
    Offset(470, 950), Offset(496, 995), Offset(504, 1045),
    Offset(494, 1088), Offset(462, 1125),
  ];
  static const wavesSize = Size(880, 290);
  static const micCenter = Offset(436, 160);
  static const micRadius = 92.0;
}

class HomeGeometry {
  HomeGeometry._({
    required this.orbRect, required this.dockRect,
    required this.orbScale, required this.dockScale,
  });

  factory HomeGeometry.resolve(Size area) {
    final w = area.width; final h = area.height;
    final dockScale = math.min(
      w / ArtSpec.wavesSize.width,
      (h * 0.26) / ArtSpec.wavesSize.height,
    );
    final dockW = ArtSpec.wavesSize.width * dockScale;
    final dockH = ArtSpec.wavesSize.height * dockScale;
    final bottomPad = (h * 0.02).clamp(4.0, 20.0);
    final dockRect = Rect.fromLTWH(
      (w - dockW) / 2, h - dockH - bottomPad, dockW, dockH,
    );
    final gap = (h * 0.06).clamp(20.0, 72.0);
    final orbAreaH = math.max(0.0, dockRect.top - gap + ArtSpec.micRadius * dockScale * 0.2);
    final orbScale = math.min(w / ArtSpec.orbSize.width, orbAreaH / ArtSpec.orbSize.height);
    final orbW = ArtSpec.orbSize.width * orbScale;
    final orbH = ArtSpec.orbSize.height * orbScale;
    final orbRect = Rect.fromLTWH((w - orbW) / 2, orbAreaH - orbH, orbW, orbH);
    return HomeGeometry._(orbRect: orbRect, dockRect: dockRect, orbScale: orbScale, dockScale: dockScale);
  }

  final Rect orbRect; final Rect dockRect;
  final double orbScale; final double dockScale;

  Offset orbPoint(Offset art, {double lift = 0}) =>
      orbRect.topLeft + art * orbScale - Offset(0, lift);
  Offset get micCenter => dockRect.topLeft + ArtSpec.micCenter * dockScale;
  double get micRadius => ArtSpec.micRadius * dockScale;
  Offset get micTop => micCenter - Offset(0, micRadius * 0.92);
}
