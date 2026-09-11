---
name: swift-to-flutter
description: >-
  Systematic guide, runbook, and automated utilities for migrating macOS and iOS Swift, SwiftUI,
  and AppKit/UIKit projects to idiomatic Flutter and Dart while preserving pixel-perfect design,
  fluid animations, and native desktop/mobile OS capabilities.
---

# Swift to Flutter Migration Skill

A comprehensive methodology and toolkit for translating Swift codebases (SwiftUI, AppKit, UIKit, Combine, Concurrency, Swift Data/CoreData/SQLite) into clean, performant, idiomatic Flutter and Dart applications.

## Migration Principles

1. **Design & Geometry Parity**: Never eyeball numbers or approximate visual weights. Preserve exact pixel scales, design anchors, stroke widths, corner radii, and Bézier curves. Use custom painters or clippers for non-standard geometry.
2. **Behavioral Equivalence**: Preserve interaction states, spring physics, hover grace periods, keyboard shortcuts, and layout constraints.
3. **Architecture Mapping**:
   - SwiftUI `@Published` / `ObservableObject` / `@Observable` -> Dart `ChangeNotifier` / `ValueNotifier` / Rivers/Bloc.
   - Swift `Actor` / `async/await` -> Dart async methods, isolate workers, or concurrent Streams.
   - Combine pipelines (`.sink`, `.debounce`, `.filter`) -> `rxdart` or native `StreamTransformer` pipelines.
   - AppKit/UIKit native windows and panels -> Flutter Desktop Window plugins / Custom Native Runners with MethodChannels.
4. **Desktop Native Capabilities**: When desktop apps require features like borderless floating `NSPanel`, mouse event pass-through, status items (`NSStatusItem`), or macOS Keychain access, cleanly bridge Flutter with a lightweight macOS Runner layer.

---

## 4-Phase Migration Workflow

### Phase 1: Codebase Analysis & Inventory
Run the project analyzer script to catalog views, shapes, models, platform dependencies, and async pipelines:
```bash
python3 scripts/analyze_swift_project.py <path_to_swift_sources>
```
Review the generated report for:
- Complex SwiftUI `Shape` structs requiring `CustomPainter` / `Path` reconstruction.
- Platform-native APIs (Keychain, SQLite, `NSWindow`/`NSPanel`, `NSStatusItem`, `ProcessInfo`).
- Asynchronous data stores and Combine publishers.

### Phase 2: Design System & Shared Foundations
1. **Palette & Tokens**: Port color schemes to Flutter `Color(0xFF...)`.
2. **Typography & Scaling**: Port font point sizes, cap-height ratios, and design frame scale factors (`px()` functions).
3. **Geometry & Shapes**: Use `scripts/swift_shape_to_flutter_painter.py` to convert canonical Bézier path definitions and arcs into Flutter `Path` operations.

### Phase 3: Domain Models, Store & Concurrency
1. **Models**: Port Swift `struct` / `Codable` to Dart classes with `fromJson` / `toJson` or factory constructors.
2. **Copy & Formatters**: Replicate locale, date formatting, and relative elapsed time helpers with exact unit test coverage.
3. **State Management**: Translate `@MainActor ObservableObject` stores into Dart `ChangeNotifier` with reactive notification dispatching.

### Phase 4: UI Composition, Animation & Native Platform Bridge
1. **Component Hierarchy**:
   - `VStack` / `HStack` -> `Column` / `Row` / `Flex`.
   - `ZStack` -> `Stack` / `Positioned`.
   - `GeometryReader` -> `LayoutBuilder` / `CustomSingleChildLayout`.
2. **Animations**: Map SwiftUI spring curves (`response`, `dampingFraction`) to Flutter `CurvedAnimation` with `SpringSimulation` or appropriate cubic easing curves.
3. **Platform Runner**: If migrating a desktop utility requiring an `NSPanel` or specific activation policy, integrate the macOS runner templates documented in [references/appkit_to_flutter_desktop.md](./references/appkit_to_flutter_desktop.md).

---

## Reference Guides

- [SwiftUI to Flutter UI Mapping](./references/swiftui_to_flutter_ui.md): Detailed comparison table and widget conversions.
- [AppKit to Flutter Desktop](./references/appkit_to_flutter_desktop.md): Window styles, non-activating panels, mouse event pass-through, status bar items.
- [Concurrency and State Management](./references/concurrency_and_state.md): Actor isolation, async-await, Combine publishers to Dart Streams.
- [Platform Services & Storage](./references/platform_services.md): Keychain, SQLite, filesystem discovery, process checks.

## Scripts & Tools

- [analyze_swift_project.py](./scripts/analyze_swift_project.py): Swift source scanner.
- [swift_shape_to_flutter_painter.py](./scripts/swift_shape_to_flutter_painter.py): SwiftUI Shape to Flutter Path translator.
- [scaffold_flutter_macos.py](./scripts/scaffold_flutter_macos.py): macOS Flutter runner generator with custom window support.
