import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_machine_status_strip.dart';
import '../../design/jf_numeric_display.dart';
import '../../design/jf_oled_dialog.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_section_label.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/jf_status_line.dart';
import '../../design/junkfeathers_tokens.dart';

/// Debug-only visual review surface. Not linked from release builds.
class DebugComponentGallery extends StatefulWidget {
  const DebugComponentGallery({super.key});

  @override
  State<DebugComponentGallery> createState() => _DebugComponentGalleryState();
}

class _DebugComponentGalleryState extends State<DebugComponentGallery> {
  final _fieldController = TextEditingController(text: 'Springfield, Missouri');
  bool _selected = true;

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: JfColors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                JfSpacing.lg,
                JfSpacing.lg,
                JfSpacing.lg,
                JfSpacing.lg + bottomInset,
              ),
              children: [
                Text(
                  'DEBUG // COMPONENT GALLERY',
                  style: JfTypography.deviceTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: JfSpacing.xs),
                const Text(
                  'Temporary visual-approval surface. Not part of production navigation.',
                  style: JfTypography.supporting,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('MACHINE IDENTITY'),
                const SizedBox(height: JfSpacing.sm),
                const Text(
                  AgoraMachineIdentity.model,
                  style: JfTypography.controlLabel,
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfMachineStatusStrip(),
                const SizedBox(height: JfSpacing.xs),
                const Text(
                  'Portrait-only on Android/iOS. Web has no phone orientation lock.',
                  style: JfTypography.supporting,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('SIGNAL COIL'),
                const SizedBox(height: JfSpacing.sm),
                const JfSignalCoil(mode: JfSignalCoilMode.idle, height: 100),
                const SizedBox(height: JfSpacing.sm),
                const Text('STATIC / REDUCED MOTION', style: JfTypography.micro),
                const SizedBox(height: JfSpacing.xs),
                const JfSignalCoil(
                  mode: JfSignalCoilMode.idle,
                  height: 100,
                  forceStatic: true,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('TYPOGRAPHY'),
                const SizedBox(height: JfSpacing.sm),
                const Text('THE LOCAL AGORA', style: JfTypography.deviceTitle),
                const SizedBox(height: JfSpacing.sm),
                const Text(
                  'Supporting copy uses sentence case for clarity.',
                  style: JfTypography.supporting,
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfNumericDisplay('12', label: 'SIGNALS'),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('BORDER HIERARCHY'),
                const SizedBox(height: JfSpacing.sm),
                const JfPanel(
                  weight: JfPanelWeight.major,
                  child: Text(
                    '3 PX MAJOR FRAME',
                    style: JfTypography.controlLabel,
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfPanel(
                  weight: JfPanelWeight.primary,
                  child: Text(
                    '2 PX PRIMARY PANEL',
                    style: JfTypography.controlLabel,
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfPanel(
                  weight: JfPanelWeight.secondary,
                  borderColor: JfColors.white54,
                  child: Text(
                    '1 PX SECONDARY FRAME',
                    style: JfTypography.controlLabel,
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('BUTTONS'),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'PRIMARY FULL-WIDTH',
                  onPressed: () => showJfOledToast(
                    context,
                    'PRIMARY PRESSED',
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                Wrap(
                  spacing: JfSpacing.sm,
                  runSpacing: JfSpacing.sm,
                  children: [
                    JfDeviceButton(
                      label: 'COMPACT',
                      variant: JfButtonVariant.compact,
                      expanded: false,
                      onPressed: () {},
                    ),
                    JfDeviceButton(
                      label: 'SELECTED',
                      variant: JfButtonVariant.selectable,
                      expanded: false,
                      selected: _selected,
                      onPressed: () => setState(() => _selected = !_selected),
                    ),
                    const JfDeviceButton(
                      label: 'DISABLED',
                      variant: JfButtonVariant.compact,
                      expanded: false,
                      onPressed: null,
                    ),
                    const JfDeviceButton(
                      label: 'LOCKED',
                      variant: JfButtonVariant.compact,
                      expanded: false,
                      locked: true,
                      lockedMessage: 'LOCKED EXAMPLE — gated feature later.',
                    ),
                  ],
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('KEYBOARD-SAFE FIELD'),
                const SizedBox(height: JfSpacing.sm),
                JfMachineField(
                  label: 'CITY OR ZIP CODE',
                  controller: _fieldController,
                  hintText: 'Enter location',
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('TOP OLED TOASTS'),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'TOP INFO TOAST',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledToast(
                    context,
                    'SCAN CONTROL READY',
                    detail:
                        'Live Keryx connection arrives in the next governed pass.',
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'TOP WARNING TOAST',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledToast(
                    context,
                    'LOCATION REQUIRED',
                    detail: 'Enter a city or ZIP code.',
                    warning: true,
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'SHOW SQUARE DIALOG',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledDialog<void>(
                    context: context,
                    title: 'SQUARE DIALOG',
                    body: '2 px white frame. Monospace body. No rounded card.',
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('STATUS LINES'),
                const SizedBox(height: JfSpacing.sm),
                const JfStatusLine('LOADING // SEARCHING PUBLIC SIGNALS'),
                const SizedBox(height: JfSpacing.xs),
                const JfStatusLine(
                  'EMPTY // NO CURRENT SIGNALS FOUND',
                  tone: JfStatusTone.secondary,
                ),
                const SizedBox(height: JfSpacing.xs),
                const JfStatusLine(
                  'ERROR // LOCATION REQUIRED',
                  tone: JfStatusTone.error,
                ),
                const SizedBox(height: JfSpacing.xs),
                const JfStatusLine(
                  'OFFLINE // NETWORK UNAVAILABLE',
                  tone: JfStatusTone.secondary,
                ),
                const SizedBox(height: JfSpacing.xs),
                const JfStatusLine(
                  'WARNING // DETAILS INCOMPLETE',
                  tone: JfStatusTone.warning,
                ),
                const SizedBox(height: JfSpacing.xl),
                JfDeviceButton(
                  label: 'RETURN TO SCAN CONTROL',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
