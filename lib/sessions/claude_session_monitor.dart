import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'agent_activity_monitor.dart';
import 'agent_session.dart';
import 'claude_session_record.dart';
import 'process_liveness.dart';

class ClaudeSessionMonitor implements AgentActivityMonitor {
  final Directory directory;
  final Duration interval;

  List<AgentSession> _sessions = [];
  final StreamController<List<AgentSession>> _controller =
      StreamController<List<AgentSession>>.broadcast();
  Timer? _timer;

  ClaudeSessionMonitor({
    Directory? directory,
    this.interval = const Duration(seconds: 2),
  }) : directory = directory ??
            Directory(
              '${Platform.environment['HOME'] ?? ''}/.claude/sessions',
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
    final found = readSessions(directory: directory);
    if (!_areListsEqual(found, _sessions)) {
      _sessions = found;
      _controller.add(_sessions);
    }
  }

  static List<AgentSession> readSessions({required Directory directory}) {
    if (!directory.existsSync()) return [];
    final List<AgentSession> active = [];

    try {
      final files = directory.listSync().whereType<File>();
      for (final file in files) {
        if (!file.path.endsWith('.json')) continue;
        try {
          final content = file.readAsStringSync();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final record = ClaudeSessionRecord.fromJson(json);
          if (record != null) {
            if (ProcessLiveness.isAlive(record.pid, startedAt: record.startedAt)) {
              active.add(record.session);
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    return active;
  }

  bool _areListsEqual(List<AgentSession> a, List<AgentSession> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
