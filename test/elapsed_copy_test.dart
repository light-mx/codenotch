import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/model/elapsed_copy.dart';

void main() {
  group('ElapsedCopyTests', () {
    final now = DateTime.fromMillisecondsSinceEpoch(1787900000 * 1000, isUtc: true);

    test('fresh changes read as just now', () {
      expect(ElapsedCopy.textSince(now.subtract(const Duration(seconds: 5)), now: now), 'just now');
      expect(ElapsedCopy.textSince(now.subtract(const Duration(seconds: 44)), now: now), 'just now');
    });

    test('minutes', () {
      expect(ElapsedCopy.textSince(now.subtract(const Duration(minutes: 6)), now: now), '6 min');
      expect(ElapsedCopy.textSince(now.subtract(const Duration(minutes: 59)), now: now), '59 min');
    });

    test('hours', () {
      expect(ElapsedCopy.textSince(now.subtract(const Duration(hours: 1)), now: now), '1 hr');
      expect(ElapsedCopy.textSince(now.subtract(const Duration(minutes: 65)), now: now), '1 hr 5 min');
    });

    test('future timestamps do not go negative', () {
      expect(ElapsedCopy.textSince(now.add(const Duration(seconds: 120)), now: now), 'just now');
    });
  });
}
