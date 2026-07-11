import 'dart:math';
import 'package:flutter/material.dart';

/// The three explicit animation phases of the universal Junkfeathers splash.
enum SplashPhase {
  reveal,
  hold,
  hide,
}

/// Renders the full-bleed boot interference: bands, tears, scanlines.
/// No random star noise or flashing occurs during the hold phase.
class JunkfeathersSplashBackdropPainter extends CustomPainter {
  final SplashPhase phase;
  final double progress;
  final bool reducedMotion;

  JunkfeathersSplashBackdropPainter({
    required this.phase,
    required this.progress,
    this.reducedMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (reducedMotion) return;
    if (phase == SplashPhase.hold) return; // Clean black background during hold

    // Translate local phase progress to equivalent reference timeline progress
    final double tOriginal =
        phase == SplashPhase.reveal ? progress * 0.70 : 0.70 + progress * 0.30;

    int phaseFour = 0;
    double phaseProgress = 0;
    _splashPhasesFour(tOriginal, (p, pp) {
      phaseFour = p;
      phaseProgress = pp;
    });

    // Phase 0 backdrop is clean black
    if (phaseFour == 0) return;

    final int globalStep = (tOriginal * 240).floor();
    final Random globalR = Random(globalStep);

    final double w = size.width;
    final double h = size.height;

    // Master visibility (fade-in/out ends of sequence).
    double master = 1.0;
    if (phaseFour == 0) {
      master = 0.04 + 0.96 * phaseProgress;
    } else if (phaseFour == 3) {
      master = 1.0 - 0.97 * phaseProgress;
    }

    // Phase-dependent corruption strength
    int coverBase;
    double tearAmp;
    int scanMul; // 1 = every 3px, 2 = denser in heavy phases
    if (phaseFour == 1) {
      coverBase = 18 + (globalR.nextInt(15));
      tearAmp = 3.0 + phaseProgress * 4.0;
      scanMul = 1;
    } else if (phaseFour == 2) {
      coverBase = 48 + (globalR.nextInt(22));
      tearAmp = 10.0 + phaseProgress * 12.0;
      scanMul = 2;
    } else {
      coverBase = 72 + (globalR.nextInt(25));
      tearAmp = 22.0 + phaseProgress * 26.0;
      scanMul = 2;
    }

    final Paint bandPaint = Paint()
      ..color = Colors.black.withValues(alpha: master);
    final Paint fastLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.82 * master);
    final Paint tearWhite = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * master);

    int y = 0;
    while (y < h) {
      int bandH = globalR.nextInt(14) + 4;
      if (y + bandH > h) bandH = max(0, (h - y).floor());
      if (bandH <= 0) break;

      final rowRand = Random(globalStep ^ (y * 9973));
      final tearDx = (rowRand.nextDouble() - 0.5) * 2.0 * tearAmp * master;

      final int coverChance = (coverBase + rowRand.nextInt(12)).clamp(0, 98);
      if (globalR.nextInt(100) < coverChance) {
        canvas.drawRect(
          Rect.fromLTWH(tearDx, y.toDouble(), w, bandH.toDouble()),
          bandPaint,
        );
      } else {
        if (globalR.nextInt(100) < (phaseFour >= 2 ? 22 : 12)) {
          canvas.drawRect(
            Rect.fromLTWH(tearDx, y.toDouble(), w, 1.2),
            fastLine,
          );
        }
        if (phaseFour >= 2 && globalR.nextInt(100) < 18) {
          canvas.drawRect(
            Rect.fromLTWH(tearDx + w * 0.35, y.toDouble(), w * 0.12, 1),
            tearWhite,
          );
        }
      }
      y += bandH;
    }

    final Paint scan = Paint()
      ..color = Colors.black.withValues(alpha: 0.14 * master);
    for (double sy = 0; sy < h; sy += (3 / scanMul)) {
      canvas.drawRect(Rect.fromLTWH(0, sy, w, 1), scan);
    }
  }

  @override
  bool shouldRepaint(covariant JunkfeathersSplashBackdropPainter old) =>
      old.phase != phase ||
      old.progress != progress ||
      old.reducedMotion != reducedMotion;
}

/// Renders the Junkfeathers Tech wordmarks and outline dead birds.
class JunkfeathersLogoMarkPainter extends CustomPainter {
  final SplashPhase phase;
  final double progress;
  final bool reducedMotion;

  JunkfeathersLogoMarkPainter({
    required this.phase,
    required this.progress,
    this.reducedMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 128, size.height / 64);

    if (phase == SplashPhase.hold) {
      // Hold phase: completely clean state
      _drawWordmarkGlitch(
        canvas,
        'JUNKFEATHERS',
        7,
        1.0,
        12.0,
        0,
        0.20,
        sliceGlitch: false,
      );
      _drawWordmarkGlitch(
        canvas,
        'TECH',
        22,
        1.0,
        12.0,
        0,
        0.20,
        sliceGlitch: false,
      );

      _drawBirdOutlined(canvas, 32, 45, 10.8, 1.0);
      _drawBirdOutlined(canvas, 96, 45, 10.8, 1.0);
      return;
    }

    // Translate local phase progress to equivalent reference timeline progress
    final double tOriginal =
        phase == SplashPhase.reveal ? progress * 0.70 : 0.70 + progress * 0.30;

    int phaseFour = 0;
    double phaseProgress = 0;
    _splashPhasesFour(tOriginal, (p, pp) {
      phaseFour = p;
      phaseProgress = pp;
    });

    const int totalSteps = 240;
    final int globalStep = (tOriginal * totalSteps).floor();
    final Random globalR = Random(globalStep);

    if (phaseFour == 3 && phaseProgress > 0.88) {
      return;
    }

    double jMag = 0;
    if (!reducedMotion) {
      if (phaseFour == 1) jMag = 1.0;
      if (phaseFour == 2) jMag = 2.0;
      if (phaseFour == 3) {
        jMag = (3.2 + phaseProgress * 3.5) * (1.0 - phaseProgress * 0.55);
      }
    }

    double jitterX = 0;
    double jitterY = 0;
    if (!reducedMotion && phaseFour >= 1) {
      jitterX = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
      jitterY = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
    }

    if (jitterX != 0 || jitterY != 0) {
      canvas.translate(jitterX, jitterY);
    }

    double master = 1.0;
    if (phaseFour == 0) {
      master = 0.06 + 0.94 * phaseProgress;
    }
    if (phaseFour == 3) {
      master = 1.0 - 0.98 * phaseProgress;
    }
    if (!reducedMotion && (phaseFour == 1 || phaseFour == 2)) {
      if (globalR.nextInt(100) < 8) {
        master *= 0.5 + globalR.nextDouble() * 0.5;
      }
    }

    const double wordPx = 12.0;
    final bool sliceGlitch = !reducedMotion && (phaseFour >= 1);

    _drawWordmarkGlitch(
      canvas,
      'JUNKFEATHERS',
      7,
      master,
      wordPx,
      globalStep ^ 31,
      tOriginal,
      sliceGlitch: sliceGlitch,
    );
    _drawWordmarkGlitch(
      canvas,
      'TECH',
      22,
      master,
      wordPx,
      globalStep ^ 997,
      tOriginal,
      sliceGlitch: sliceGlitch,
    );

    _drawBirdOutlined(canvas, 32, 45, 10.8, master);
    _drawBirdOutlined(canvas, 96, 45, 10.8, master);

    // Final phase: slice the mark itself
    if (!reducedMotion && phaseFour == 3) {
      final Random corruptR = Random(globalStep ^ 0x5fce);
      final int cov = (36 + phaseProgress * 58).round().clamp(32, 98).toInt();
      for (int yy = 0; yy < 64; yy += 3) {
        if (corruptR.nextInt(100) >= cov) continue;
        final bh = corruptR.nextInt(5) + 1;
        canvas.drawRect(
          Rect.fromLTWH(0, yy.toDouble(), 128, bh.toDouble()),
          Paint()..color = Colors.black.withValues(alpha: master),
        );
      }
    }

    if (jitterX != 0 || jitterY != 0) {
      canvas.translate(-jitterX, -jitterY);
    }
  }

  void _drawWordmarkGlitch(
    Canvas canvas,
    String text,
    double y,
    double m,
    double fontPx,
    int lineSalt,
    double tOriginal, {
    bool sliceGlitch = true,
  }) {
    final double shimmer =
        sin(tOriginal * pi * 2.6 + y * 0.08).clamp(-1.0, 1.0) * 0.045;
    final double textAlpha = (m * (0.72 + shimmer)).clamp(0.12, 1.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: textAlpha),
          fontFamily: 'monospace',
          fontSize: fontPx,
          fontWeight: FontWeight.bold,
          height: 1.05,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 124);
    final double x = (128 - textPainter.width) * 0.5;
    textPainter.paint(canvas, Offset(x, y));

    final double w = textPainter.width;
    final double h = textPainter.height;
    final Random sliceR = Random(
      lineSalt ^ ((tOriginal * 100000).floor()) ^ text.hashCode ^ 0x9e3779b9,
    );

    if (!sliceGlitch) {
      return;
    }

    double gy = y;
    final double bottom = y + h;
    while (gy < bottom) {
      if (sliceR.nextInt(100) < 48) {
        final double gap = 0.85 + sliceR.nextDouble() * 0.55;
        canvas.drawRect(
          Rect.fromLTRB(x - 1, gy, x + w + 1, gy + gap),
          Paint()
            ..color = Colors.black.withValues(
              alpha: m * (0.38 + sliceR.nextDouble() * 0.28),
            ),
        );
      }
      if (sliceR.nextInt(100) < 12) {
        canvas.drawRect(
          Rect.fromLTRB(
              x + sliceR.nextDouble() * w * 0.08, gy, x + w, gy + 0.85),
          Paint()
            ..color = Colors.black.withValues(
              alpha: m * (0.18 + sliceR.nextDouble() * 0.12),
            ),
        );
      }
      if (sliceR.nextInt(100) < 8) {
        canvas.drawRect(
          Rect.fromLTWH(x - 1, gy, w + 2, 0.65),
          Paint()
            ..color = Colors.white.withValues(
              alpha: m * (0.1 + sliceR.nextDouble() * 0.08),
            ),
        );
      }
      gy += 2.0 + sliceR.nextDouble() * 2.4;
    }
  }

  void _drawBirdOutlined(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double m,
  ) {
    final Paint interior = Paint()
      ..color = Colors.black.withValues(alpha: m)
      ..style = PaintingStyle.fill;

    final Paint ring = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    final Paint eyeStroke = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.88)
      ..strokeWidth = 1.45
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, interior);
    canvas.drawCircle(Offset(cx, cy), r, ring);

    final double exL = cx - (r / 2);
    final double exR = cx + (r / 2);
    final double eyeY = cy - (r / 4);
    const double s = 2.0;

    canvas.drawLine(
        Offset(exL - s, eyeY - s), Offset(exL + s, eyeY + s), eyeStroke);
    canvas.drawLine(
        Offset(exL - s, eyeY + s), Offset(exL + s, eyeY - s), eyeStroke);
    canvas.drawLine(
        Offset(exR - s, eyeY - s), Offset(exR + s, eyeY + s), eyeStroke);
    canvas.drawLine(
        Offset(exR - s, eyeY + s), Offset(exR + s, eyeY - s), eyeStroke);

    final double bx = cx;
    final double by = cy + (r / 3);

    final Path beak = Path()
      ..moveTo(bx, by + 2.8)
      ..lineTo(bx - 3.8, by - 1.8)
      ..lineTo(bx + 3.8, by - 1.8)
      ..close();

    final Paint beakFill = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.82)
      ..style = PaintingStyle.fill;
    canvas.drawPath(beak, beakFill);
    canvas.drawPath(
      beak,
      Paint()
        ..color = Colors.white.withValues(alpha: m * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );
  }

  @override
  bool shouldRepaint(covariant JunkfeathersLogoMarkPainter old) =>
      old.phase != phase ||
      old.progress != progress ||
      old.reducedMotion != reducedMotion;
}

/// Helper function to parse/evaluate original phase values (0 to 3).
void _splashPhasesFour(
  double t,
  void Function(int phase, double phaseProgress) out,
) {
  const double kSpEndFade = 0.20;
  const double kSpEndLight = 0.42;
  const double kSpEndHeavy = 0.70;

  if (t < kSpEndFade) {
    out(0, t / kSpEndFade);
  } else if (t < kSpEndLight) {
    out(1, (t - kSpEndFade) / (kSpEndLight - kSpEndFade));
  } else if (t < kSpEndHeavy) {
    out(2, (t - kSpEndLight) / (kSpEndHeavy - kSpEndLight));
  } else {
    out(3, (t - kSpEndHeavy) / (1.0 - kSpEndHeavy));
  }
}
