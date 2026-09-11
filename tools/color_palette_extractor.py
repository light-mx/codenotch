#!/usr/bin/env python3
"""
color_palette_extractor.py

Extracts color definitions from Swift source code (Color(hex:), Color(red:green:blue:),
NSColor) and converts them into CSS variables, Dart color constants, or C# classes.
"""

import sys
import os
import re
import argparse

HEX_PATTERN = re.compile(r'(?:static\s+(?:let|var)|let|var)\s+(\w+)\s*=\s*(?:Color|NSColor)\(hex:\s*"#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})"\)')
RGB_PATTERN = re.compile(r'(?:static\s+(?:let|var)|let|var)\s+(\w+)\s*=\s*(?:Color|NSColor)\(red:\s*([\d\.]+),\s*green:\s*([\d\.]+),\s*blue:\s*([\d\.]+)(?:,\s*opacity:\s*([\d\.]+))?\)')

def to_kebab_case(name: str) -> str:
    s1 = re.sub(r'(.)([A-Z][a-z]+)', r'\1-\2', name)
    return re.sub(r'([a-z0-9])([A-Z])', r'\1-\2', s1).lower()

def parse_colors(swift_content: str):
    colors = {}
    for name, hex_val in HEX_PATTERN.findall(swift_content):
        colors[name] = {
            "hex": f"#{hex_val.upper()}",
            "r": int(hex_val[0:2], 16),
            "g": int(hex_val[2:4], 16),
            "b": int(hex_val[4:6], 16),
            "a": int(hex_val[6:8], 16) / 255.0 if len(hex_val) == 8 else 1.0
        }
    for match in RGB_PATTERN.finditer(swift_content):
        name, r, g, b, opacity = match.groups()
        r_int = int(float(r) * 255)
        g_int = int(float(g) * 255)
        b_int = int(float(b) * 255)
        a_float = float(opacity) if opacity else 1.0
        hex_val = f"#{r_int:02X}{g_int:02X}{b_int:02X}"
        colors[name] = {
            "hex": hex_val,
            "r": r_int,
            "g": g_int,
            "b": b_int,
            "a": a_float
        }
    return colors

def format_css(colors):
    lines = [":root {"]
    for name, data in colors.items():
        kebab = to_kebab_case(name)
        lines.append(f"  --color-{kebab}: {data['hex']};")
    lines.append("}\n")
    return "\n".join(lines)

def format_dart(colors, class_name="AppColors"):
    lines = [
        "import 'package:flutter/material.dart';",
        "",
        f"class {class_name} {{",
        f"  const {class_name}._();",
        ""
    ]
    for name, data in colors.items():
        alpha_hex = f"{int(data['a'] * 255):02X}"
        hex_no_hash = data['hex'].replace("#", "")
        lines.append(f"  static const Color {name} = Color(0x{alpha_hex}{hex_no_hash});")
    lines.append("}\n")
    return "\n".join(lines)

def format_csharp(colors, class_name="AppColors"):
    lines = [
        "namespace App.Design;",
        "",
        f"public static class {class_name}",
        "{",
    ]
    for name, data in colors.items():
        pascal = name[0].upper() + name[1:]
        lines.append(f'    public const string {pascal} = "{data["hex"]}";')
    lines.append("}\n")
    return "\n".join(lines)

def main():
    parser = argparse.ArgumentParser(description="Extract Swift colors into CSS, Dart, or C#")
    parser.add_argument("swift_file", help="Path to Swift file containing Color definitions")
    parser.add_argument("--format", choices=["css", "dart", "csharp", "json"], default="css", help="Output format")
    parser.add_argument("--output", "-o", help="Optional output file path")
    args = parser.parse_args()

    with open(args.swift_file, "r", encoding="utf-8") as f:
        content = f.read()

    colors = parse_colors(content)
    if not colors:
        print(f"No color definitions found in {args.swift_file}", file=sys.stderr)
        return

    if args.format == "css":
        out = format_css(colors)
    elif args.format == "dart":
        out = format_dart(colors)
    elif args.format == "csharp":
        out = format_csharp(colors)
    elif args.format == "json":
        import json
        out = json.dumps(colors, indent=2)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"Wrote {len(colors)} colors to {args.output}")
    else:
        print(out)

if __name__ == "__main__":
    main()
