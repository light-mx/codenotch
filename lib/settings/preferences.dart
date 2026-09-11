import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notch/notch_edge.dart';
import 'app_presence.dart';
import 'notch_visibility.dart';

class Preferences extends ChangeNotifier {
  Set<String> _disconnectedProviders = {};
  NotchVisibility _notchVisibility = NotchVisibility.onHover;
  NotchEdge _notchEdge = NotchEdge.right;
  AppPresence _appPresence = AppPresence.dockAndMenuBar;
  String? _lastSeenVersion;
  bool _launchAtLogin = false;
  bool _isFirstLaunch = false;

  SharedPreferences? _prefs;

  Set<String> get disconnectedProviders => _disconnectedProviders;
  NotchVisibility get notchVisibility => _notchVisibility;
  NotchEdge get notchEdge => _notchEdge;
  AppPresence get appPresence => _appPresence;
  String? get lastSeenVersion => _lastSeenVersion;
  bool get launchAtLogin => _launchAtLogin;
  bool get isFirstLaunch => _isFirstLaunch;

  Preferences() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final hasLaunched = _prefs?.getBool('hasLaunchedBefore') ?? false;
      _isFirstLaunch = !hasLaunched;
      if (_isFirstLaunch) {
        await _prefs?.setBool('hasLaunchedBefore', true);
      }

      final disconnectedList = _prefs?.getStringList('hiddenProviders') ?? [];
      _disconnectedProviders = disconnectedList.toSet();

      final visRaw = _prefs?.getString('notchVisibility');
      if (visRaw != null) {
        _notchVisibility = NotchVisibility.values.firstWhere(
          (v) => v.name == visRaw,
          orElse: () => NotchVisibility.onHover,
        );
      }

      final edgeRaw = _prefs?.getString('notchEdge');
      if (edgeRaw != null) {
        _notchEdge = NotchEdge.values.firstWhere(
          (e) => e.name == edgeRaw,
          orElse: () => NotchEdge.right,
        );
      }

      final presenceRaw = _prefs?.getString('appPresence');
      if (presenceRaw != null) {
        _appPresence = AppPresence.values.firstWhere(
          (p) => p.name == presenceRaw,
          orElse: () => AppPresence.dockAndMenuBar,
        );
      }

      _lastSeenVersion = _prefs?.getString('lastSeenVersion');
      _launchAtLogin = _prefs?.getBool('launchAtLogin') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  void setDisconnectedProviders(Set<String> providers) {
    _disconnectedProviders = providers;
    _prefs?.setStringList('hiddenProviders', providers.toList());
    notifyListeners();
  }

  void toggleProvider(String id) {
    final next = Set<String>.from(_disconnectedProviders);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    setDisconnectedProviders(next);
  }

  void setNotchVisibility(NotchVisibility visibility) {
    if (_notchVisibility == visibility) return;
    _notchVisibility = visibility;
    _prefs?.setString('notchVisibility', visibility.name);
    notifyListeners();
  }

  void setNotchEdge(NotchEdge edge) {
    if (_notchEdge == edge) return;
    _notchEdge = edge;
    _prefs?.setString('notchEdge', edge.name);
    notifyListeners();
  }

  void setAppPresence(AppPresence presence) {
    if (_appPresence == presence) return;
    _appPresence = presence;
    _prefs?.setString('appPresence', presence.name);
    notifyListeners();
  }

  void setLastSeenVersion(String version) {
    _lastSeenVersion = version;
    _prefs?.setString('lastSeenVersion', version);
    notifyListeners();
  }

  void setLaunchAtLogin(bool enabled) {
    _launchAtLogin = enabled;
    _prefs?.setBool('launchAtLogin', enabled);
    notifyListeners();
  }
}
