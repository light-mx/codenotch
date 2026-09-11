import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/usage_provider.dart';
import 'usage_archive.dart';
import 'usage_model.dart';

class UsageStore extends ChangeNotifier {
  final List<UsageProvider> providers;
  final Duration refreshInterval;
  final Duration idleRefreshInterval;
  final Duration staleAfter;
  final UsageArchive archive;

  List<ProviderSnapshot> _snapshots = [];
  Set<String> _refreshing = {};
  Set<String> _refusedAccess = {};
  Set<String> _disconnected = {};
  final Map<String, ({ProviderSnapshot snapshot, DateTime fetchedAt})> _lastGood = {};

  bool Function() isBusy = () => false;
  Timer? _timer;
  bool _isFetching = false;

  List<ProviderSnapshot> get snapshots => _snapshots;
  Set<String> get refreshing => _refreshing;
  Set<String> get refusedAccess => _refusedAccess;
  Set<String> get disconnected => _disconnected;

  UsageStore({
    required this.providers,
    this.refreshInterval = const Duration(seconds: 60),
    this.idleRefreshInterval = const Duration(minutes: 5),
    this.staleAfter = const Duration(minutes: 15),
    UsageArchive? archive,
    Set<String> disconnected = const {},
  })  : archive = archive ?? UsageArchive(),
        _disconnected = Set.from(disconnected) {
    _lastGood.addAll(this.archive.load());
    for (final id in _disconnected) {
      _lastGood.remove(id);
    }
    _rebuildSnapshots();
  }

  void setDisconnected(Set<String> next) {
    if (setEquals(_disconnected, next)) return;
    _disconnected = Set.from(next);
    for (final id in next) {
      _lastGood.remove(id);
    }
    archive.save(_lastGood);
    _rebuildSnapshots();
    refreshNow();
  }

  void start() {
    stop();
    refreshNow();
    _scheduleNextPoll();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNextPoll() {
    _timer?.cancel();
    final interval = isBusy() ? refreshInterval : idleRefreshInterval;
    _timer = Timer(interval, () {
      refreshNow();
      _scheduleNextPoll();
    });
  }

  Future<void> refreshNow() async {
    if (_isFetching) return;
    _isFetching = true;

    final activeProviders = providers.where((p) => !_disconnected.contains(p.id)).toList();
    _refreshing = activeProviders.map((p) => p.id).toSet();
    notifyListeners();

    try {
      final futures = activeProviders.map((p) async {
        try {
          final snapshot = await p.fetchSnapshot();
          _refusedAccess.remove(p.id);
          _lastGood[p.id] = (snapshot: snapshot, fetchedAt: DateTime.now());
        } on UsageProviderError catch (e) {
          if (e == UsageProviderError.accessDenied) {
            _refusedAccess.add(p.id);
          } else {
            _refusedAccess.remove(p.id);
          }
        } catch (_) {
          _refusedAccess.remove(p.id);
        }
      });

      await Future.wait(futures);
      archive.save(_lastGood);
      _rebuildSnapshots();
    } finally {
      _refreshing = {};
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> refreshProvider(String id) async {
    final provider = providers.firstWhere((p) => p.id == id, orElse: () => throw Exception());
    _refreshing.add(id);
    notifyListeners();

    try {
      final snapshot = await provider.fetchSnapshot();
      _refusedAccess.remove(id);
      _lastGood[id] = (snapshot: snapshot, fetchedAt: DateTime.now());
      archive.save(_lastGood);
      _rebuildSnapshots();
    } on UsageProviderError catch (e) {
      if (e == UsageProviderError.accessDenied) {
        _refusedAccess.add(id);
      } else {
        _refusedAccess.remove(id);
      }
    } catch (_) {
      _refusedAccess.remove(id);
    } finally {
      _refreshing.remove(id);
      notifyListeners();
    }
  }

  void _rebuildSnapshots() {
    final List<ProviderSnapshot> list = [];
    final current = DateTime.now();

    for (final p in providers) {
      if (_disconnected.contains(p.id)) continue;
      final cached = _lastGood[p.id];
      if (cached != null) {
        final age = current.difference(cached.fetchedAt);
        if (age > staleAfter) {
          list.add(
            ProviderSnapshot(
              id: cached.snapshot.id,
              displayName: cached.snapshot.displayName,
              glyph: cached.snapshot.glyph,
              fidelity: cached.snapshot.fidelity,
              status: ProviderStatusStale(cached.fetchedAt),
              windows: cached.snapshot.windows,
              headlineID: cached.snapshot.headlineID,
              block: cached.snapshot.block,
            ),
          );
        } else {
          list.add(cached.snapshot);
        }
      } else {
        list.add(
          ProviderSnapshot(
            id: p.id,
            displayName: p.displayName,
            glyph: p.glyph,
            fidelity: Fidelity.official,
            status: const ProviderStatusNeedsAuth(),
            windows: const [],
          ),
        );
      }
    }

    _snapshots = list;
    notifyListeners();
  }

  List<ProviderSummary> get providerSummaries {
    return providers.map((p) {
      final isConn = !_disconnected.contains(p.id);
      final snapshot = _snapshots.firstWhere(
        (s) => s.id == p.id,
        orElse: () => ProviderSnapshot(
          id: p.id,
          displayName: p.displayName,
          glyph: p.glyph,
          fidelity: Fidelity.official,
          status: const ProviderStatusNeedsAuth(),
          windows: const [],
        ),
      );

      return ProviderSummary(
        id: p.id,
        displayName: p.displayName,
        glyph: p.glyph,
        account: p.account(),
        status: snapshot.status,
        isConnected: isConn,
        wasRefusedAccess: _refusedAccess.contains(p.id),
      );
    }).toList();
  }

  void signOut(String id) {
    final next = Set<String>.from(_disconnected)..add(id);
    setDisconnected(next);
  }

  bool signIn(String id) {
    final next = Set<String>.from(_disconnected)..remove(id);
    setDisconnected(next);
    final provider = providers.firstWhere((p) => p.id == id, orElse: () => throw Exception());
    provider.presentSignIn();
    return true;
  }

  void reauthorize(String id) {
    final provider = providers.firstWhere((p) => p.id == id, orElse: () => throw Exception());
    provider.forgetCachedCredential();
    refreshProvider(id);
  }
}
