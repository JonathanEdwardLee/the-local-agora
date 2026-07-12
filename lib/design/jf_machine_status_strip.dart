import 'package:flutter/material.dart';

export 'jf_machine_identity_panel.dart' show AgoraMachineIdentity;

/// Legacy status-strip placeholder. Scan Control uses [JfMachineIdentityPanel].
class JfMachineStatusStrip extends StatelessWidget {
  const JfMachineStatusStrip({super.key, this.now, this.forceDevIndicator});

  final DateTime? now;
  final bool? forceDevIndicator;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
