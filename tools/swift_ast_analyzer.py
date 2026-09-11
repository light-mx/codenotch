#!/usr/bin/env python3
"""
swift_ast_analyzer.py

Universal static analysis tool for inspecting native Swift/AppKit/SwiftUI projects.
Generates an assessment report and target suitability analysis for migrating to
Flutter, Electron, or .NET MAUI.
"""

import sys
import os
import re
import json
from pathlib import Path
from collections import defaultdict

VIEW_PATTERN = re.compile(r'struct\s+(\w+)\s*:\s*(?:[A-Za-z0-9_,\s]*\b)?View\b')
SHAPE_PATTERN = re.compile(r'struct\s+(\w+)\s*:\s*(?:[A-Za-z0-9_,\s]*\b)?Shape\b')
COMBINE_PATTERN = re.compile(r'@Published\b|\bAnyPublisher\b|\bCurrentValueSubject\b|\bPassthroughSubject\b')
STATE_PATTERN = re.compile(r'@(?:State|Binding|ObservedObject|StateObject|EnvironmentObject|Environment)\b')
APPKIT_PATTERN = re.compile(r'\b(NSPanel|NSWindow|NSView|NSHostingView|NSApplication|NSMenu|NSStatusItem|NSScreen|NSEvent|NSWorkspace)\b')
STORAGE_PATTERN = re.compile(r'\b(UserDefaults|Keychain|SecItemCopyMatching|sqlite3|FileManager|CoreData|SwiftData)\b')
CONCURRENCY_PATTERN = re.compile(r'\b(actor\s+\w+|@MainActor|Task\b|Task\.detached|nonisolated)\b')

def analyze_swift_file(file_path: Path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    lines = len(content.splitlines())
    views = VIEW_PATTERN.findall(content)
    shapes = SHAPE_PATTERN.findall(content)
    appkit_items = list(set(APPKIT_PATTERN.findall(content)))
    storage_items = list(set(STORAGE_PATTERN.findall(content)))
    concurrency_items = list(set(CONCURRENCY_PATTERN.findall(content)))
    has_combine = bool(COMBINE_PATTERN.search(content))
    has_state = bool(STATE_PATTERN.search(content))

    return {
        "file": str(file_path),
        "lines": lines,
        "views": views,
        "shapes": shapes,
        "appkit": appkit_items,
        "storage": storage_items,
        "concurrency": concurrency_items,
        "has_combine": has_combine,
        "has_state": has_state
    }

def analyze_directory(source_dir: str):
    root = Path(source_dir)
    if not root.exists():
        print(f"Error: Directory not found: {source_dir}", file=sys.stderr)
        sys.exit(1)

    swift_files = [f for f in root.rglob("*.swift") if not any(part in f.parts for part in ['.git', 'DerivedData', 'build'])]
    
    total_lines = 0
    all_views = set()
    all_shapes = set()
    all_appkit = set()
    all_storage = set()
    combine_files = 0
    concurrency_count = 0

    for f in swift_files:
        stats = analyze_swift_file(f)
        total_lines += stats["lines"]
        all_views.update(stats["views"])
        all_shapes.update(stats["shapes"])
        all_appkit.update(stats["appkit"])
        all_storage.update(stats["storage"])
        if stats["has_combine"]:
            combine_files += 1
        if stats["concurrency"]:
            concurrency_count += len(stats["concurrency"])

    report = {
        "source_directory": str(root),
        "swift_files_count": len(swift_files),
        "total_loc": total_lines,
        "swiftui_views": sorted(list(all_views)),
        "swiftui_shapes": sorted(list(all_shapes)),
        "appkit_dependencies": sorted(list(all_appkit)),
        "storage_and_security": sorted(list(all_storage)),
        "combine_files_count": combine_files,
        "concurrency_references": concurrency_count
    }

    return report

def print_report(report):
    print("\n" + "=" * 65)
    print("      UNIVERSAL SWIFT CODEBASE MIGRATION ASSESSMENT      ")
    print("=" * 65)
    print(f"Source Directory        : {report['source_directory']}")
    print(f"Total Swift Source Files: {report['swift_files_count']}")
    print(f"Total Lines of Code     : {report['total_loc']}")
    print(f"SwiftUI Views Discovered: {len(report['swiftui_views'])}")
    print(f"SwiftUI Shapes          : {len(report['swiftui_shapes'])}")
    print(f"AppKit Classes Found    : {len(report['appkit_dependencies'])} -> {', '.join(report['appkit_dependencies'])}")
    print(f"Storage & Security APIs : {', '.join(report['storage_and_security'])}")
    print(f"Combine Reactive Files  : {report['combine_files_count']}")
    print("=" * 65)

    print("\n[ Target Suitability Evaluation ]")
    print("1. Flutter Desktop:")
    print(f"   - Shapes to CustomPainter : {len(report['swiftui_shapes'])} shape(s) map cleanly to CustomPainter.")
    print(f"   - AppKit Window Bridging  : {('Required (NSPanel/Runner)' if 'NSPanel' in report['appkit_dependencies'] else 'Standard Desktop Window')}")
    print("2. Electron + React:")
    print(f"   - SwiftUI to JSX/SVG      : {len(report['swiftui_views'])} view(s) to React functional components.")
    print(f"   - Native Window Level     : Full support for type: 'panel' and click-through transparency.")
    print("3. .NET MAUI (Blazor Hybrid):")
    print(f"   - UI Layout to Blazor     : Flexible HTML/CSS flexbox for SwiftUI view conversion.")
    print(f"   - Reactive State          : Combine publishers map cleanly to INotifyPropertyChanged.")
    print("=" * 65 + "\n")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    res = analyze_directory(target)
    if "--json" in sys.argv:
        print(json.dumps(res, indent=2))
    else:
        print_report(res)
