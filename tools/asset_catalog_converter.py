#!/usr/bin/env python3
"""
asset_catalog_converter.py

Extracts images and icons from Xcode .xcassets asset catalogs and converts/organizes
them for Flutter, Electron, or .NET MAUI projects.
"""

import sys
import os
import shutil
import json
import argparse
from pathlib import Path

def parse_contents_json(json_path: Path):
    if not json_path.exists():
        return None
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None

def process_app_icon(appiconset_dir: Path, output_dir: Path, target_platform: str):
    images = list(appiconset_dir.glob("*.png"))
    if not images:
        return None

    # Sort images by resolution
    def get_pixel_size(p: Path):
        meta = parse_contents_json(appiconset_dir / "Contents.json")
        if meta and "images" in meta:
            for item in meta["images"]:
                if item.get("filename") == p.name:
                    size_str = item.get("size", "0x0")
                    scale_str = item.get("scale", "1x").replace("x", "")
                    try:
                        base = float(size_str.split("x")[0])
                        scale = float(scale_str)
                        return base * scale
                    except Exception:
                        pass
        return p.stat().st_size

    sorted_images = sorted(images, key=get_pixel_size, reverse=True)
    largest = sorted_images[0]

    output_dir.mkdir(parents=True, exist_ok=True)
    if target_platform == "electron":
        dest = output_dir / "app-icon.png"
    elif target_platform == "flutter":
        dest = output_dir / "app_icon.png"
    elif target_platform == "maui":
        dest = output_dir / "appicon.png"
    else:
        dest = output_dir / largest.name

    shutil.copy2(largest, dest)
    print(f"✓ Extracted AppIcon: {largest.name} -> {dest}")
    return dest

def process_image_set(imageset_dir: Path, output_dir: Path):
    files = list(imageset_dir.glob("*.png")) + list(imageset_dir.glob("*.svg"))
    copied = []
    output_dir.mkdir(parents=True, exist_ok=True)
    for f in files:
        dest = output_dir / f.name
        shutil.copy2(f, dest)
        copied.append(dest)
        print(f"✓ Extracted Asset: {f.name} -> {dest}")
    return copied

def convert_catalog(xcassets_dir: str, output_dir: str, target_platform: str = "generic"):
    root = Path(xcassets_dir)
    out = Path(output_dir)
    if not root.exists():
        print(f"Error: Asset catalog not found: {xcassets_dir}", file=sys.stderr)
        return False

    print(f"\nProcessing asset catalog: {root}")
    for item in root.glob("**/*.appiconset"):
        process_app_icon(item, out, target_platform)

    for item in root.glob("**/*.imageset"):
        process_image_set(item, out)

    print("Asset conversion complete.\n")
    return True

def main():
    parser = argparse.ArgumentParser(description="Convert Xcode .xcassets into web/flutter/maui assets")
    parser.add_argument("catalog", help="Path to .xcassets directory")
    parser.add_argument("output", help="Destination directory")
    parser.add_argument("--platform", choices=["electron", "flutter", "maui", "generic"], default="generic")
    args = parser.parse_args()

    convert_catalog(args.catalog, args.output, args.platform)

if __name__ == "__main__":
    main()
