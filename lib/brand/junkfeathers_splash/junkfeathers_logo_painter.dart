import 'dart:math';
import 'package:flutter/material.dart';

/// Timing segment names preserved (990 / 1000 / 880 ms).
///
/// Pass 02C.1 visual meaning (normal motion):
/// - [SplashPhase.reveal] — logo becomes readable; interference absent then light
/// - [SplashPhase.hold] — interference continuously increases (not a clean pause)
/// - [SplashPhase.hide] — interference rises to maximum; splash ends at peak
enum SplashPhase { reveal, hold, hide }

/// Normalized 0..1 position in the full 2870 ms sequence.
double splashNormalizedTime(SplashPhase phase, double progress) {
  const revealMs = 990.0;
  const holdMs = 1000.0;
  const hideMs = 880.0;
  const totalMs = revealMs + holdMs + hideMs;
  final p = progress.clamp(0.0, 1.0);
  switch (phase) {
    case SplashPhase.reveal:
      return (p * revealMs) / totalMs;
    case SplashPhase.hold:
      return (revealMs + p * holdMs) / totalMs;
    case SplashPhase.hide:
      return (revealMs + holdMs + p * hideMs) / totalMs;
  }
}

/// Monotonic interference envelope from low → high (Pass 02C.1).
///
/// Individual frames may jitter randomly; the envelope does not return to a
/// deliberate clean mid-sequence hold or a cleaning glitch-out.
double splashInterferenceIntensity(SplashPhase phase, double progress) {
  final t = splashNormalizedTime(phase, progress);
  // Segment 1 (~0–0.345): clean/minimal, light interference near the end.
  if (t <= 0.22) return 0.0;
  if (t <= 0.345) {
    return ((t - 0.22) / (0.345 - 0.22)) * 0.15;
  }
  // Segments 2–3: continuously worsen to maximum at t = 1.
  final u = ((t - 0.345) / (1.0 - 0.345)).clamp(0.0, 1.0);
  return 0.15 + 0.85 * (u * u);
}

/// True when the painter would render a deliberate clean static midpoint.
/// Always false after Pass 02C.1 for normal-motion envelopes at mid-hold.
bool splashUsesCleanStaticHold(SplashPhase phase, double progress) {
  // Historical clean-hold behavior removed; midpoint of former hold is noisy.
  if (phase != SplashPhase.hold) return false;
  return splashInterferenceIntensity(phase, progress) <= 0.001;
}

/// Renders the full-bleed boot interference: bands, tears, scanlines.
/// Intensity follows [splashInterferenceIntensity] — no clean mid pause.
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

    final double intensity = splashInterferenceIntensity(phase, progress);
    if (intensity <= 0.001) return;

    final double t = splashNormalizedTime(phase, progress);
    final int globalStep = (t * 240).floor();
    final Random globalR = Random(globalStep);

    final double w = size.width;
    final double h = size.height;

    // Master tracks interference — does not fade out at the end.
    final double master = intensity.clamp(0.0, 1.0);

    final int coverBase = (10 + (master * 78)).round();
    final double tearAmp = 2.0 + master * 42.0;
    final int scanMul = master > 0.42 ? 2 : 1;

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
        if (globalR.nextInt(100) < (master > 0.5 ? 22 : 12)) {
          canvas.drawRect(
            Rect.fromLTWH(tearDx, y.toDouble(), w, 1.2),
            fastLine,
          );
        }
        if (master > 0.45 && globalR.nextInt(100) < 18) {
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

    final double t = splashNormalizedTime(phase, progress);
    final double intensity = splashInterferenceIntensity(phase, progress);

    // Logo readability fade-in early; remains present while interference grows.
    double logoMaster = 1.0;
    if (t < 0.12) {
      logoMaster = 0.04 + 0.96 * (t / 0.12);
    }

    if (reducedMotion) {
      _drawWordmarkGlitch(
        canvas,
        'JUNKFEATHERS',
        7,
        logoMaster,
        12.0,
        0,
        t,
        sliceGlitch: false,
      );
      _drawWordmarkGlitch(
        canvas,
        'TECH',
        22,
        logoMaster,
        12.0,
        0,
        t,
        sliceGlitch: false,
      );
      _drawBirdOutlined(canvas, 32, 45, 10.8, logoMaster);
      _drawBirdOutlined(canvas, 96, 45, 10.8, logoMaster);
      return;
    }

    const int totalSteps = 240;
    final int globalStep = (t * totalSteps).floor();
    final Random globalR = Random(globalStep);

    final double jMag = intensity * 5.8;
    double jitterX = 0;
    double jitterY = 0;
    if (intensity > 0.02) {
      jitterX = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
      jitterY = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
      canvas.translate(jitterX, jitterY);
    }

    double master = logoMaster;
    if (intensity > 0.08 &&
        globalR.nextInt(100) < (6 + (intensity * 10).round())) {
      master *= 0.5 + globalR.nextDouble() * 0.5;
    }

    const double wordPx = 12.0;
    final bool sliceGlitch = intensity > 0.08;

    _drawWordmarkGlitch(
      canvas,
      'JUNKFEATHERS',
      7,
      master,
      wordPx,
      globalStep ^ 31,
      t,
      sliceGlitch: sliceGlitch,
    );
    _drawWordmarkGlitch(
      canvas,
      'TECH',
      22,
      master,
      wordPx,
      globalStep ^ 997,
      t,
      sliceGlitch: sliceGlitch,
    );

    _drawBirdOutlined(canvas, 32, 45, 10.8, master);
    _drawBirdOutlined(canvas, 96, 45, 10.8, master);

    // Increasing obstruction as intensity rises — no cleaning fade at the end.
    if (intensity > 0.35) {
      final Random corruptR = Random(globalStep ^ 0x5fce);
      final int cov = (20 + intensity * 72).round().clamp(20, 98).toInt();
      for (int yy = 0; yy < 64; yy += 3) {
        if (corruptR.nextInt(100) >= cov) continue;
        final bh = corruptR.nextInt(5) + 1;
        canvas.drawRect(
          Rect.fromLTWH(0, yy.toDouble(), 128, bh.toDouble()),
          Paint()..color = Colors.black.withValues(alpha: master * intensity),
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
            x + sliceR.nextDouble() * w * 0.08,
            gy,
            x + w,
            gy + 0.85,
          ),
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
      Offset(exL - s, eyeY - s),
      Offset(exL + s, eyeY + s),
      eyeStroke,
    );
    canvas.drawLine(
      Offset(exL - s, eyeY + s),
      Offset(exL + s, eyeY - s),
      eyeStroke,
    );
    canvas.drawLine(
      Offset(exR - s, eyeY - s),
      Offset(exR + s, eyeY + s),
      eyeStroke,
    );
    canvas.drawLine(
      Offset(exR - s, eyeY + s),
      Offset(exR + s, eyeY - s),
      eyeStroke,
    );

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
