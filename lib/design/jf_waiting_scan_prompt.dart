import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Honest idle CRT prompt — does not imply an active network search.
class JfWaitingScanPrompt extends StatefulWidget {
  const JfWaitingScanPrompt({
    super.key,
    this.forceStatic,
    this.warning = false,
  });

  final bool? forceStatic;
  final bool warning;

  @override
  State<JfWaitingScanPrompt> createState() => _JfWaitingScanPromptState();
}

class _JfWaitingScanPromptState extends State<JfWaitingScanPrompt>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant JfWaitingScanPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed ||
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
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
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
    final color = widget.warning ? JfColors.amber : JfColors.white70;
    return Semantics(
      label: 'Waiting for scan',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final cursorOpacity = _reduceMotion ? 1.0 : _controller.value;
          return Text.rich(
            TextSpan(
              style: JfTypography.supporting.copyWith(
                color: color,
                fontSize: 11,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: '> WAITING FOR SCAN... '),
                TextSpan(
                  text: '█',
                  style: TextStyle(color: color.withValues(alpha: cursorOpacity)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
