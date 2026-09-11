import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/model/reset_copy.dart';
import 'package:codenotch/model/usage_model.dart';

void main() {
  group('ResetCopyTests', () {
    final now = DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000, isUtc: true);

    test('relative under an hour', () {
      expect(
        ResetCopy.textFor(now.add(const Duration(minutes: 51)), now: now),
        'Resets in 51 min',
      );
    });

    test('rounds to the nearest minute', () {
      expect(
        ResetCopy.textFor(now.add(const Duration(minutes: 50, seconds: 20)), now: now),
        'Resets in 50 min',
      );
      expect(
        ResetCopy.textFor(now.add(const Duration(minutes: 50, seconds: 40)), now: now),
        'Resets in 51 min',
      );
    });

    test('switches to absolute at sixty minutes', () {
      final atTheEdge = ResetCopy.textFor(now.add(const Duration(minutes: 60)), now: now);
      expect(atTheEdge.contains('min'), isFalse);
      expect(atTheEdge.startsWith('Resets '), isTrue);

      final justUnder = ResetCopy.textFor(now.add(const Duration(minutes: 59, seconds: 20)), now: now);
      expect(justUnder, 'Resets in 59 min');

      final rounding = ResetCopy.textFor(now.add(const Duration(minutes: 59, seconds: 40)), now: now);
      expect(rounding.contains('min'), isFalse);
    });

    test('absolute time uses a colon', () {
      final text = ResetCopy.textFor(now.add(const Duration(hours: 6)), now: now);
      expect(text.contains(':'), isTrue, reason: 'expected a colon in $text');
    });

    test('past resets read as resetting', () {
      expect(
        ResetCopy.textFor(now.subtract(const Duration(seconds: 5)), now: now),
        'Resetting…',
      );
    });
  });

  group('ResetCopyDistantDateTests', () {
    DateTime parse(String iso) => DateTime.parse(iso);

    test('a month away shows the date not a weekday', () {
      final text = ResetCopy.textFor(
        parse('2026-09-28T15:55:00+07:00'),
        now: parse('2026-09-01T23:30:00+07:00'),
      );
      expect(text.contains('28'), isTrue, reason: 'day of month missing: $text');
      expect(text.contains('Mon'), isFalse, reason: 'four weeks out should not read as weekday');
    });

    test('within the week keeps the weekday and time', () {
      final text = ResetCopy.textFor(
        parse('2026-09-04T12:00:00+07:00'),
        now: parse('2026-09-01T23:30:00+07:00'),
      );
      expect(text.contains('12:00'), isTrue, reason: 'expected a time: $text');
    });

    test('seven days is already too far for a weekday', () {
      final text = ResetCopy.textFor(
        parse('2026-09-08T12:00:00+07:00'),
        now: parse('2026-09-01T12:00:00+07:00'),
      );
      expect(text.contains('8'), isTrue, reason: 'expected a date: $text');
    });

    test('counts whole calendar days not elapsed hours', () {
      expect(
        ResetCopy.daysApart(
          parse('2026-09-01T23:30:00+07:00'),
          parse('2026-09-02T00:30:00+07:00'),
        ),
        1,
      );
    });
  });

  group('WindowSummaryTests', () {
    LimitWindow window(double fraction) {
      return LimitWindow(id: 'w', label: 'Monthly limit', usedFraction: fraction);
    }

    test('it shows both ends of the same figure', () {
      expect(window(0.12).summary, '12% Used · 88% left');
    });

    test('the halves always sum to a hundred', () {
      for (int percent = 0; percent <= 100; percent += 7) {
        final text = window(percent / 100.0).summary;
        final match = RegExp(r'(\d+)% Used · (\d+)% left').firstMatch(text);
        expect(match, isNotNull, reason: 'format mismatch: $text');
        final used = int.parse(match!.group(1)!);
        final left = int.parse(match.group(2)!);
        expect(used + left, 100, reason: '$text does not add up to 100');
      }
    });

    test('an overspent limit never goes negative', () {
      expect(window(1.04).summary, '104% Used · 0% left');
    });

    test('counts are untouched', () {
      expect(
        const LimitWindow(id: 'w', label: 'Requests', used: 8).summary,
        '8 used',
      );
      expect(
        const LimitWindow(id: 'w', label: 'Requests', remaining: 3).summary,
        '3 left',
      );
    });
  });
}
