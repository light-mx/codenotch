import 'dart:async';
import 'dart:io';
import 'agent_activity_monitor.dart';
import 'agent_session.dart';

class AntigravityActivityMonitor implements AgentActivityMonitor {
  final Directory root;
  final Duration interval;
  final Duration staleAfter;

  List<AgentSession> _sessions = [];
  final StreamController<List<AgentSession>> _controller =
      StreamController<List<AgentSession>>.broadcast();
  Timer? _timer;

  AntigravityActivityMonitor({
    Directory? root,
    this.interval = const Duration(seconds: 2),
    this.staleAfter = const Duration(seconds: 45),
  }) : root = root ??
            Directory(
              '${Platform.environment['HOME'] ?? ''}/.gemini/antigravity/brain',
            );

  @override
  List<AgentSession> get sessions => _sessions;

  @override
  Stream<List<AgentSession>> get sessionsStream => _controller.stream;

  @override
  void start() {
    stop();
    _poll();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    _controller.close();
  }

  void _poll() {
    final found = readSessions(root: root, staleAfter: staleAfter);
    if (!_areListsEqual(found, _sessions)) {
      _sessions = found;
      _controller.add(_sessions);
    }
  }

  static List<AgentSession> readSessions({
    required Directory root,
    required Duration staleAfter,
    DateTime? now,
  }) {
    if (!root.existsSync()) return [];
    final current = now ?? DateTime.now();

    try {
      final entities = root.listSync();
      File? newestTranscript;
      DateTime? newestModified;

      for (final entity in entities) {
        if (entity is Directory) {
          final transcript = File(
            '${entity.path}/.system_generated/logs/transcript.jsonl',
          );
          if (transcript.existsSync()) {
            final mod = transcript.lastModifiedSync();
            if (newestModified == null || mod.isAfter(newestModified)) {
              newestModified = mod;
              newestTranscript = transcript;
            }
          }
        }
      }

      if (newestTranscript != null && newestModified != null) {
        if (current.difference(newestModified) <= staleAfter) {
          final parts = newestTranscript.parent.parent.parent.path.split('/');
          final convId = parts.isNotEmpty ? parts.last : 'session';
          return [
            AgentSession(
              id: 'antigravity.$convId',
              name: 'Antigravity',
              detail: 'Working',
              state: AgentSessionState.busy,
              since: newestModified,
            ),
          ];
        }
      }
    } catch (_) {}
    return [];
  }

  bool _areListsEqual(List<AgentSession> a, List<AgentSession> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
