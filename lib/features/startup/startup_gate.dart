import 'package:flutter/material.dart';

import '../../brand/junkfeathers_splash/junkfeathers_splash.dart';
import '../../brand/local_agora_splash_tips.dart';
import '../welcome/agora_welcome_dialog.dart';
import '../welcome/welcome_suppression_store.dart';

typedef StartupShellBuilder =
    Widget Function(BuildContext context, Future<void> Function() openWelcome);

/// App-owned startup gate: universal splash once, then Local Agora main shell.
///
/// Uses [JunkfeathersSplash.onComplete] (not destination / pushReplacement).
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.builder,
    required this.welcomeStore,
    this.tips = kLocalAgoraSplashTips,
    this.enableStartupSplash = true,
    this.autoShowWelcome = true,
    this.deterministicTipIndex,
    this.reducedMotionOverride,
  });

  final StartupShellBuilder builder;
  final WelcomeSuppressionStore welcomeStore;
  final List<String> tips;
  final bool enableStartupSplash;
  final bool autoShowWelcome;
  final int? deterministicTipIndex;
  final bool? reducedMotionOverride;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late bool _showSplash;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.enableStartupSplash;
  }

  void _onSplashComplete() {
    if (!mounted || _completed) return;
    _completed = true;
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return JunkfeathersSplash(
        key: const ValueKey('jf-universal-splash'),
        tips: widget.tips,
        deterministicTipIndex: widget.deterministicTipIndex,
        reducedMotionOverride: widget.reducedMotionOverride,
        onComplete: _onSplashComplete,
      );
    }

    return _MainShellHost(
      key: const ValueKey('agora-main-shell-host'),
      welcomeStore: widget.welcomeStore,
      autoShowWelcome: widget.autoShowWelcome,
      builder: widget.builder,
    );
  }
}

class _MainShellHost extends StatefulWidget {
  const _MainShellHost({
    super.key,
    required this.builder,
    required this.welcomeStore,
    required this.autoShowWelcome,
  });

  final StartupShellBuilder builder;
  final WelcomeSuppressionStore welcomeStore;
  final bool autoShowWelcome;

  @override
  State<_MainShellHost> createState() => _MainShellHostState();
}

class _MainShellHostState extends State<_MainShellHost> {
  bool _autoWelcomeAttempted = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoShowWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeShowAutomaticWelcome();
      });
    }
  }

  Future<void> _maybeShowAutomaticWelcome() async {
    if (!mounted || _autoWelcomeAttempted || _dialogOpen) return;
    _autoWelcomeAttempted = true;
    final dismissed = await widget.welcomeStore.isPermanentlyDismissed();
    if (!mounted || dismissed) return;
    await _openWelcome(manual: false);
  }

  Future<void> openWelcomeManually() => _openWelcome(manual: true);

  Future<void> _openWelcome({required bool manual}) async {
    if (!mounted || _dialogOpen) return;
    _dialogOpen = true;
    try {
      await showAgoraWelcomeDialog(
        context: context,
        store: widget.welcomeStore,
        manual: manual,
      );
    } finally {
      if (mounted) {
        _dialogOpen = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, openWelcomeManually);
  }
}
