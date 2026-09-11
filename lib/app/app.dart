import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/design.dart';
import '../design_system/palette.dart';
import '../model/fixtures.dart';
import '../model/usage_model.dart';
import '../model/usage_store.dart';
import '../notch/notch_geometry.dart';
import '../notch/notch_layout.dart';
import '../notch/notch_placement.dart';
import '../notch/notch_root_view.dart';
import '../notch/notch_view_model.dart';
import '../providers/antigravity_provider.dart';
import '../providers/claude_oauth_provider.dart';
import '../providers/codex_local_provider.dart';
import '../providers/cursor_local_provider.dart';
import '../providers/glm_provider.dart';
import '../sessions/agent_activity_monitor.dart';
import '../sessions/antigravity_activity_monitor.dart';
import '../sessions/claude_session_monitor.dart';
import '../sessions/claude_session_record.dart';
import '../sessions/cursor_activity_monitor.dart';
import '../settings/app_presence.dart';
import '../settings/notch_visibility.dart';
import '../settings/preferences.dart';
import '../settings/release_notes.dart';
import '../settings/settings_view.dart';
import '../settings/whats_new_view.dart';
import 'platform_bridge.dart';

class CodenotchApp extends StatefulWidget {
  final bool isDemo;
  final Preferences? preferences;
  final UsageStore? store;
  final NotchViewModel? viewModel;

  const CodenotchApp({
    super.key,
    this.isDemo = false,
    this.preferences,
    this.store,
    this.viewModel,
  });

  @override
  State<CodenotchApp> createState() => _CodenotchAppState();
}

class _CodenotchAppState extends State<CodenotchApp> {
  late final Preferences _preferences;
  late final NotchViewModel _model;
  UsageStore? _store;
  late final PlatformBridge _bridge;

  final Map<String, AgentActivityMonitor> _monitors = {};
  Timer? _clockTimer;
  SimpleScreen? _screen;
  bool _showingSettings = false;
  bool _showingWhatsNew = false;
  ReleaseNote? _currentReleaseNote;

  @override
  void initState() {
    super.initState();

    _preferences = widget.preferences ?? Preferences();
    _model = widget.viewModel ?? NotchViewModel();

    _bridge = PlatformBridge(
      onRefresh: () => _store?.refreshNow(),
      onTogglePinned: () => _model.togglePinned(),
      onOpenSettings: _openSettings,
      onSignIn: (index) {},
      onScreenChanged: _relocate,
    );

    _initApp();
  }

  Future<void> _initApp() async {
    _preferences.addListener(_onPreferencesChanged);
    _model.addListener(_onModelChanged);

    if (widget.isDemo) {
      _model.setSnapshots(Fixtures.snapshots());
    } else {
      _setupStoreAndMonitors();
    }

    _model.setEdge(_preferences.notchEdge);
    _applyVisibility(_preferences.notchVisibility);

    await _relocate();

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _model.tickClock();
    });

    // Check first launch / What's new
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWhatsNewOrFirstLaunch();
    });
  }

  void _setupStoreAndMonitors() {
    final claudeProfiles = ClaudeProfile.discover();

    final providers = [
      ...claudeProfiles.map((p) => ClaudeOAuthProvider(profile: p)),
      CursorLocalProvider(),
      CodexLocalProvider(),
      AntigravityProvider(),
      GLMProvider(),
      GrokLocalProvider(),
      OpenCodeProvider(),
    ];

    _store = widget.store ??
        UsageStore(
          providers: providers,
          disconnected: _preferences.disconnectedProviders,
        );

    _store!.addListener(_onStoreChanged);
    _model.setSnapshots(_store!.snapshots);
    _store!.start();

    // Activity monitors
    _monitors['cursor'] = CursorActivityMonitor();
    _monitors['codex'] = CodexActivityMonitor();
    _monitors['gemini'] = AntigravityActivityMonitor();
    _monitors['grok'] = GrokActivityMonitor();

    for (final profile in claudeProfiles) {
      _monitors[profile.id] = ClaudeSessionMonitor(directory: profile.sessionsDirectory);
    }

    for (final entry in _monitors.entries) {
      entry.value.sessionsStream.listen((sessions) {
        if (!mounted) return;
        _model.setSessions(entry.key, sessions);
      });
      entry.value.start();
    }

    _store!.isBusy = () => _monitors.values.any((m) => m.hasActiveSessions);
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    _model.removeListener(_onModelChanged);
    _store?.removeListener(_onStoreChanged);
    _store?.stop();
    for (final m in _monitors.values) {
      m.stop();
    }
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onPreferencesChanged() {
    _model.setEdge(_preferences.notchEdge);
    _store?.setDisconnected(_preferences.disconnectedProviders);
    _applyVisibility(_preferences.notchVisibility);
    _bridge.setAppPresence(
      showInDock: _preferences.appPresence.activationPolicy == ActivationPolicy.regular,
      showStatusItem: _preferences.appPresence.wantsStatusItem,
    );
    _relocate();
  }

  void _onStoreChanged() {
    if (!mounted || _store == null) return;
    _model.setSnapshots(_store!.snapshots);
    _model.setRefreshing(_store!.refreshing);
  }

  void _onModelChanged() {
    _updateInteractiveRects();
  }

  void _applyVisibility(NotchVisibility visibility) {
    switch (visibility) {
      case NotchVisibility.alwaysShow:
        _model.setAlwaysOn(true);
        break;
      case NotchVisibility.onHover:
        _model.setAlwaysOn(false);
        break;
      case NotchVisibility.hidden:
        _model.setAlwaysOn(false);
        _model.setExpanded(false);
        break;
    }
  }

  Future<void> _relocate() async {
    final screen = await _bridge.getScreenGeometry() ??
        const SimpleScreen(
          frameValue: Rect.fromLTWH(0, 0, 1920, 1080),
          visibleFrameValue: Rect.fromLTWH(0, 25, 1920, 1055),
        );
    _screen = screen;

    final panelSize = _model.panelSize();
    final frame = NotchGeometry.panelFrame(
      screen: screen,
      panelSize: panelSize,
      edge: _model.edge,
    );

    await _bridge.setWindowFrame(frame);
    _updateInteractiveRects();
  }

  void _updateInteractiveRects() {
    if (_showingSettings || _showingWhatsNew) {
      // Allow clicking on dialog
      _bridge.setInteractiveRects([
        const Rect.fromLTWH(0, 0, 2000, 2000),
      ]);
      return;
    }

    final panelSize = _model.panelSize();
    final place = NotchPlacement(edge: _model.edge, panelSize: panelSize);

    final List<Rect> rects = [];

    // Live rect
    if (_model.isExpanded) {
      final notchRect = place.rect(
        along: _model.slackValue,
        across: 0,
        length: _model.shapeLengthValue,
        depth: _model.notchDepth,
      );

      final handleCenter = place.point(
        along: _model.slackValue + _model.orbAlong,
        across: _model.orbInset,
      );
      final handleRect = Rect.fromCenter(
        center: handleCenter,
        width: NotchLayout.orbHotZone,
        height: NotchLayout.orbHotZone,
      );

      rects.add(notchRect.expandToInclude(handleRect));
    } else {
      final length = _model.restingLength > NotchLayout.pillHotZone
          ? _model.restingLength
          : NotchLayout.pillHotZone;
      final pillRect = place.rect(
        along: _model.slackValue + (_model.shapeLengthValue - length) / 2,
        across: 0,
        length: length,
        depth: _model.restingDepth + NotchLayout.pillHotZone,
      );
      rects.add(pillRect);
    }

    // Tooltip rect if hovered
    if (_model.isExpanded && _model.hoveredIndex != null) {
      final index = _model.hoveredIndex!;
      if (index >= 0 && index < _model.snapshots.length) {
        final snapshot = _model.snapshots[index];
        final activity = _model.activityFor(snapshot.id);
        final cardHeight = NotchLayout.cardHeight(
          windowCount: snapshot.windows.length,
          sessionCount: activity?.sessions.length ?? 0,
          sessionCap: _model.sessionCap,
          statusMessage: snapshot.statusMessage,
          blockMessage: snapshot.block?.summary(now: _model.now),
        );

        final cardAcross = _model.edge.isVertical ? NotchLayout.cardWidth : cardHeight;
        final cardAlong = _model.edge.isVertical ? cardHeight : NotchLayout.cardWidth;
        final center = _model.slackValue + _model.ringCenter(index);

        final cardRect = place.rect(
          along: center - cardAlong / 2,
          across: _model.contentInset + NotchLayout.bodyDepth(_model.edge),
          length: cardAlong,
          depth: NotchLayout.tailGap + NotchLayout.tailLength + cardAcross,
        );
        rects.add(cardRect);
      }
    }

    _bridge.setInteractiveRects(rects);
  }

  void _checkWhatsNewOrFirstLaunch() {
    final note = ReleaseNotes.latest;
    if (_preferences.isFirstLaunch) {
      _openWhatsNew(note);
    } else if (_preferences.lastSeenVersion != note.version) {
      _openWhatsNew(note);
    }
  }

  void _openSettings() {
    setState(() {
      _showingSettings = true;
    });
    _updateInteractiveRects();
  }

  void _closeSettings() {
    setState(() {
      _showingSettings = false;
    });
    _updateInteractiveRects();
  }

  void _openWhatsNew(ReleaseNote note) {
    setState(() {
      _currentReleaseNote = note;
      _showingWhatsNew = true;
    });
    _updateInteractiveRects();
  }

  void _closeWhatsNew() {
    if (_currentReleaseNote != null) {
      _preferences.setLastSeenVersion(_currentReleaseNote!.version);
    }
    setState(() {
      _showingWhatsNew = false;
      _currentReleaseNote = null;
    });
    if (_preferences.isFirstLaunch) {
      _openSettings();
    } else {
      _updateInteractiveRects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codenotch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Floating Notch
            if (_preferences.notchVisibility != NotchVisibility.hidden)
              Positioned.fill(
                child: NotchRootView(
                  model: _model,
                  onOpenSettings: _openSettings,
                  onRefreshProvider: (id) => _store?.refreshProvider(id),
                ),
              ),

            // Settings Overlay
            if (_showingSettings)
              _buildModalBackdrop(
                child: Dialog(
                  backgroundColor: Palette.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Palette.cardBorder),
                  ),
                  child: Stack(
                    children: [
                      SettingsView(
                        preferences: _preferences,
                        providers: () => _store?.providerSummaries ?? [],
                        onSignOut: (id) => _store?.signOut(id),
                        onSignIn: (id) => _store?.signIn(id) ?? false,
                        onRetry: (id) => _store?.reauthorize(id),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Palette.textSecondary),
                          onPressed: _closeSettings,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // What's New Overlay
            if (_showingWhatsNew && _currentReleaseNote != null)
              _buildModalBackdrop(
                child: Dialog(
                  backgroundColor: Palette.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Palette.cardBorder),
                  ),
                  child: WhatsNewView(
                    note: _currentReleaseNote!,
                    onContinue: _closeWhatsNew,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalBackdrop({required Widget child}) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: child,
    );
  }
}
