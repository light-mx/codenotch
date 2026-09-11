import 'dart:io';

/// Is a pid still running, and is it still the same process?
abstract final class ProcessLiveness {
  static bool isAlive(int pid, {DateTime? startedAt}) {
    try {
      final res = Process.runSync('kill', ['-0', pid.toString()]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
