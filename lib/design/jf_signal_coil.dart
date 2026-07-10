import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

enum JfSignalCoilMode {
  idle,
  focused,
  ready,
  warning,
}

/// 03 — restrained procedural SIGNAL COIL visual (Stage 1).
///
/// No network, no fake scan progress. Reacts only to truthful local mode.
class JfSignalCoil extends StatefulWidget {
  const JfSignalCoil({
    super.key,
    this.mode = JfSignalCoilMode.idle,
    this.height = 120,
    this.forceStatic,
  });

  final JfSignalCoilMode mode;
  final double height;

  /// When true, always static. When null, follows reduced-motion settings.
  final bool? forceStatic;

  @override
  State<JfSignalCoil> createState() => _JfSignalCoilState();
}

class _JfSignalCoilState extends State<JfSignalCoil>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );
  }

  @override
  void didUpdateWidget(covariant JfSignalCoil oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (mounted) _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  bool get _reduceMotion {
    if (widget.forceStatic == true) return true;
    if (widget.forceStatic == false) return false;
    return MediaQuery.disableAnimationsOf(context);
  }

  void _syncAnimation() {
    final shouldAnimate = !_reduceMotion && _appActive;
    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0.18;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Signal coil display, ${widget.mode.name} mode',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: JfColors.black,
          border: Border.all(
            color: widget.mode == JfSignalCoilMode.warning
                ? JfColors.amber
                : JfColors.white54,
            width: JfBorders.secondary,
          ),
          borderRadius: JfBorders.square,
        ),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _SignalCoilPainter(
                  progress: _controller.value,
                  mode: widget.mode,
                  staticFrame: _reduceMotion || !_controller.isAnimating,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignalCoilPainter extends CustomPainter {
  _SignalCoilPainter({
    required this.progress,
    required this.mode,
    required this.staticFrame,
  });

  final double progress;
  final JfSignalCoilMode mode;
  final bool staticFrame;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = mode == JfSignalCoilMode.warning
          ? JfColors.amber
          : JfColors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dim = Paint()
      ..color = JfColors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final phase = staticFrame ? 0.18 : progress;

    // Outer frame ticks
    for (var i = 0; i < 12; i++) {
      final x = 8.0 + (size.width - 16) * (i / 11);
      canvas.drawLine(Offset(x, 6), Offset(x, 10), dim);
      canvas.drawLine(
        Offset(x, size.height - 6),
        Offset(x, size.height - 10),
        dim,
      );
    }

    // Central coil / transmitter
    final coreR = 10.0 + (mode == JfSignalCoilMode.focused ? 2 : 0);
    canvas.drawCircle(Offset(cx, cy), coreR, ink);
    canvas.drawCircle(Offset(cx, cy), coreR * 0.45, ink);
    canvas.drawLine(Offset(cx, cy - coreR - 8), Offset(cx, cy - coreR), ink);
    canvas.drawLine(Offset(cx, cy + coreR), Offset(cx, cy + coreR + 8), ink);

    // Symmetrical signal arcs
    final arcCount = mode == JfSignalCoilMode.ready ? 4 : 3;
    for (var i = 1; i <= arcCount; i++) {
      final r = coreR + 14.0 * i + 6 * math.sin(phase * math.pi * 2 + i);
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.5, false, ink);
      canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.5, false, ink);
    }

    // Sweep marks / nodes
    final sweep = phase * math.pi * 2;
    for (var i = 0; i < 6; i++) {
      final a = sweep + (i * math.pi / 3);
      final r = coreR + 38;
      final p = Offset(cx + math.cos(a) * r, cy + math.sin(a) * r);
      canvas.drawCircle(p, 1.6, ink);
    }

    // Horizontal pulse lines
    final pulseY = cy + 36 * math.sin(phase * math.pi * 2);
    canvas.drawLine(Offset(12, pulseY), Offset(size.width - 12, pulseY), dim);
  }

  @override
  bool shouldRepaint(covariant _SignalCoilPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mode != mode ||
        oldDelegate.staticFrame != staticFrame;
  }
}
