enum AgentSessionState {
  busy,
  waiting,
  idle,
}

/// One agent session, whichever tool it belongs to.
class AgentSession {
  final String id;
  final String name;
  final String detail;
  final AgentSessionState state;
  final String? waitingFor;
  final DateTime since;

  const AgentSession({
    required this.id,
    required this.name,
    required this.detail,
    required this.state,
    this.waitingFor,
    required this.since,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          state == other.state &&
          detail == other.detail &&
          since == other.since;

  @override
  int get hashCode => id.hashCode ^ state.hashCode ^ since.hashCode;
}
