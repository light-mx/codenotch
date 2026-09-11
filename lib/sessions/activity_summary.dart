import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import 'agent_session.dart';

enum ActivityState {
  working,
  waiting,
  idle,
}

class ActivitySummary {
  final ActivityState state;
  final List<AgentSession> sessions;

  ActivitySummary._({required this.state, required this.sessions});

  /// Null when nothing is running — the cell disappears rather than sitting
  /// there saying nothing.
  static ActivitySummary? create(List<AgentSession> sessions) {
    if (sessions.isEmpty) return null;
    final state = sessions.any((s) => s.state == AgentSessionState.waiting)
        ? ActivityState.waiting
        : sessions.any((s) => s.state == AgentSessionState.busy)
            ? ActivityState.working
            : ActivityState.idle;
    return ActivitySummary._(state: state, sessions: sessions);
  }

  factory ActivitySummary({required List<AgentSession> sessions}) {
    final state = sessions.any((s) => s.state == AgentSessionState.waiting)
        ? ActivityState.waiting
        : sessions.any((s) => s.state == AgentSessionState.busy)
            ? ActivityState.working
            : ActivityState.idle;
    return ActivitySummary._(state: state, sessions: sessions);
  }

  const ActivitySummary.withState({
    required this.state,
    required this.sessions,
  });

  /// One short word, for the tooltip.
  String get label {
    switch (state) {
      case ActivityState.working:
        return 'working';
      case ActivityState.waiting:
        return 'waiting';
      case ActivityState.idle:
        return 'idle';
    }
  }

  Color get color {
    switch (state) {
      case ActivityState.working:
        return Palette.textPrimary;
      case ActivityState.waiting:
        return Palette.watch;
      case ActivityState.idle:
        return Palette.ringTrack;
    }
  }

  List<AgentSession> get waitingSessions =>
      sessions.where((s) => s.state == AgentSessionState.waiting).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivitySummary &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          sessions.length == other.sessions.length;

  @override
  int get hashCode => state.hashCode ^ sessions.length.hashCode;
}
