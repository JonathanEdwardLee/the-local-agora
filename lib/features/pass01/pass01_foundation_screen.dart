import 'package:flutter/material.dart';

import '../../brand/junkfeathers_splash_spec.dart';

/// Minimal Pass 01 engineering shell — not the finished civic receiver UI.
class Pass01FoundationScreen extends StatelessWidget {
  const Pass01FoundationScreen({super.key});

  static const Color _oled = Color(0xFF0A0A0A);
  static const Color _bone = Color(0xFFE8E4D9);
  static const Color _dim = Color(0xFF9A968A);
  static const Color _line = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oled,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    JunkfeathersSplashSpec.brandName,
                    style: _labelStyle.copyWith(letterSpacing: 2.4),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: _line),
                  const SizedBox(height: 28),
                  Text(
                    JunkfeathersSplashSpec.productName,
                    style: _titleStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PASS 01 // KERYX FEASIBILITY',
                    style: _labelStyle.copyWith(color: _dim),
                  ),
                  const SizedBox(height: 36),
                  _statusRow('FLUTTER PROJECT', 'FOUNDATION READY'),
                  _statusRow('BACKEND SPIKE', 'FUNCTIONS WORKSPACE'),
                  _statusRow('SPLASH SEAM', 'SPEC LOCKED / ANIMATION PENDING'),
                  _statusRow('KERYX UI', 'DEFERRED TO LATER PASS'),
                  const Spacer(),
                  Container(height: 1, color: _line),
                  const SizedBox(height: 16),
                  Text(
                    'Engineering foundation only.\n'
                    'The full civic receiver interface arrives in a later pass.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'v0.1.0+1  ·  com.junkfeathers.localagora',
                    style: _labelStyle.copyWith(color: _dim, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: _labelStyle.copyWith(color: _dim)),
          ),
          Expanded(child: Text(value, style: _labelStyle)),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Courier',
    fontFamilyFallback: <String>['Courier New', 'monospace'],
    color: _bone,
    fontSize: 12,
    height: 1.35,
  );

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Courier',
    fontFamilyFallback: <String>['Courier New', 'monospace'],
    color: _bone,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.2,
  );

  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: 'Courier',
    fontFamilyFallback: <String>['Courier New', 'monospace'],
    color: _dim,
    fontSize: 12,
    height: 1.5,
  );
}
