import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

enum JfSignalCoilMode {
  idle,
  focused,
  ready,
  warning,
}

/// 03 — compact triple-ring signal visual with ticks and scan line.
class JfSignalCoil extends StatefulWidget {
  const JfSignalCoil({
    super.key,
    this.mode = JfSignalCoilMode.idle,
    this.height = 60,
    this.forceStatic,
  });

  final JfSignalCoilMode mode;
  final double height;
  final bool? forceStatic;

  static const int ringCount = 3;

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
      duration: const Duration(milliseconds: 4200),
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
      _controller.value = 0.35;
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
    final phase = staticFrame ? 0.35 : progress;

    const pad = 8.0;
    final maxR = math.min(size.width, size.height) / 2 - pad;
    final radii = <double>[maxR * 0.34, maxR * 0.62, maxR * 0.92];

    // Side tick / marker lines
    for (var i = 0; i < 7; i++) {
      final y = pad + (size.height - pad * 2) * (i / 6);
      canvas.drawLine(Offset(4, y), Offset(9, y), dim);
      canvas.drawLine(
        Offset(size.width - 9, y),
        Offset(size.width - 4, y),
        dim,
      );
    }

    // Center node
    final coreBoost = mode == JfSignalCoilMode.focused ? 1.2 : 0.0;
    canvas.drawCircle(Offset(cx, cy), 3.0 + coreBoost, ink);

    for (var i = 0; i < JfSignalCoil.ringCount; i++) {
      final local = (phase + (1 - i) * 0.18) % 1.0;
      final pulse = 0.88 + 0.12 * math.sin(local * math.pi * 2);
      final safeR = math.min(radii[i] * pulse, maxR);
      canvas.drawCircle(Offset(cx, cy), safeR, i == 2 ? dim : ink);

      final nodeCount = 4 + i;
      for (var n = 0; n < nodeCount; n++) {
        final a = (n / nodeCount) * math.pi * 2 + phase * math.pi * 2 * 0.2;
        final p = Offset(cx + math.cos(a) * safeR, cy + math.sin(a) * safeR);
        canvas.drawCircle(p, 1.1, ink);
      }
    }

    // Horizontal scan line moving vertically (triangle wave).
    final scanPaint = Paint()
      ..color = mode == JfSignalCoilMode.warning
          ? JfColors.amber
          : JfColors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final t = staticFrame ? 0.45 : phase;
    final tri = t < 0.5 ? (t * 2) : (2 - t * 2);
    final scanY = pad + (size.height - pad * 2) * tri;
    canvas.drawLine(
      Offset(pad + 2, scanY),
      Offset(size.width - pad - 2, scanY),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TripleRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mode != mode ||
        oldDelegate.staticFrame != staticFrame;
  }
}
