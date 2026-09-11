import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/design_system/palette.dart';
import 'package:codenotch/sessions/activity_summary.dart';
import 'package:codenotch/sessions/agent_session.dart';

void main() {
  group('ActivitySummaryTests', () {
    AgentSession session(AgentSessionState state, {String name = 's'}) {
      return AgentSession(
        id: name,
        name: name,
        detail: 'Terminal · $name',
        state: state,
        since: DateTime.now(),
      );
    }

    test('nothing running means no cell', () {
      expect(ActivitySummary.create([]), isNull);
    });

    test('waiting outranks working', () {
      final summary = ActivitySummary.create([
        session(AgentSessionState.busy),
        session(AgentSessionState.waiting),
        session(AgentSessionState.idle),
      ]);
      expect(summary?.state, ActivityState.waiting);
      expect(summary?.label, 'waiting');
    });

    test('working outranks idle', () {
      final summary = ActivitySummary.create([
        session(AgentSessionState.idle),
        session(AgentSessionState.busy),
      ]);
      expect(summary?.state, ActivityState.working);
      expect(summary?.label, 'working');
    });

    test('all idle reads as idle', () {
      final summary = ActivitySummary.create([
        session(AgentSessionState.idle),
        session(AgentSessionState.idle),
      ]);
      expect(summary?.state, ActivityState.idle);
      expect(summary?.label, 'idle');
    });

    test('working is neutral and waiting is not', () {
      final working = ActivitySummary.create([session(AgentSessionState.busy)]);
      expect(working?.color, Palette.textPrimary);

      final waiting = ActivitySummary.create([session(AgentSessionState.waiting)]);
      expect(waiting?.color, Palette.watch);
    });
  });
}
