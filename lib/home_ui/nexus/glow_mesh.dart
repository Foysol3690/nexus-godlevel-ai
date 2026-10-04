import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

class GlowMesh {
  GlowMesh(this.maxVertices)
      : _positions = Float32List(maxVertices * 2),
        _colors = Int32List(maxVertices),
        _indices = Uint16List(maxVertices * 4);

  final int maxVertices;
  final Float32List _positions;
  final Int32List _colors;
  final Uint16List _indices;
  int _vertexCount = 0;
  int _indexCount = 0;

  static final ui.Paint _additive = ui.Paint()..blendMode = ui.BlendMode.plus;

  bool get isEmpty => _indexCount == 0;

  void reset() { _vertexCount = 0; _indexCount = 0; }

  void addStrand(Float32List xs, Float32List ys, Float32List halfWidths, Int32List colors, int count, {bool closed = false}) {
    if (count < 2) return;
    final needed = count * 3;
    if (_vertexCount + needed > maxVertices) return;
    final base = _vertexCount;

    for (var j = 0; j < count; j++) {
      final prev = j == 0 ? (closed ? count - 1 : 0) : j - 1;
      final next = j == count - 1 ? (closed ? 0 : count - 1) : j + 1;
      var tx = xs[next] - xs[prev]; var ty = ys[next] - ys[prev];
      final len = math.sqrt(tx * tx + ty * ty);
      if (len < 1e-4) { tx = 1; ty = 0; } else { tx /= len; ty /= len; }
      final nx = -ty * halfWidths[j]; final ny = tx * halfWidths[j];
      final x = xs[j]; final y = ys[j];
      final color = colors[j]; final edge = color & 0x00FFFFFF;
      final v = (base + j * 3) * 2;
      _positions[v] = x + nx; _positions[v + 1] = y + ny;
      _positions[v + 2] = x; _positions[v + 3] = y;
      _positions[v + 4] = x - nx; _positions[v + 5] = y - ny;
      final c = base + j * 3;
      _colors[c] = edge; _colors[c + 1] = color; _colors[c + 2] = edge;
    }
    _vertexCount += needed;

    final segments = closed ? count : count - 1;
    for (var j = 0; j < segments; j++) {
      final a = base + j * 3; final b = base + ((j + 1) % count) * 3;
      _push(a, a + 1, b); _push(a + 1, b + 1, b);
      _push(a + 1, a + 2, b + 1); _push(a + 2, b + 2, b + 1);
    }
  }

  void _push(int a, int b, int c) {
    if (_indexCount + 3 > _indices.length) return;
    _indices[_indexCount++] = a; _indices[_indexCount++] = b; _indices[_indexCount++] = c;
  }

  void draw(ui.Canvas canvas) {
    if (isEmpty) return;
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      Float32List.sublistView(_positions, 0, _vertexCount * 2),
      colors: Int32List.sublistView(_colors, 0, _vertexCount),
      indices: Uint16List.sublistView(_indices, 0, _indexCount),
    );
    canvas.drawVertices(vertices, ui.BlendMode.dst, _additive);
    vertices.dispose();
  }
}

class StrandScratch {
  StrandScratch(int capacity)
      : xs = Float32List(capacity), ys = Float32List(capacity), zs = Float32List(capacity),
        widths = Float32List(capacity), colors = Int32List(capacity);
  final Float32List xs, ys, zs, widths;
  final Int32List colors;
}
