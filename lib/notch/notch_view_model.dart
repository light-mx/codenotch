import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/usage_model.dart';
import '../sessions/activity_summary.dart';
import '../sessions/agent_session.dart';
import 'notch_edge.dart';
import 'notch_geometry.dart';
import 'notch_layout.dart';

class NotchViewModel extends ChangeNotifier {
  List<ProviderSnapshot> _snapshots = [];
  NotchEdge _edge = NotchEdge.right;
  bool _isExpanded = false;
  bool _isPinned = false;
  bool _isAlwaysOn = false;
  int? _hoveredIndex;
  bool _isHoveringSettings = false;
  final Map<String, List<AgentSession>> _sessions = {};
  Set<String> _refreshing = {};
  DateTime _now = DateTime.now();

  HardwareNotch? joinedNotch;
  int sessionCap = NotchLayout.defaultSessionCap;

  List<ProviderSnapshot> get snapshots => _snapshots;
  NotchEdge get edge => _edge;
  bool get isExpanded => _isExpanded;
  bool get isPinned => _isPinned;
  bool get isAlwaysOn => _isAlwaysOn;
  bool get staysOpen => _isPinned || _isAlwaysOn;
  int? get hoveredIndex => _hoveredIndex;
  bool get isHoveringSettings => _isHoveringSettings;
  Map<String, List<AgentSession>> get sessions => _sessions;
  Set<String> get refreshing => _refreshing;
  DateTime get now => _now;

  ProviderSnapshot? get hoveredSnapshot =>
      (_hoveredIndex != null && _hoveredIndex! >= 0 && _hoveredIndex! < _snapshots.length)
          ? _snapshots[_hoveredIndex!]
          : null;

  void setSnapshots(List<ProviderSnapshot> next) {
    _snapshots = next;
    notifyListeners();
  }

  void setEdge(NotchEdge next) {
    if (_edge == next) return;
    _edge = next;
    notifyListeners();
  }

  void setExpanded(bool next) {
    if (_isExpanded == next) return;
    _isExpanded = next;
    notifyListeners();
  }

  void setPinned(bool next) {
    if (_isPinned == next) return;
    _isPinned = next;
    notifyListeners();
  }

  void togglePinned() {
    if (_isAlwaysOn) return;
    _isPinned = !_isPinned;
    if (_isPinned) {
      _isExpanded = true;
    }
    notifyListeners();
  }

  void setAlwaysOn(bool next) {
    _isAlwaysOn = next;
    if (_isAlwaysOn) {
      _isPinned = false;
      _isExpanded = true;
    }
    notifyListeners();
  }

  void setHoveredIndex(int? next) {
    if (_hoveredIndex == next) return;
    _hoveredIndex = next;
    notifyListeners();
  }

  void setHoveringSettings(bool next) {
    if (_isHoveringSettings == next) return;
    _isHoveringSettings = next;
    notifyListeners();
  }

  void setSessions(String providerID, List<AgentSession> list) {
    _sessions[providerID] = list;
    _now = DateTime.now();
    notifyListeners();
  }

  void setRefreshing(Set<String> set) {
    _refreshing = set;
    notifyListeners();
  }

  void tickClock() {
    _now = DateTime.now();
    notifyListeners();
  }

  ActivitySummary? activityFor(String providerID) {
    final list = _sessions[providerID];
    if (list == null || list.isEmpty) return null;
    return ActivitySummary(sessions: list);
  }

  // --- Geometry & Measurements ---
  double get flare =>
      joinedNotch == null ? NotchLayout.curlRadius : NotchLayout.bezelFillet;

  double get endSpread => 0.0;

  double get notchLength => _isExpanded
      ? NotchLayout.shapeLength(cellCount: _snapshots.length, edge: _edge, flare: flare)
      : restingLength;

  double get notchDepth =>
      _isExpanded ? NotchLayout.bodyDepth(_edge) : restingDepth;

  double get restingLength =>
      _edge.isVertical ? NotchLayout.pillHeight : NotchLayout.pillWidth;

  double get restingDepth =>
      _edge.isVertical ? NotchLayout.pillWidth : NotchLayout.pillHeight;

  double get slackValue => NotchLayout.slack(edge: _edge);

  double get shapeLengthValue =>
      NotchLayout.shapeLength(cellCount: _snapshots.length, edge: _edge, flare: flare);

  double get notchLeadingInset =>
      slackValue + (_isExpanded ? 0.0 : (shapeLengthValue - notchLength) / 2);

  double get contentInset => 0.0;

  Size get notchSize => _edge.isVertical
      ? Size(notchDepth, notchLength)
      : Size(notchLength, notchDepth);

  Size panelSize({int? cellCount}) {
    final count = cellCount ?? _snapshots.length;
    final length = NotchLayout.shapeLength(cellCount: count, edge: _edge) + 2 * slackValue;
    final depth = NotchLayout.bodyDepth(_edge) +
        NotchLayout.tooltipDepth(edge: _edge);

    return _edge.isVertical ? Size(depth, length) : Size(length, depth);
  }

  double ringCenter(int index) {
    return NotchLayout.ringCenter(index: index, edge: _edge, flare: flare) + endSpread;
  }

  double get orbAlong =>
      NotchLayout.orbCenterAlong(cellCount: _snapshots.length, edge: _edge);

  double get orbInset => NotchLayout.orbInsetFromEdge;

  double get orbMergeScale => NotchLayout.orbMergeScale;

  bool get orbHugsCorner => false;

  double get orbArcRadius => NotchLayout.orbArcRadius;

  Offset get orbArcOffset => Offset.zero;

  bool isOnOrbHandle({required double along, required double across}) {
    final centerAlong = orbAlong;
    final centerAcross = orbInset;
    final dist = math.sqrt(
      math.pow(along - centerAlong, 2) + math.pow(across - centerAcross, 2),
    );
    return dist <= NotchLayout.orbHotZone / 2;
  }
}
