import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/services/keryx/keryx_service.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';

void main() {
  test('public scan/results surfaces avoid Keryx and SIGNAL jargon', () {
    final paths = [
      'lib/features/scan_control/scan_control_screen.dart',
      'lib/features/discovery/crt_signal_record.dart',
      'lib/features/discovery/crt_searching_animation.dart',
      'lib/design/jf_search_parameter_dialog.dart',
    ];
    for (final path in paths) {
      final text = File(path).readAsStringSync();
      expect(text.contains('LIVE KERYX SIGNALS'), isFalse, reason: path);
      expect(text.contains('VERIFIED KERYX SIGNALS'), isFalse, reason: path);
      expect(text.contains('SIGNALS FOUND'), isFalse, reason: path);
      expect(text.contains('SCAN THE AGORA'), isFalse, reason: path);
      expect(text.contains('OPEN RECORD'), isFalse, reason: path);
      expect(text.contains('WINDOW //'), isFalse, reason: path);
      expect(text.contains('SIGNAL TYPE'), isFalse, reason: path);
    }
  });

  test('eventsFoundLabel singular and plural', () {
    final req = const KeryxScanRequest(
      location: 'X',
      timeWindow: TimeWindow.tonight,
      category: EventCategory.music,
    );
    expect(
      KeryxScanResult(
        outcome: KeryxScanOutcome.results,
        request: req,
        signals: const [],
      ).eventsFoundLabel(),
      '0 EVENTS FOUND',
    );
  });

  test('initial ScanControlState has no presets', () {
    const state = ScanControlState();
    expect(state.locationText, isEmpty);
    expect(state.timeWindow, isNull);
    expect(state.category, isNull);
  });
}
