import 'package:flutter/material.dart';

import 'jf_crt_monitor.dart';
import 'jf_indicator_board.dart';
import 'jf_signal_coil.dart';
import 'junkfeathers_tokens.dart';

/// Combined Panel 02 — CRT monitor plus lower signal/control band.
class JfMonitorModule extends StatelessWidget {
  const JfMonitorModule({
    super.key,
    this.lines = const [],
    this.crtBody,
    this.monitorHeight = 220,
    this.bandHeight = 72,
    this.warning = false,
    this.coilMode = JfSignalCoilMode.idle,
    this.forceStatic,
    this.showWaitingPrompt = true,
    this.crtScrollController,
  });

  final List<String> lines;

  /// When set, replaces CRT text lines (e.g. chronological results).
  final Widget? crtBody;

  final double monitorHeight;
  final double bandHeight;
  final bool warning;
  final JfSignalCoilMode coilMode;
  final bool? forceStatic;
  final bool showWaitingPrompt;
  final ScrollController? crtScrollController;

  /// Default CRT height after Panel 04 compact deck recovers vertical space.
  static const double defaultMonitorHeight = 300;

  /// Lower band height (square art + indicator board) — locked.
  static const double defaultBandHeight = 72;

  /// Responsive CRT height for supported phone viewports.
  static double resolveMonitorHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return (h * 0.40).clamp(260.0, 360.0);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = JfColors.white;

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
                body: crtBody,
                height: monitorHeight,
                warning: warning,
                showWaitingPrompt: showWaitingPrompt && crtBody == null,
                forceStaticPrompt: forceStatic,
                framed: false,
                scrollController: crtScrollController,
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
