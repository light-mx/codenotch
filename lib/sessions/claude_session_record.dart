import 'dart:io';
import 'package:intl/intl.dart';
import 'agent_session.dart';

class ClaudeSessionRecord {
  final int pid;
  final DateTime? startedAt;
  final AgentSession session;

  const ClaudeSessionRecord({
    required this.pid,
    this.startedAt,
    required this.session,
  });

  static ClaudeSessionRecord? fromJson(Map<String, dynamic> json) {
    final pid = (json['pid'] as num?)?.toInt();
    final cwd = json['cwd'] as String?;
    if (pid == null || cwd == null) return null;

    final raw = json['status'] as String?;
    final tempo = json['tempo'] as String?;

    AgentSessionState state = AgentSessionState.idle;
    if (tempo == 'blocked' || raw == 'waiting') {
      state = AgentSessionState.waiting;
    } else if (tempo == 'active' || raw == 'busy') {
      state = AgentSessionState.busy;
    }

    final double? millis = (json['statusUpdatedAt'] as num?)?.toDouble() ??
        (json['updatedAt'] as num?)?.toDouble();

    DateTime? startedAt;
    if (json['startedAt'] != null) {
      final double s = (json['startedAt'] as num).toDouble();
      startedAt = DateTime.fromMillisecondsSinceEpoch(s.toInt());
    } else if (json['procStart'] is String) {
      startedAt = parseProcStart(json['procStart'] as String);
    }

    final folder = cwd.split('/').where((s) => s.isNotEmpty).lastOrNull ?? cwd;
    final String name = (json['name'] as String?) ?? folder;
    final String surfaceStr = surface(json['entrypoint'] as String?);

    final session = AgentSession(
      id: 'claude.$pid',
      name: name,
      detail: '$surfaceStr · $folder',
      state: state,
      waitingFor: (json['waitingFor'] as String?) ?? (json['needs'] as String?),
      since: millis != null
          ? DateTime.fromMillisecondsSinceEpoch(millis.toInt())
          : DateTime.now(),
    );

    return ClaudeSessionRecord(
      pid: pid,
      startedAt: startedAt,
      session: session,
    );
  }

  static String surface(String? entrypoint) {
    switch (entrypoint) {
      case 'claude-desktop':
      case 'claude-desktop-3p':
        return 'Desktop';
      case 'claude-vscode':
        return 'VS Code';
      case 'local-agent':
        return 'Agent';
      default:
        return 'Terminal';
    }
  }

  static DateTime? parseProcStart(String text) {
    try {
      final collapsed = text.split(' ').where((s) => s.isNotEmpty).join(' ');
      // Format: "Fri Aug 28 05:15:20 2026"
      final formatter = DateFormat('EEE MMM d HH:mm:ss yyyy', 'en_US');
      return formatter.parse(collapsed, true).toUtc();
    } catch (_) {
      return null;
    }
  }
}
