# AppKit to Flutter Desktop Integration Guide

When porting a native macOS AppKit application to Flutter, desktop apps often require window configurations and system capabilities beyond a standard document window.

## 1. Window Types and Floating Panels

In native AppKit, floating utility windows, menubar helpers, or notches use `NSPanel`:
```swift
super.init(
    contentRect: contentRect,
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
level = .statusBar
collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
isOpaque = false
backgroundColor = .clear
hasShadow = false
```

### Flutter macOS Implementation
In `macos/Runner/MainFlutterWindow.swift`:
1. Subclass `NSPanel` (or customize `NSWindow`).
2. Set `isOpaque = false`, `backgroundColor = .clear`, and `.borderless, .nonactivatingPanel`.
3. Set `level = .statusBar` so the surface floats above all spaces and full-screen windows.
4. Set `collectionBehavior` to `[.canJoinAllSpaces, .fullScreenAuxiliary]`.

## 2. Transparent Mouse Event Pass-Through

Desktop notches or overlays occupy a large window bounding box (to hold tooltips/shadows), but must allow mouse events to click through the empty transparent regions.

### Native Pass-Through Filter
```swift
final class CustomContainerView: NSView {
    var interactiveRects: [NSRect] = []

    override func hitTest(_ point: NSPoint) -> NSView? {
        let local = convert(point, from: superview)
        guard interactiveRects.contains(where: { $0.contains(local) }) else {
            return nil // Passes click through to windows underneath!
        }
        return super.hitTest(point)
    }
}
```

### Dart Bridge
Communicate active bounding boxes from Flutter to the native host via `MethodChannel`:
```dart
const platform = MethodChannel('com.example.app/window');
await platform.invokeMethod('setInteractiveRects', [
  {'x': notchRect.left, 'y': notchRect.top, 'width': notchRect.width, 'height': notchRect.height},
  if (hoveredCard != null)
    {'x': cardRect.left, 'y': cardRect.top, 'width': cardRect.width, 'height': cardRect.height},
]);
```

## 3. Menu Bar & Status Items (`NSStatusItem`)

For ambient utilities that offer a status bar icon:
```swift
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
if let button = statusItem.button {
    button.image = NSImage(named: "MenuBarIcon")
    button.action = #selector(statusItemClicked)
}
```
In Flutter, control status item visibility and trigger settings window presentation through platform channels.
