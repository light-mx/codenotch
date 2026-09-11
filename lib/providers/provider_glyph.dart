import 'package:flutter/material.dart';
import '../design_system/design.dart';
import '../design_system/palette.dart';
import 'glyph_outline.dart';

/// Which mark a provider cell draws.
enum ProviderGlyph {
  claude('claude'),
  openai('openai'),
  third('third'),
  cursor('cursor'),
  antigravity('gemini'),
  glm('glm'),
  grok('grok'),
  opencode('opencode');

  final String rawValue;
  const ProviderGlyph(this.rawValue);

  String get assetName => 'glyph-$rawValue';

  /// How much to scale this mark so it reads the same size as the others.
  double get opticalScale {
    switch (this) {
      case ProviderGlyph.claude:
        return 0.97;
      case ProviderGlyph.cursor:
        return 0.97;
      case ProviderGlyph.openai:
        return 0.94;
      case ProviderGlyph.antigravity:
        return 1.0;
      case ProviderGlyph.glm:
        return 0.95;
      case ProviderGlyph.grok:
        return 1.0;
      case ProviderGlyph.opencode:
        return 0.95;
      case ProviderGlyph.third:
        return 1.0;
    }
  }

  List<List<Offset>> get outline {
    switch (this) {
      case ProviderGlyph.claude:
        return GlyphOutline.claude;
      case ProviderGlyph.openai:
        return GlyphOutline.openai;
      case ProviderGlyph.third:
        return GlyphOutline.third;
      case ProviderGlyph.cursor:
        return GlyphOutline.cursor;
      case ProviderGlyph.antigravity:
        return GlyphOutline.antigravity;
      case ProviderGlyph.glm:
        return GlyphOutline.glm;
      case ProviderGlyph.grok:
        return GlyphOutline.grok;
      case ProviderGlyph.opencode:
        return GlyphOutline.opencode;
    }
  }
}

class GlyphShapePainter extends CustomPainter {
  final List<List<Offset>> outline;
  final Color color;

  const GlyphShapePainter({
    required this.outline,
    this.color = Palette.textPrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()..fillType = PathFillType.evenOdd;
    for (final loop in outline) {
      if (loop.isEmpty) continue;
      path.moveTo(loop.first.dx * size.width, loop.first.dy * size.height);
      for (int i = 1; i < loop.length; i++) {
        path.lineTo(loop[i].dx * size.width, loop[i].dy * size.height);
      }
      path.close();
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GlyphShapePainter oldDelegate) =>
      oldDelegate.outline != outline || oldDelegate.color != color;
}

class ProviderGlyphView extends StatelessWidget {
  final ProviderGlyph glyph;
  final double? size;
  final Color color;

  const ProviderGlyphView({
    super.key,
    required this.glyph,
    this.size,
    this.color = Palette.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? Design.px(46);
    return SizedBox(
      width: s,
      height: s,
      child: Center(
        child: Transform.scale(
          scale: glyph.opticalScale,
          child: CustomPaint(
            size: Size(s, s),
            painter: GlyphShapePainter(outline: glyph.outline, color: color),
          ),
        ),
      ),
    );
  }
}
