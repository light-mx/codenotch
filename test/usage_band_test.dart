import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/model/usage_band.dart';

void main() {
  group('UsageBandTests', () {
    test('bands match the design frame', () {
      expect(UsageBand.bandFor(0.21), UsageBand.ample);
      expect(UsageBand.bandFor(0.52), UsageBand.watch);
      expect(UsageBand.bandFor(0.73), UsageBand.critical);
    });

    test('boundaries', () {
      expect(UsageBand.bandFor(0.0), UsageBand.ample);
      expect(UsageBand.bandFor(0.4999), UsageBand.ample);
      expect(UsageBand.bandFor(0.50), UsageBand.watch);
      expect(UsageBand.bandFor(0.6999), UsageBand.watch);
      expect(UsageBand.bandFor(0.70), UsageBand.critical);
      expect(UsageBand.bandFor(0.9999), UsageBand.critical);
      expect(UsageBand.bandFor(1.0), UsageBand.exhausted);
      expect(UsageBand.bandFor(1.4), UsageBand.exhausted);
    });
  });
}
