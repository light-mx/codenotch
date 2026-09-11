---
name: swift-to-electron
description: >-
  Comprehensive guide, runbooks, scripts, and architectural patterns for converting native macOS Swift/SwiftUI/AppKit applications into high-performance, pixel-perfect Electron and React desktop applications. Use when migrating native macOS apps to cross-platform Electron/React, porting NSPanel/NSWindow overlays, handling click-through transparency, or translating SwiftUI views into React components.
---

# Swift to Electron Migration Skill

A standardized framework, executable toolchain, and reference architecture for translating native macOS applications (Swift, SwiftUI, AppKit) into modern, high-fidelity Electron + React applications with strict behavioral and visual parity.

---

## When to Invoke This Skill

Activate this skill whenever you need to:
1. **Migrate an existing Swift / macOS application** to Electron + React.
2. **Replicate native macOS desktop behaviors in Electron**, including:
   - Floating panels (`NSPanel`), borderless click-through windows with interactive regions.
   - macOS screen-edge notches, status bars, and hardware bezel integration.
   - Tray items (`NSStatusItem`) and dock tile control (`app.dock.show()` / `app.dock.hide()`).
   - Native macOS Keychain access (`security` CLI / Keychain APIs).
   - Reading application local state (SQLite databases in WAL mode, JSON configurations, local Unix domain sockets or RPC servers).
3. **Translate SwiftUI declarative syntax to React 19 + TypeScript**:
   - Translating `@State`, `@ObservedObject`, `@Published`, `Combine` pipelines to React hooks and stores.
   - Converting `VStack`, `HStack`, `ZStack`, `GeometryReader`, and custom `Shape` paths into JSX and SVG.
   - Replicating Apple spring dynamics and transition curves in CSS/Web Animations.
4. **Audit and verify design and behavioral parity** between the native macOS build and the Electron build.

---

## Migration Workflow (The 6-Phase Pipeline)

```text
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Audit & Discovery                                  │
│ run scripts/analyze-swift-project.js                        │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ Phase 2: Asset & Glyph Pipeline                             │
│ run scripts/convert-xcassets-to-web.js                      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ Phase 3: Project Scaffolding                                │
│ run scripts/generate-electron-scaffold.js                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ Phase 4: System & IPC Layer (Main & Preload)                │
│ Window geometry, mouse forwarding, security & credentials   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ Phase 5: React UI & State Transpilation                     │
│ Design tokens, SVG shapes, animations, settings & dialogs   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ Phase 6: Parity QA & Verification                           │
│ run scripts/verify-parity.js                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Procedure

### Step 1: Codebase Audit & Static Analysis
Run the project analyzer against the native Swift codebase:
```bash
node scripts/analyze-swift-project.js /path/to/swift/sources
```
This inspects the AST/tokens of the Swift project and outputs:
- AppKit window controllers and panels used (`NSPanel`, `NSWindow`, `NSMenu`).
- SwiftUI Views, shapes, modifiers, and view models (`ObservableObject`).
- Local storage and credentials accessed (`Keychain`, `UserDefaults`, SQLite files).
- System-level processes or monitoring hooks (`Process`, `DispatchSourceFileSystemObject`).

### Step 2: Convert Assets and Vector Marks
Extract asset catalogs (`.xcassets`) and vector definitions to web equivalents:
```bash
node scripts/convert-xcassets-to-web.js /path/to/Assets.xcassets /path/to/output
```
- App icons: Converts `.appiconset` to `icon.png`, `icon@2x.png`, `icon.icns`.
- Status bar / Menu bar icons: Generates template SVGs and PNGs.
- Traced glyphs: Converts Swift `CGPoint` polygon arrays into SVG `d="M... L... Z"` paths.

### Step 3: Project Scaffolding
Initialize the Electron + React + TypeScript structure:
```bash
node scripts/generate-electron-scaffold.js my-app
```
Scaffolds Vite + React + TypeScript with standard Electron dual-process architecture.

### Step 4: System & IPC Implementation
Follow the reference guides in `references/`:
1. **Window Levels & Multi-Space Pinning**: See [`references/macos-transparency-and-panels.md`](./references/macos-transparency-and-panels.md).
   - Use `type: 'panel'`, `alwaysOnTop: true` with `'screen-saver'`, and `setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })`.
2. **Mouse Event Forwarding**:
   - Set `win.setIgnoreMouseEvents(true, { forward: true })` by default.
   - On mouse enter over interactive components, call `window.desktopBridge.setIgnoreMouseEvents(false)`.
   - On mouse leave, call `window.desktopBridge.setIgnoreMouseEvents(true, { forward: true })`.
3. **Keychain & Local State**: See [`references/native-macos-system-integrations.md`](./references/native-macos-system-integrations.md).
   - Use macOS `/usr/bin/security` CLI or native bindings for generic password reading.
   - Use read-only SQLite connections without WAL lockouts.

### Step 5: UI & Animation Transpilation
1. **Layout & Tokens**: See [`references/swiftui-to-react-mapping.md`](./references/swiftui-to-react-mapping.md).
   - Port `Palette.swift` colors directly to CSS variables or TypeScript constants.
   - Port `Design.scale` proportional units.
2. **Custom Curves & Flares**: See [`references/macos-transparency-and-panels.md`](./references/macos-transparency-and-panels.md).
   - Use exact SVG cubic Beziers or arcs (`A rx ry x-axis-rotation large-arc-flag sweep-flag x y`) to construct inverse rounded corners.
3. **Spring Animations**: Use CSS transitions with `cubic-bezier(0.36, 0, 0.2, 1)` or Web Animations API to match Apple's standard spring physics.

### Step 6: Parity Verification
Execute the automated parity verification script:
```bash
node scripts/verify-parity.js
```
Validates:
- Proportional scale and color hex equivalence.
- Stack-space geometry and screen bounding boxes.
- Provider snapshot and limit window data schemas.

---

## Detailed References

- [Architecture Comparison](./references/architecture-comparison.md)
- [AppKit to Electron API Mapping](./references/appkit-to-electron-api.md)
- [SwiftUI to React & Tailwind Mapping](./references/swiftui-to-react-mapping.md)
- [macOS Notch Geometry & Transparency](./references/macos-transparency-and-panels.md)
- [Native macOS System Integrations](./references/native-macos-system-integrations.md)
