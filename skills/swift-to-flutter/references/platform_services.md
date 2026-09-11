# Platform Services & Storage Migration Guide

Detailed strategies for accessing macOS Keychain, SQLite stores, process monitoring, and local preferences in Flutter.

## 1. Keychain Access (`Security.framework`)

### Swift Pattern
In Swift, `SecItemCopyMatching` reads items with metadata (`kSecReturnAttributes`) or extracts secrets (`kSecReturnData`).

### Dart Migration Strategies
1. **Direct CLI Bridge** (Zero dependency):
   Call `/usr/bin/security find-generic-password -s <service> -w` via `Process.run()` to safely retrieve stored keys.
2. **Native Platform Channel**:
   Implement `loadKeychainToken(service: String)` in `macos/Runner/AppDelegate.swift` using `SecItemCopyMatching` and invoke via `MethodChannel`.
3. **Dart FFI**:
   Bind directly to `Security.framework` using `package:ffigen` for high-performance in-process reads.

## 2. SQLite Database Reading

### Swift Pattern
`sqlite3_open_v2` with read-only flags reads databases in WAL mode (e.g. Cursor or Codex state).

### Dart Migration
Use `sqlite3` Dart package:
```dart
import 'package:sqlite3/sqlite3.dart';

final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
final results = db.select('SELECT value FROM ItemTable WHERE key = ?', [key]);
```

## 3. Process Liveness (`sysctl` / `kill(pid, 0)`)

In Swift:
`kill(pid, 0) == 0` checks if a process is still running without sending a signal.
In Dart:
```dart
import 'dart:io';

Future<bool> isProcessAlive(int pid) async {
  final result = await Process.run('kill', ['-0', pid.toString()]);
  return result.exitCode == 0;
}
```
Or query process list via `ps -p <pid> -o lstart=`.

## 4. User Preferences
Swift `UserDefaults` maps directly to `shared_preferences` or local JSON storage in `~/Library/Application Support/<bundle_id>/preferences.json`.
