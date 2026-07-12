import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Decorative non-interactive machine indicator board.
/// Purely visual — does not imply scanning or backend status.
class JfIndicatorBoard extends StatefulWidget {
  const JfIndicatorBoard({
    super.key,
    this.height = 72,
    this.columns = 8,
    this.rows = 3,
    this.forceStatic,
  });

  final double height;
  final int columns;
  final int rows;
  final bool? forceStatic;

  @override
  State<JfIndicatorBoard> createState() => _JfIndicatorBoardState();
}

class _JfIndicatorBoardState extends State<JfIndicatorBoard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late List<bool> _lit;
  late List<bool> _target;
  final _rng = math.Random(42);
  bool _appActive = true;
  DateTime _lastFlicker = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lit = _randomPattern();
    _target = List<bool>.from(_lit);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..addListener(_onTick);
  }

  List<bool> _randomPattern() {
    final count = widget.rows * widget.columns;
    return List<bool>.generate(count, (_) => _rng.nextDouble() > 0.45);
  }

  void _onTick() {
    if (_reduceMotion || !_appActive) return;
    final t = _controller.value;
    final inFlicker = t > 0.55 && t < 0.78;
    final now = DateTime.now();
    if (inFlicker &&
        now.difference(_lastFlicker) > const Duration(milliseconds: 180)) {
      _lastFlicker = now;
      final next = List<bool>.from(_lit);
      final flips = 2 + _rng.nextInt(3);
      for (var i = 0; i < flips; i++) {
        final idx = _rng.nextInt(next.length);
        next[idx] = !next[idx];
      }
      if (mounted) setState(() => _lit = next);
    } else if (t >= 0.78 && t < 0.85) {
      if (mounted) setState(() => _lit = List<bool>.from(_target));
    } else if (t >= 0.98) {
      _target = _randomPattern();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (mounted) _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant JfIndicatorBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  bool get _reduceMotion {
    if (widget.forceStatic == true) return true;
    if (widget.forceStatic == false) return false;
    return MediaQuery.disableAnimationsOf(context);
  }

  void _sync() {
    final animate = !_reduceMotion && _appActive;
    if (animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Decorative machine indicator board',
      excludeSemantics: true,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: JfColors.black,
            border: Border.all(
              color: JfColors.white54,
              width: JfBorders.secondary,
            ),
            borderRadius: JfBorders.square,
          ),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(JfSpacing.xs),
              child: Column(
                children: List.generate(widget.rows, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(widget.columns, (col) {
                        final idx = row * widget.columns + col;
                        final on = idx < _lit.length && _lit[idx];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: on ? JfColors.white70 : JfColors.black,
                                border: Border.all(
                                  color: on ? JfColors.white : JfColors.white24,
                                  width: JfBorders.secondary,
                                ),
                                borderRadius: JfBorders.square,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
