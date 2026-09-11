# AppKit to Electron API Mapping Reference

An exhaustive mapping of native AppKit classes and methods to Electron counterparts.

---

## 1. Windows & Panels

| AppKit (Swift) | Electron (TypeScript/JavaScript) | Notes |
|:---|:---|:---|
| `NSWindow(contentRect:styleMask:backing:defer:)` | `new BrowserWindow({ width, height, ... })` | Basic window constructor. |
| `styleMask: [.borderless, .nonactivatingPanel]` | `frame: false, focusable: false, type: 'panel'` | Borderless, non-stealing focus overlay. |
| `window.isOpaque = false` | `transparent: true` | Enables alpha transparency. |
| `window.backgroundColor = .clear` | `backgroundColor: '#00000000'` | Clear window background. |
| `window.hasShadow = false` | `hasShadow: false` | Prevents shadow rendering around transparent paths. |
| `window.level = .statusBar` | `win.setAlwaysOnTop(true, 'screen-saver')` | Puts window above all normal windows and menu bar. |
| `window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]` | `win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })` | Stays visible across all macOS spaces & fullscreen. |
| `window.canBecomeKey = false` | `focusable: false` | Window never steals keyboard focus from active apps. |
| `window.setFrame(rect, display: true)` | `win.setBounds({ x, y, width, height })` | Position and size in screen coordinates. |

---

## 2. Screens & Geometry

| AppKit (Swift) | Electron (TypeScript/JavaScript) | Notes |
|:---|:---|:---|
| `NSScreen.main` | `screen.getPrimaryDisplay()` | Primary screen with the menu bar. |
| `NSScreen.screens` | `screen.getAllDisplays()` | List of all connected monitors. |
| `screen.frame` | `display.bounds` (`{ x, y, width, height }`) | Full physical screen bounding box. |
| `screen.visibleFrame` | `display.workArea` (`{ x, y, width, height }`) | Usable screen space excluding Dock & Menu Bar. |
| `screen.safeAreaInsets.top` | `display.bounds.height - display.workArea.height` (approx) | Detects hardware camera notch or top menu bar height. |
| `NSApplication.didChangeScreenParametersNotification` | `screen.on('display-metrics-changed', ...)` | Notification when monitors are connected/rearranged. |

---

## 3. Menu Bar & Tray

| AppKit (Swift) | Electron (TypeScript/JavaScript) | Notes |
|:---|:---|:---|
| `NSStatusBar.system.statusItem(withLength:)` | `new Tray(iconPath)` | Creates a menu bar icon. |
| `statusItem.button?.image` | `tray.setImage(nativeImage)` | Sets 16x16 / 32x32 template icon. |
| `statusItem.menu = menu` | `tray.setContextMenu(Menu.buildFromTemplate([...]))` | Attaches a popup menu. |
| `NSApp.setActivationPolicy(.accessory)` | `app.dock.hide()` | Hides app icon from the macOS Dock. |
| `NSApp.setActivationPolicy(.regular)` | `app.dock.show()` | Shows app icon in the macOS Dock. |

---

## 4. Workspaces & System Open

| AppKit (Swift) | Electron (TypeScript/JavaScript) | Notes |
|:---|:---|:---|
| `NSWorkspace.shared.open(url)` | `shell.openExternal(url)` | Opens URL in user's default browser. |
| `NSWorkspace.shared.openApplication(at:...)` | `child_process.execFile('open', ['-b', bundleId])` | Launches another macOS application by bundle ID. |
| `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)` | `child_process.execSync('mdfind kMDItemCFBundleIdentifier == ...')` | Checks if an application is installed. |
