import 'dart:ui' show Vertices;

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:blurhash_dart/blurhash_extensions.dart';
import 'package:flutter/material.dart';

class BlurHashBackground extends StatelessWidget {
  const BlurHashBackground({
    super.key,
    required this.blurHash,
    this.opacity = 1.0,
  });

  final String blurHash;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BlurHashPainter(
          blurHash: blurHash,
          opacity: opacity,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// colors are sampled on a grid and interpolated by the GPU, so the hash is
// painted in the first frame without decoding an image
class _BlurHashPainter extends CustomPainter {
  _BlurHashPainter({
    required this.blurHash,
    required this.opacity,
  });

  final String blurHash;
  final double opacity;

  static const _columns = 12;
  static const _rows = 12;
  static final _indices = _buildIndices();

  late final List<Color> _colors = _buildColors();

  static List<int> _buildIndices() {
    final indices = <int>[];

    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _columns; x++) {
        final topLeft = y * (_columns + 1) + x;
        final bottomLeft = topLeft + _columns + 1;

        indices.addAll([topLeft, topLeft + 1, bottomLeft]);
        indices.addAll([topLeft + 1, bottomLeft + 1, bottomLeft]);
      }
    }

    return indices;
  }

  List<Color> _buildColors() {
    final hash = BlurHash.decode(blurHash);
    final alpha = (opacity * 255).round();
    final colors = <Color>[];

    for (var y = 0; y <= _rows; y++) {
      for (var x = 0; x <= _columns; x++) {
        final rgb = hash.linearRgbAt(x / _columns, y / _rows).toRgb();

        colors.add(
          Color.fromARGB(alpha, rgb.r.toInt(), rgb.g.toInt(), rgb.b.toInt()),
        );
      }
    }

    return colors;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final positions = <Offset>[];

    for (var y = 0; y <= _rows; y++) {
      for (var x = 0; x <= _columns; x++) {
        positions.add(
          Offset(x / _columns * size.width, y / _rows * size.height),
        );
      }
    }

    final vertices = Vertices(
      VertexMode.triangles,
      positions,
      colors: _colors,
      indices: _indices,
    );

    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
  }

  @override
  bool shouldRepaint(_BlurHashPainter oldDelegate) {
    return oldDelegate.blurHash != blurHash || oldDelegate.opacity != opacity;
  }
}
