import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

abstract final class NexusPalette {
  static const ink = Color(0xFF02050D);
  static const deepNavy = Color(0xFF050B1C);
  static const cyan = Color(0xFF2DEBFF);
  static const blue = Color(0xFF3D7BFF);
  static const violet = Color(0xFF8B6BFF);
  static const magenta = Color(0xFFD94BFF);
  static const pink = Color(0xFFFF4F9A);
  static const orange = Color(0xFFFF944D);
  static const text = Color(0xFFE9ECFF);

  static const spectrum = <Color>[cyan, blue, violet, magenta, pink, orange];

  static final Int32List _lut = _buildLut();

  static Int32List _buildLut() {
    final lut = Int32List(256);
    final last = spectrum.length - 1;
    for (var i = 0; i < 256; i++) {
      final u = i / 255 * last;
      final index = u.floor().clamp(0, last - 1);
      final color = Color.lerp(spectrum[index], spectrum[index + 1], u - index)!;
      lut[i] = color.toARGB32() & 0x00FFFFFF;
    }
    return lut;
  }

  static int spectral(double u, double alpha) {
    final i = (u.clamp(0.0, 1.0) * 255).round();
    final a = (alpha.clamp(0.0, 1.0) * 255).round();
    return (a << 24) | _lut[i];
  }

  static Color spectralColor(double u, [double alpha = 1]) =>
      Color(spectral(u, alpha));

  static double angleToSpectrum(double angle) =>
      .03 + .95 * (.5 + .5 * math.cos(angle)) - .06 * math.sin(angle);
}

double flowNoise(double x, double t) =>
    math.sin(x * 1.7 + t * .91) * .5 +
    math.sin(x * 2.93 - t * 1.37 + 1.1) * .3 +
    math.sin(x * 5.31 + t * 2.13 + 2.3) * .2;

double smoothstep(double edge0, double edge1, double x) {
  final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

double mix(double a, double b, double t) => a + (b - a) * t;
