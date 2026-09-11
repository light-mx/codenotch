#!/usr/bin/env python3
"""
swift_shape_to_flutter_painter.py

Assists in converting SwiftUI `Shape.path(in rect: CGRect) -> Path` implementations
into Flutter `CustomPainter` and `CustomClipper<Path>`.
"""

import sys
import re

def convert_swift_path_syntax(swift_code: str) -> str:
    """Translates common Swift Path commands to Dart Path commands."""
    lines = swift_code.splitlines()
    converted_lines = []

    for line in lines:
        # path.move(to: CGPoint(x: ..., y: ...)) -> path.moveTo(..., ...)
        m = re.sub(r'path\.move\(to:\s*CGPoint\(x:\s*([^,]+),\s*y:\s*([^\)]+)\)\)', r'path.moveTo(\1, \2)', line)
        # path.addLine(to: CGPoint(x: ..., y: ...)) -> path.lineTo(..., ...)
        m = re.sub(r'path\.addLine\(to:\s*CGPoint\(x:\s*([^,]+),\s*y:\s*([^\)]+)\)\)', r'path.lineTo(\1, \2)', m)
        # path.closeSubpath() -> path.close()
        m = re.sub(r'path\.closeSubpath\(\)', r'path.close()', m)
        # rect.minX, maxX, etc.
        m = m.replace('rect.minX', 'rect.left')
        m = m.replace('rect.maxX', 'rect.right')
        m = m.replace('rect.minY', 'rect.top')
        m = m.replace('rect.maxY', 'rect.bottom')
        m = m.replace('rect.midX', 'rect.center.dx')
        m = m.replace('rect.midY', 'rect.center.dy')
        m = m.replace('CGFloat', 'double')
        converted_lines.append(m)

    return "\n".join(converted_lines)

def generate_flutter_template(class_name: str, path_body: str) -> str:
    return f"""import 'dart:math' as math;
import 'package:flutter/material.dart';

class {class_name}Painter extends CustomPainter {{
  final Color color;

  const {class_name}Painter({{this.color = Colors.black}});

  Path getPath(Size size) {{
    final Rect rect = Offset.zero & size;
    final Path path = Path();
    
    // --- Ported Path Logic ---
{path_body}
    // -------------------------

    return path;
  }}

  @override
  void paint(Canvas canvas, Size size) {{
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(getPath(size), paint);
  }}

  @override
  bool shouldRepaint(covariant {class_name}Painter oldDelegate) =>
      oldDelegate.color != color;
}}

class {class_name}Clipper extends CustomClipper<Path> {{
  @override
  Path getClip(Size size) {{
    final Rect rect = Offset.zero & size;
    final Path path = Path();
{path_body}
    return path;
  }}

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}}
"""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: swift_shape_to_flutter_painter.py <ShapeName> [swift_snippet.txt]")
        sys.exit(0)

    name = sys.argv[1]
    input_text = ""
    if len(sys.argv) > 2:
        with open(sys.argv[2], "r") as f:
            input_text = f.read()
    else:
        input_text = sys.stdin.read() if not sys.stdin.isatty() else ""

    converted = convert_swift_path_syntax(input_text)
    print(generate_flutter_template(name, converted))
