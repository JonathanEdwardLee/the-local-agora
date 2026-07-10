import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

enum JfSignalCoilMode {
  idle,
  focused,
  ready,
  warning,
}

/// 03 — compact triple-ring signal visual (Stage 1 refinement).
///
/// Three concentric rings stay fully inside the art box. No network implication.
class JfSignalCoil extends StatefulWidget {
  const JfSignalCoil({
    super.key,
    this.mode = JfSignalCoilMode.idle,
    this.height = 72,
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
      duration: const Duration(milliseconds: 3600),
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
      _controller.value = 0.22;
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
      label: 'Signal coil display, ${widget.mode.name} mode, three rings',
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
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TripleRingPainter(
                    progress: _controller.value,
                    mode: widget.mode,
                    staticFrame: _reduceMotion || !_controller.isAnimating,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TripleRingPainter extends CustomPainter {
  _TripleRingPainter({
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
      ..strokeWidth = 1.2;

    final dim = Paint()
      ..color = JfColors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final phase = staticFrame ? 0.22 : progress;

    // Padding so outer ring never touches the border.
    const pad = 10.0;
    final maxR = math.min(size.width, size.height) / 2 - pad;
    final radii = <double>[maxR * 0.34, maxR * 0.62, maxR * 0.92];

    // Center node
    final coreBoost = mode == JfSignalCoilMode.focused ? 1.5 : 0.0;
    canvas.drawCircle(Offset(cx, cy), 3.5 + coreBoost, ink);

    for (var i = 0; i < 3; i++) {
      // Phased pulse: inner first, then middle, then outer.
      final local = (phase + (1 - i) * 0.18) % 1.0;
      final pulse = 0.85 + 0.15 * math.sin(local * math.pi * 2);
      final r = radii[i] * pulse;
      // Hard clamp inside pad.
      final safeR = math.min(r, maxR);
      canvas.drawCircle(Offset(cx, cy), safeR, i == 2 ? dim : ink);

      // Subtle nodes on each ring
      final nodeCount = 4 + i;
      for (var n = 0; n < nodeCount; n++) {
        final a = (n / nodeCount) * math.pi * 2 + phase * math.pi * 2 * 0.25;
        final p = Offset(cx + math.cos(a) * safeR, cy + math.sin(a) * safeR);
        canvas.drawCircle(p, 1.2, ink);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TripleRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mode != mode ||
        oldDelegate.staticFrame != staticFrame;
  }
}
