import 'package:flutter/material.dart';

import '../../design/junkfeathers_tokens.dart';

/// Continuous CRT searching animation for long live scans.
///
/// Black / white / occasional green only. No deceptive percentages.
class CrtSearchingAnimation extends StatefulWidget {
  const CrtSearchingAnimation({
    super.key,
    this.location = '',
    this.timeFrameLabel = '',
    this.eventTypeLabel = '',
    this.forceStatic,
  });

  final String location;
  final String timeFrameLabel;
  final String eventTypeLabel;
  final bool? forceStatic;

  static const statusLines = <String>[
    'SEARCHING PUBLIC EVENT SOURCES',
    'CHECKING EVENT DETAILS',
    'VERIFYING DATES AND LOCATIONS',
    'ORGANIZING UPCOMING EVENTS',
  ];

  @override
  State<CrtSearchingAnimation> createState() => CrtSearchingAnimationState();
}

@visibleForTesting
class CrtSearchingAnimationState extends State<CrtSearchingAnimation>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _scanLine;
  late final AnimationController _dots;
  late final AnimationController _status;
  bool _appActive = true;

  int get statusIndex {
    if (_status.duration == null || _status.duration == Duration.zero) {
      return 0;
    }
    final t = _status.value;
    final n = CrtSearchingAnimation.statusLines.length;
    return (t * n).floor().clamp(0, n - 1);
  }

  int get dotCount {
    final phase = (_dots.value * 4).floor() % 4;
    return phase; // 0..3 → SEARCHING / ./ ../ ...
  }

  bool get isAnimating =>
      _scanLine.isAnimating || _dots.isAnimating || _status.isAnimating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _status = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant CrtSearchingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (mounted) _sync();
  }

  bool get _reduceMotion {
    if (widget.forceStatic == true) return true;
    if (widget.forceStatic == false) return false;
    return MediaQuery.disableAnimationsOf(context);
  }

  void _sync() {
    final animate = !_reduceMotion && _appActive;
    if (animate) {
      if (!_scanLine.isAnimating) _scanLine.repeat();
      if (!_dots.isAnimating) _dots.repeat();
      if (!_status.isAnimating) _status.repeat();
    } else {
      _scanLine.stop();
      _scanLine.value = 0.35;
      if (!_dots.isAnimating) _dots.repeat(); // dots/text still advance lightly
      if (!_status.isAnimating) _status.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLine.dispose();
    _dots.dispose();
    _status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Searching for upcoming events',
      child: AnimatedBuilder(
        animation: Listenable.merge([_scanLine, _dots, _status]),
        builder: (context, _) {
          final dots = '.' * dotCount;
          final status = CrtSearchingAnimation.statusLines[statusIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SEARCHING$dots',
                style: JfTypography.controlLabel.copyWith(
                  color: JfColors.signalGreen,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: JfSpacing.sm),
              if (widget.location.isNotEmpty)
                Text(
                  'LOCATION // ${widget.location.toUpperCase()}',
                  style: JfTypography.supporting.copyWith(fontSize: 11),
                ),
              if (widget.timeFrameLabel.isNotEmpty)
                Text(
                  'TIME FRAME // ${widget.timeFrameLabel}',
                  style: JfTypography.supporting.copyWith(fontSize: 11),
                ),
              if (widget.eventTypeLabel.isNotEmpty)
                Text(
                  'EVENT TYPE // ${widget.eventTypeLabel}',
                  style: JfTypography.supporting.copyWith(fontSize: 11),
                ),
              const SizedBox(height: JfSpacing.md),
              SizedBox(
                height: 56,
                child: CustomPaint(
                  painter: _CrtScanLinePainter(
                    progress: _scanLine.value,
                    reduceMotion: _reduceMotion,
                    blink: _dots.value,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: JfSpacing.sm),
              Text(
                status,
                style: JfTypography.micro.copyWith(
                  color: JfColors.signalGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'SEARCHING FOR UPCOMING EVENTS',
                style: JfTypography.micro.copyWith(color: JfColors.white70),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CrtScanLinePainter extends CustomPainter {
  _CrtScanLinePainter({
    required this.progress,
    required this.reduceMotion,
    required this.blink,
  });

  final double progress;
  final bool reduceMotion;
  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = JfColors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, border);

    if (reduceMotion) {
      final cursor = Paint()
        ..color = JfColors.signalGreen.withValues(alpha: 0.35 + 0.65 * blink);
      canvas.drawRect(Rect.fromLTWH(6, size.height / 2 - 4, 10, 8), cursor);
      return;
    }

    final y = progress * size.height;
    final line = Paint()
      ..color = JfColors.signalGreen.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), line);

    final haze = Paint()..color = JfColors.signalGreen.withValues(alpha: 0.12);
    canvas.drawRect(
      Rect.fromLTWH(2, (y - 8).clamp(0, size.height), size.width - 4, 16),
      haze,
    );
  }

  @override
  bool shouldRepaint(covariant _CrtScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.blink != blink;
  }
}
