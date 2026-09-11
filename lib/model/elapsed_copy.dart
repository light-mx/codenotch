/// "how long has it been like this" — the second half of answering "is Claude
/// still working".
abstract final class ElapsedCopy {
  /// The same span, phrased as a point in the past.
  static String ago({required DateTime since, DateTime? now}) {
    final elapsed = text(since: since, now: now);
    return elapsed == 'just now' ? elapsed : '$elapsed ago';
  }

  static String text({required DateTime since, DateTime? now}) {
    final current = now ?? DateTime.now();
    final double seconds = (current.difference(since).inMilliseconds / 1000).clamp(0, double.infinity);
    if (seconds < 45) return 'just now';

    final int minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '${minutes < 1 ? 1 : minutes} min';
    }

    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    if (rest == 0) return '$hours hr';
    return '$hours hr $rest min';
  }
}
