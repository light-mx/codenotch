# Swift vs Electron/React Architecture Comparison

When migrating a native macOS application written in Swift (AppKit + SwiftUI) to an Electron + React application, the mental model shifts from a single-process compiled runtime to a multi-process web-and-node architecture.

---

## Architectural Mapping Overview

| Native macOS (Swift) | Electron + React (TypeScript) | Key Considerations |
|:---|:---|:---|
| **`NSApplication` & `AppDelegate`** | **Electron Main Process (`app`)** | Manages application lifecycle, native menus, dock tiles, displays, and window instances. |
| **`NSWindow` / `NSPanel`** | **`BrowserWindow`** | Window instances. An `NSPanel` maps to a frameless, transparent `BrowserWindow({ type: 'panel' })`. |
| **`NSHostingView` & SwiftUI Root** | **React Renderer Process (`index.html`)** | Renders declarative UI inside Chromium. Communicates with Main exclusively via IPC. |
| **`@Published` & `ObservableObject`** | **React State / Hooks (`useState`, `useSyncExternalStore`)** | Reactive state updates triggering UI re-renders. |
| **`Combine` Publishers (`AnyPublisher`)** | **`ipcRenderer.on` / `ipcMain.emit` / `EventEmitter`** | Streamed asynchronous data flow across processes. |
| **`UserDefaults`** | **`electron-store` or Local JSON Storage** | Persistent preferences stored in `app.getPath('userData')`. |
| **`Keychain` (`Security.framework`)** | **macOS `/usr/bin/security` CLI or `safeStorage`** | Safe extraction and storage of tokens. |
| **`NSScreen`** | **Electron `screen` module** | Display bounds, usable work area (excluding Dock and Menu Bar), display change events. |
| **`NSStatusItem`** | **Electron `Tray` module** | Menu bar icon and popup context menus. |

---

## Process Separation & Context Isolation

```text
┌─────────────────────────────────────────────────────────────┐
│                    Electron Main Process                    │
│   - Node.js environment                                     │
│   - System level APIs (Keychain, SQLite, child_process)     │
│   - Window management (transparent overlays, panel level)   │
│   - Polling engine & data providers                         │
└──────────────────────────────┬──────────────────────────────┘
                               │ IPC (invoke / handle, send / on)
┌──────────────────────────────▼──────────────────────────────┐
│                    Preload Script                           │
│   - contextBridge.exposeInMainWorld('api', { ... })         │
│   - Strict security barrier: NO direct Node.js in renderer  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                   React Renderer Process                    │
│   - Chromium browser environment                            │
│   - Pure React 19 + TypeScript                              │
│   - SVG rendering for shapes & progress arcs                │
│   - Mouse event hit-testing for forward-clickthrough        │
└─────────────────────────────────────────────────────────────┘
```

---

## Performance & Memory Best Practices

1. **Lightweight Overlay Renderer**:
   Keep the React renderer lean. Avoid large UI component libraries with massive runtime CSS overhead. Use CSS custom properties and lightweight SVG elements.
2. **Background Throttling**:
   Electron throttles background windows by default. For status overlays and notches, ensure:
   ```javascript
   webPreferences: {
     backgroundThrottling: false,
     contextIsolation: true,
     nodeIntegration: false,
     preload: path.join(__dirname, '../preload/index.js')
   }
   ```
3. **No Flashing on Launch**:
   Initialize windows with `show: false` and call `win.showInactive()` inside `ready-to-show` to prevent visual white flashes.
