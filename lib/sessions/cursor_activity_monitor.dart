import 'dart:async';
import 'dart:io';
import 'agent_activity_monitor.dart';
import 'agent_session.dart';

class CursorActivityMonitor implements AgentActivityMonitor {
  final Duration interval;
  List<AgentSession> _sessions = [];
  final StreamController<List<AgentSession>> _controller =
      StreamController<List<AgentSession>>.broadcast();
  Timer? _timer;

  CursorActivityMonitor({this.interval = const Duration(seconds: 3)});

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
    // Reads Cursor composer state if available
    final dbFile = File(
      '${Platform.environment['HOME'] ?? ''}/Library/Application Support/Cursor/User/globalStorage/state.vscdb',
    );
    if (!dbFile.existsSync()) {
      if (_sessions.isNotEmpty) {
        _sessions = [];
        _controller.add(_sessions);
      }
      return;
    }
  }
}

class CodexActivityMonitor implements AgentActivityMonitor {
  final Duration interval;
  List<AgentSession> _sessions = [];
  final StreamController<List<AgentSession>> _controller =
      StreamController<List<AgentSession>>.broadcast();
  Timer? _timer;

  CodexActivityMonitor({this.interval = const Duration(seconds: 3)});

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

  void _poll() {}
}

class GrokActivityMonitor implements AgentActivityMonitor {
  final Duration interval;
  List<AgentSession> _sessions = [];
  final StreamController<List<AgentSession>> _controller =
      StreamController<List<AgentSession>>.broadcast();
  Timer? _timer;

  GrokActivityMonitor({this.interval = const Duration(seconds: 3)});

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

  void _poll() {}
}
