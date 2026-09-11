#!/usr/bin/env python3
"""
analyze_swift_project.py

Analyzes a Swift codebase (SwiftUI, AppKit/UIKit, Combine, Swift Concurrency)
to generate a Flutter/Dart migration assessment report.
"""

import sys
import os
import re
from pathlib import Path
from collections import defaultdict

SWIFTUI_VIEWS = re.compile(r':\s*(?:View|Shape)\b')
COMBINE_PUBLISHERS = re.compile(r'@Published\b|\bAnyPublisher\b|\bCurrentValueSubject\b|\bPassthroughSubject\b')
APPKIT_PATTERNS = re.compile(r'\b(?:NSWindow|NSPanel|NSApplication|NSHostingView|NSMenu|NSStatusItem|NSScreen|NSEvent)\b')
STORAGE_PATTERNS = re.compile(r'\b(?:UserDefaults|Keychain|SQLite|sqlite3|FileManager)\b')
ACTOR_PATTERNS = re.compile(r'\b(?:actor\s+\w+|nonisolated|Task\b|MainActor)\b')

def analyze_file(file_path: Path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    stats = {
        "path": str(file_path),
        "lines": len(content.splitlines()),
        "is_swiftui": bool(SWIFTUI_VIEWS.search(content)),
        "is_shape": ": Shape" in content,
        "uses_combine": bool(COMBINE_PUBLISHERS.search(content)),
        "uses_appkit": bool(APPKIT_PATTERNS.search(content)),
        "storage": list(set(STORAGE_PATTERNS.findall(content))),
        "concurrency": list(set(ACTOR_PATTERNS.findall(content))),
    }
    return stats

def analyze_directory(source_dir: str):
    source_path = Path(source_dir)
    if not source_path.exists():
        print(f"Directory not found: {source_dir}", file=sys.stderr)
        sys.exit(1)

    all_files = list(source_path.rglob("*.swift"))
    print(f"Scanning {len(all_files)} Swift source files in {source_dir}...\n")

    summary = defaultdict(list)
    total_lines = 0

    for file_path in all_files:
        stats = analyze_file(file_path)
        total_lines += stats["lines"]

        if stats["is_shape"]:
            summary["shapes"].append(stats["path"])
        elif stats["is_swiftui"]:
            summary["views"].append(stats["path"])

        if stats["uses_combine"]:
            summary["combine"].append(stats["path"])

        if stats["uses_appkit"]:
            summary["appkit"].append(stats["path"])

        if stats["storage"]:
            summary["storage"].append((stats["path"], stats["storage"]))

        if stats["concurrency"]:
            summary["concurrency"].append((stats["path"], stats["concurrency"]))

    print("=" * 60)
    print("SWIFT TO FLUTTER MIGRATION ASSESSMENT REPORT")
    print("=" * 60)
    print(f"Total Swift files : {len(all_files)}")
    print(f"Total Lines       : {total_lines}")
    print(f"SwiftUI Views     : {len(summary['views'])}")
    print(f"SwiftUI Shapes    : {len(summary['shapes'])}")
    print(f"Combine Publishers: {len(summary['combine'])}")
    print(f"AppKit Usages     : {len(summary['appkit'])}")
    print(f"Storage references: {len(summary['storage'])}")
    print("=" * 60)

    if summary["shapes"]:
        print("\n[!] Custom SwiftUI Shapes to migrate to CustomPainter / CustomClipper:")
        for path in summary["shapes"]:
            print(f"  - {path}")

    if summary["appkit"]:
        print("\n[!] Native AppKit Components requiring Native macOS Runner Bridge:")
        for path in summary["appkit"]:
            print(f"  - {path}")

    if summary["combine"]:
        print("\n[!] State Management / Combine files to migrate to ChangeNotifier / Streams:")
        for path in summary["combine"]:
            print(f"  - {path}")

    print("\nNext Steps:")
    print("1. Implement DesignSystem (Palette, Typography, Dimensions) in Dart.")
    print("2. Port Custom Shapes to CustomPainter.")
    print("3. Convert Stores & Monitors to ChangeNotifier / StreamControllers.")
    print("4. Configure macOS Runner MethodChannel for AppKit window features.")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    analyze_directory(target)
