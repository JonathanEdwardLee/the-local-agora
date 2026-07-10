import 'package:flutter/material.dart';

import 'jf_crt_monitor.dart';
import 'jf_indicator_board.dart';
import 'jf_signal_coil.dart';
import 'junkfeathers_tokens.dart';

/// Combined Panel 02 — CRT monitor plus lower signal/control band.
class JfMonitorModule extends StatelessWidget {
  const JfMonitorModule({
    super.key,
    required this.lines,
    this.monitorHeight = 220,
    this.bandHeight = 72,
    this.warning = false,
    this.coilMode = JfSignalCoilMode.idle,
    this.forceStatic,
    this.showWaitingPrompt = true,
  });

  final List<String> lines;
  final double monitorHeight;
  final double bandHeight;
  final bool warning;
  final JfSignalCoilMode coilMode;
  final bool? forceStatic;
  final bool showWaitingPrompt;

  /// Default CRT height after absorbing former panel 03 space.
  static const double defaultMonitorHeight = 220;

  /// Lower band height (square art + indicator board).
  static const double defaultBandHeight = 72;

  @override
  Widget build(BuildContext context) {
    final borderColor = warning ? JfColors.amber : JfColors.white;

    return Semantics(
      label: 'Machine monitor module',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: JfColors.black,
          border: Border.all(color: borderColor, width: JfBorders.primary),
          borderRadius: JfBorders.square,
        ),
        child: Padding(
          padding: const EdgeInsets.all(JfSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JfCrtMonitor(
                lines: lines,
                height: monitorHeight,
                warning: warning,
                showWaitingPrompt: showWaitingPrompt,
                forceStaticPrompt: forceStatic,
                framed: false,
              ),
              const SizedBox(height: JfSpacing.sm),
              SizedBox(
                height: bandHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: bandHeight,
                      child: JfSignalCoil(
                        mode: coilMode,
                        height: bandHeight,
                        forceStatic: forceStatic,
                        square: true,
                      ),
                    ),
                    const SizedBox(width: JfSpacing.sm),
                    Expanded(
                      child: JfIndicatorBoard(
                        height: bandHeight,
                        forceStatic: forceStatic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
