import 'dart:async';
import 'agent_session.dart';

abstract class AgentActivityMonitor {
  List<AgentSession> get sessions;
  Stream<List<AgentSession>> get sessionsStream;
  void start();
  void stop();
  void dispose();
}
