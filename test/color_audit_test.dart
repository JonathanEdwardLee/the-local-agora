import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';

void main() {
  test('Local Agora feature UI does not reference amber/yellow tokens', () {
    final roots = ['lib/features', 'lib/services', 'lib/data', 'lib/brand'];
    final offenders = <String>[];
    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final text = entity.readAsStringSync();
        if (text.contains('JfColors.amber') ||
            text.contains('Colors.amber') ||
            text.contains('Colors.yellow') ||
            text.contains('0xFFC9A227') ||
            text.contains('Color(0xFFFF')) {
          offenders.add(entity.path);
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('design chrome warning paths use white not amber', () {
    for (final path in [
      'lib/design/jf_crt_monitor.dart',
      'lib/design/jf_monitor_module.dart',
      'lib/design/jf_oled_toast.dart',
      'lib/design/jf_waiting_scan_prompt.dart',
      'lib/design/jf_status_line.dart',
      'lib/design/jf_signal_coil.dart',
    ]) {
      final text = File(path).readAsStringSync();
      expect(text.contains('JfColors.amber'), isFalse, reason: path);
    }
  });

  test('approved Local Agora palette tokens exist', () {
    expect(JfColors.black.toARGB32() & 0xFFFFFFFF, 0xFF000000);
    expect(JfColors.white.toARGB32() & 0xFFFFFFFF, 0xFFFFFFFF);
    expect(JfColors.signalGreen, JfColors.validationPhosphor);
  });

  test('production fixture has no example.com agora-demo URLs', () {
    final fixture = File(
      'lib/data/fixtures/springfield_keryx_demo_signals.dart',
    ).readAsStringSync();
    expect(fixture.contains('https://example.com'), isFalse);
    expect(fixture.contains('agora-demo/'), isFalse);
    expect(RegExp(r"sourceUrl:\s*Uri\.parse").hasMatch(fixture), isFalse);
  });
}
