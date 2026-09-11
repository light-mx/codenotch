# Swift Concurrency & Combine to Dart Migration Guide

This guide describes how to translate Swift's actor model, `async/await`, `@Published` properties, and Combine publisher pipelines to Dart.

## 1. Concurrency Models

| Swift | Dart | Notes |
|---|---|---|
| `actor UsageStore { ... }` | `class UsageStore` (Single-threaded Event Loop) or `Isolate` | Dart runs on a single-threaded event loop by default. Unless heavy CPU crunching is needed, ordinary classes with `Future` and `async/await` have no race conditions on state mutations. |
| `Task { await doWork() }` | `unawaited(doWork())` or `Future(() async => ...)` | Background asynchronous execution. |
| `@MainActor` | Default Flutter UI Thread | All Flutter widget builds and state notifications run on the main isolate UI loop. |
| `Task.sleep(nanoseconds:)` | `await Future.delayed(Duration(...))` | Async delay. |

## 2. State & Combine Mapping

### `@Published` Properties to `ChangeNotifier`
In Swift:
```swift
final class UsageStore: ObservableObject {
    @Published private(set) var snapshots: [ProviderSnapshot] = []
    
    func update() {
        snapshots = [...]
    }
}
```

In Dart:
```dart
class UsageStore extends ChangeNotifier {
    List<ProviderSnapshot> _snapshots = [];
    List<ProviderSnapshot> get snapshots => _snapshots;

    void update(List<ProviderSnapshot> next) {
        _snapshots = next;
        notifyListeners();
    }
}
```

### Granular Value Notifiers
For single primitive properties that change frequently (e.g., hover index, edge placement):
```dart
final ValueNotifier<int?> hoveredIndex = ValueNotifier<int?>(null);
```
Consumers listen with `ValueListenableBuilder` to re-render only the affected subtree.

## 3. Combine Streams to Dart Streams

| Combine Operation | Dart Equivalent |
|---|---|
| `CurrentValueSubject<T, Never>` | `BehaviorSubject<T>` (rxdart) or `ValueNotifier<T>` |
| `PassthroughSubject<T, Never>` | `StreamController<T>.broadcast()` |
| `.sink { value in ... }` | `stream.listen((value) { ... })` |
| `.debounce(for: .seconds(s), scheduler: ...)` | `stream.debounceTime(Duration(seconds: s))` |
| `.removeDuplicates()` | `stream.distinct()` |
| `.store(in: &cancellables)` | `StreamSubscription.cancel()` in `dispose()` |
