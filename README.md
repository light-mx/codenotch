# macOS Migration Agents

A modular, multi-target toolkit of specialized AI agents, executable skills, and automated CLI tools for migrating native macOS applications (**Swift**, **SwiftUI**, **AppKit**, **Combine**, **Foundation**) to modern cross-platform frameworks:

- 🚀 **Flutter Desktop & Multi-Platform** (Dart, CustomPainter, AppKit Runner MethodChannels)
- ⚛️ **Electron + React 19** (TypeScript, Context Isolation, Click-Through Transparent Panels)
- 🟣 **.NET MAUI & Blazor Hybrid** (C# 12 Records, CSS Spring Transitions, MacCatalyst P/Invoke)
- 🧭 **Migration Orchestrator** (Multi-target codebase assessment and framework recommendations)

---

## Key Highlights

- **Zero Project-Specific Lock-in**: Engineered as a clean, generalized framework containing no proprietary app mocks or domain assumptions.
- **Modular Distribution & Packaging**: Install individual agents, standalone skills, or complete Antigravity plugins into your workspace (`.agents/`) or machine-wide configuration (`~/.gemini/config/`).
- **Selective Installation Toolchain**: Interactive and automated CLI installer (`install.py` / `install.sh`) supporting selective installation with either file copy or live symlinking.
- **Universal AST & Design Extraction Tools**: Reusable Python 3 CLI tools for parsing Swift abstract syntax, extracting color palettes into CSS/Dart/C#, and transforming Xcode `.xcassets` bundles.

---

## Repository Architecture

```text
.
├── README.md                      # Project documentation and quickstart
├── Makefile                       # Developer tasks (test, lint, install-*)
├── install.py                     # Selective Python installer CLI
├── install.sh                     # POSIX shell installer wrapper
│
├── agents/                        # Standalone Agent Personas (YAML frontmatter)
│   ├── mac-to-flutter.md          # Native macOS -> Flutter Desktop specialist
│   ├── mac-to-electron.md         # Native macOS -> Electron + React 19 specialist
│   ├── mac-to-maui.md             # Native macOS -> .NET MAUI Blazor Hybrid specialist
│   └── mac-migration-orchestrator.md # Target assessment & orchestrator agent
│
├── plugins/                       # Self-Contained Antigravity Plugin Packages
│   ├── mac-to-flutter/            # Plugin bundle: mac-to-flutter
│   ├── mac-to-electron/           # Plugin bundle: mac-to-electron
│   └── mac-to-maui/               # Plugin bundle: mac-to-maui
│
├── skills/                        # Standalone Executable Skills & Runbooks
│   ├── swift-to-flutter/          # 4-phase migration runbook, scripts & examples
│   ├── swift-to-electron/         # 6-phase migration runbook, scripts & examples
│   └── swift-to-dotnet-maui/      # 5-phase migration runbook, scripts & examples
│
├── tools/                         # Shared Cross-Platform Migration Utilities
│   ├── swift_ast_analyzer.py      # Swift AST dependency & framework scanner
│   ├── color_palette_extractor.py # Swift Color -> CSS, Dart, and C# generator
│   └── asset_catalog_converter.py # Xcode .xcassets -> Web, Flutter, and MAUI
│
└── tests/                         # Automated Test Suite & Test Fixtures
    ├── fixtures/                  # Generic Swift models, views, and palettes
    ├── test_analyzers.py          # Unit tests for AST analyzers
    ├── test_converters.py         # Unit tests for struct/enum/palette converters
    └── test_installer.sh          # End-to-end sandbox verification for installer
```

---

## Migration Agents

| Agent | Target Framework | Primary Capabilities |
|---|---|---|
| **`mac-to-flutter`** | Flutter Desktop (macOS/iOS/Web) | • Maps SwiftUI views to Flutter widget trees.<br>• Converts SwiftUI `Shape` paths to `CustomPainter` / `CustomClipper`.<br>• Implements native `NSPanel` floating window in `MainFlutterWindow.swift`.<br>• Maps `@Published` / Combine to `ChangeNotifier` & `ValueNotifier`. |
| **`mac-to-electron`** | Electron + React 19 + TypeScript | • Dual-process architecture with strict context isolation.<br>• Screen-edge transparent overlays with forward-clickthrough (`setIgnoreMouseEvents`).<br>• Native macOS Keychain access via `/usr/bin/security`.<br>• Translates SwiftUI declarative views to React functional components & SVG. |
| **`mac-to-maui`** | .NET MAUI / Blazor Hybrid | • Translates Swift structs to C# 12 records with value equality.<br>• Translates Swift enums with associated values to discriminated union records.<br>• Converts Combine publishers to `INotifyPropertyChanged` / CommunityToolkit.Mvvm.<br>• Bridges native macOS APIs via MacCatalyst P/Invoke. |
| **`mac-migration-orchestrator`** | Evaluation & Decision | • Audits Swift AST, AppKit classes, and storage hooks.<br>• Evaluates team skill synergy and target deployment platforms.<br>• Delivers comparative recommendations and orchestrates migration agents. |

---

## Installation & Distribution

The included `install.py` / `install.sh` toolchain allows you to install individual agents, individual skills, plugin bundles, or all components into your current workspace or your global Antigravity/Gemini configuration.

### 1. View Available Components
```bash
python3 install.py --list
```

### 2. Install a Specific Agent
Install into your current project's `.agents/agents/` directory:
```bash
./install.sh --agent mac-to-flutter --scope workspace
```
Or install globally into `~/.gemini/config/agents/`:
```bash
./install.sh --agent mac-to-electron --scope global
```

### 3. Install a Specific Skill
```bash
./install.sh --skill swift-to-flutter --scope workspace
```

### 4. Install a Plugin Bundle
```bash
./install.sh --plugin mac-to-maui --scope workspace
```

### 5. Install Everything
Install all agents, skills, and plugins at once:
```bash
# Workspace installation
./install.sh --all --scope workspace

# Global installation with symlinks for live agent development
./install.sh --all --scope global --link
```

---

## Shared Universal CLI Tools

Located in the [`tools/`](./tools) directory:

### 1. Swift AST Analyzer
Inspects any Swift codebase and generates an assessment report:
```bash
python3 tools/swift_ast_analyzer.py /path/to/swift/project
# Or output as JSON:
python3 tools/swift_ast_analyzer.py /path/to/swift/project --json
```

### 2. Color Palette Extractor
Parses Swift Color extensions and converts them into CSS variables, Dart constants, or C# classes:
```bash
# Output CSS Custom Properties:
python3 tools/color_palette_extractor.py /path/to/Palette.swift --format css

# Output Flutter Dart class:
python3 tools/color_palette_extractor.py /path/to/Palette.swift --format dart -o AppColors.dart

# Output C# static class:
python3 tools/color_palette_extractor.py /path/to/Palette.swift --format csharp -o AppColors.cs
```

### 3. Asset Catalog Converter
Extracts `.appiconset` and `.imageset` bundles from Xcode `.xcassets` into target formats:
```bash
python3 tools/asset_catalog_converter.py /path/to/Assets.xcassets ./public --platform electron
python3 tools/asset_catalog_converter.py /path/to/Assets.xcassets ./assets --platform flutter
python3 tools/asset_catalog_converter.py /path/to/Assets.xcassets ./Resources --platform maui
```

---

## Testing & Quality Assurance

Run the automated test suite to verify AST parsers, transpilation converters, and installer operations:

```bash
make test
```

To run individual test suites:
```bash
# Run unit tests for analyzers and converters
python3 -m unittest discover tests

# Run installer sandbox tests
./tests/test_installer.sh
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
