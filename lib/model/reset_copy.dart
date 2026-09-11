import 'package:intl/intl.dart';

/// "Resets in 51 min" under an hour, "Resets Thu 12:00 AM" within the week,
/// "Resets Sep 28" beyond it.
abstract final class ResetCopy {
  static String textFor(DateTime resetsAt, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final int seconds = resetsAt.difference(current).inSeconds;
    if (seconds <= 0) return 'Resetting…';

    // Rounding, not truncation, so 50m40s reads as 51 rather than 50.
    final int minutes = ((resetsAt.difference(current).inMilliseconds / 1000) / 60).round();
    if (minutes < 60) {
      return 'Resets in ${minutes < 1 ? 1 : minutes} min';
    }

    final int days = daysApart(current, resetsAt);
    if (days >= 7) {
      final formatter = DateFormat('MMM d');
      return 'Resets ${formatter.format(resetsAt)}';
    }

    final formatter = DateFormat('E h:mm a');
    return 'Resets ${formatter.format(resetsAt)}';
  }

  /// Whole days between two instants, counted by calendar day rather than by
  /// dividing seconds — so a clock change cannot shift the answer.
  static int daysApart(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
}
