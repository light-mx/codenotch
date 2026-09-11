#!/usr/bin/env python3
"""
scaffold_flutter_macos.py

Scaffolds a Flutter macOS Runner supporting borderless, transparent,
non-activating NSPanel with pass-through mouse event hit-testing.
"""

import sys
import os
from pathlib import Path

MAIN_FLUTTER_WINDOW_SWIFT = """import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSPanel {
    private var channel: FlutterMethodChannel?
    var interactiveRects: [NSRect] = []

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.isMovable = false
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        self.becomesKeyOnlyIfNeeded = true
        self.isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        let registrar = flutterViewController.registrar(forPlugin: "WindowPlugin")
        let channel = FlutterMethodChannel(
            name: "com.codenotch/window",
            binaryMessenger: registrar.messenger
        )
        self.channel = channel

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "setWindowFrame":
                if let args = call.arguments as? [String: Double],
                   let x = args["x"], let y = args["y"],
                   let width = args["width"], let height = args["height"] {
                    self.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
            case "setInteractiveRects":
                if let rectsData = call.arguments as? [[String: Double]] {
                    self.interactiveRects = rectsData.compactMap { r in
                        guard let x = r["x"], let y = r["y"], let w = r["width"], let h = r["height"] else { return nil }
                        return NSRect(x: x, y: y, width: w, height: h)
                    }
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
            case "getScreenGeometry":
                if let screen = NSScreen.main {
                    let full = screen.frame
                    let usable = screen.visibleFrame
                    result([
                        "frame": ["x": full.origin.x, "y": full.origin.y, "width": full.width, "height": full.height],
                        "visibleFrame": ["x": usable.origin.x, "y": usable.origin.y, "width": usable.width, "height": usable.height]
                    ])
                } else {
                    result(nil)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }
}
"""

def scaffold(target_dir: str):
    base = Path(target_dir) / "macos" / "Runner"
    base.mkdir(parents=True, exist_ok=True)
    window_file = base / "MainFlutterWindow.swift"
    with open(window_file, "w") as f:
        f.write(MAIN_FLUTTER_WINDOW_SWIFT)
    print(f"Scaffolded MainFlutterWindow.swift at {window_file}")

if __name__ == "__main__":
    dest = sys.argv[1] if len(sys.argv) > 1 else "."
    scaffold(dest)
