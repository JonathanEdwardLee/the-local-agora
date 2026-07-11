import 'package:flutter/material.dart';
import 'junkfeathers_logo_painter.dart';
import 'junkfeathers_splash_tips.dart';

/// A reusable, app-neutral startup splash screen for Junkfeathers Tech.
class JunkfeathersSplash extends StatefulWidget {
  /// The destination screen to navigate to after the splash animation finishes.
  final Widget? destination;

  /// List of app-specific tips to show.
  final List<String> tips;

  /// Callback triggered when the splash screen completes.
  final VoidCallback? onComplete;

  /// Whether tips are enabled. Defaults to true.
  final bool tipsEnabled;

  /// Manual override to enable/disable reduced motion.
  /// If null, accessibility settings from MediaQuery are queried.
  final bool? reducedMotionOverride;

  /// Explicit tip index for deterministic behavior (e.g. testing).
  final int? deterministicTipIndex;

  const JunkfeathersSplash({
    super.key,
    this.destination,
    required this.tips,
    this.onComplete,
    this.tipsEnabled = true,
    this.reducedMotionOverride,
    this.deterministicTipIndex,
  }) : assert(destination != null || onComplete != null,
            'Either destination or onComplete must be provided');

  @override
  State<JunkfeathersSplash> createState() => _JunkfeathersSplashState();
}

class _JunkfeathersSplashState extends State<JunkfeathersSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late final String _splashTip;
  bool _transitioned = false;

  // Named timing constants total exactly 2870 ms
  static const int kRevealDurationMs = 990;
  static const int kHoldDurationMs = 1000;
  static const int kHideDurationMs = 880;
  static const int kTotalDurationMs =
      kRevealDurationMs + kHoldDurationMs + kHideDurationMs;

  @override
  void initState() {
    super.initState();

    // Select tip once per widget mount
    _splashTip = selectSplashTip(
      widget.tips,
      deterministicIndex: widget.deterministicTipIndex,
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kTotalDurationMs),
    );

    _ctrl.forward().then((_) {
      _transition();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _transition() {
    if (!mounted || _transitioned) return;
    _transitioned = true;

    if (widget.onComplete != null) {
      widget.onComplete!();
    }

    if (widget.destination != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.destination!),
      );
    }
  }

  bool get _isReducedMotion {
    if (widget.reducedMotionOverride != null) {
      return widget.reducedMotionOverride!;
    }
    try {
      return MediaQuery.disableAnimationsOf(context);
    } catch (_) {
      try {
        return MediaQuery.of(context).disableAnimations;
      } catch (_) {
        return false;
      }
    }
  }

  double _getLogoOpacity(SplashPhase phase, double progress) {
    if (phase == SplashPhase.reveal) {
      final double tOriginal = progress * 0.70;
      if (tOriginal < 0.20) {
        final double phaseProgress = tOriginal / 0.20;
        return (0.04 + 0.96 * phaseProgress).clamp(0.0, 1.0);
      }
      return 1.0;
    } else if (phase == SplashPhase.hold) {
      return 1.0;
    } else {
      // SplashPhase.hide
      if (progress > 0.62) {
        return (1.0 - ((progress - 0.62) / 0.38)).clamp(0.0, 1.0);
      }
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = _isReducedMotion;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final double elapsedMs = _ctrl.value * kTotalDurationMs;

          SplashPhase phase;
          double phaseProgress;

          if (elapsedMs < kRevealDurationMs) {
            phase = SplashPhase.reveal;
            phaseProgress = elapsedMs / kRevealDurationMs;
          } else if (elapsedMs < kRevealDurationMs + kHoldDurationMs) {
            phase = SplashPhase.hold;
            phaseProgress = (elapsedMs - kRevealDurationMs) / kHoldDurationMs;
          } else {
            phase = SplashPhase.hide;
            phaseProgress =
                (elapsedMs - (kRevealDurationMs + kHoldDurationMs)) /
                    kHideDurationMs;
          }

          phaseProgress = phaseProgress.clamp(0.0, 1.0);
          final double logoOpacity = _getLogoOpacity(phase, phaseProgress);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: JunkfeathersSplashBackdropPainter(
                  phase: phase,
                  progress: phaseProgress,
                  reducedMotion: reducedMotion,
                ),
                child: const SizedBox.expand(),
              ),
              if (logoOpacity > 0.02)
                Center(
                  child: Opacity(
                    opacity: logoOpacity,
                    child: SizedBox(
                      width: 236,
                      height: 118,
                      child: CustomPaint(
                        painter: JunkfeathersLogoMarkPainter(
                          phase: phase,
                          progress: phaseProgress,
                          reducedMotion: reducedMotion,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.tipsEnabled && _splashTip.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Opacity(
                      opacity: 0.88,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _splashTip,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontFamily: 'monospace',
                            fontSize: 8,
                            letterSpacing: 0.3,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
