import 'dart:async';
import 'package:flutter/foundation.dart';

/// Example showing how a Combine ObservableObject with @Published properties
/// is migrated to a Dart ChangeNotifier.
class UsageStoreExample extends ChangeNotifier {
  List<String> _activeSessions = [];
  bool _isRefreshing = false;
  Timer? _pollTimer;

  List<String> get activeSessions => List.unmodifiable(_activeSessions);
  bool get isRefreshing => _isRefreshing;

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => refresh());
    refresh();
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();

    try {
      // Emulate network fetch
      await Future.delayed(const Duration(milliseconds: 500));
      _activeSessions = ['Session 1', 'Session 2'];
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
