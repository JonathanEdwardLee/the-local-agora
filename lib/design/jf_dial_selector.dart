import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'junkfeathers_tokens.dart';

/// Dial-like single-value machine selector. Shows one value at a time.
class JfDialSelector<T> extends StatefulWidget {
  const JfDialSelector({
    super.key,
    required this.label,
    required this.values,
    required this.value,
    required this.labelOf,
    required this.onChanged,
    this.semanticPrefix,
  });

  final String label;
  final List<T> values;
  final T value;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final String? semanticPrefix;

  @override
  State<JfDialSelector<T>> createState() => _JfDialSelectorState<T>();
}

class _JfDialSelectorState<T> extends State<JfDialSelector<T>> {
  double _dragAccum = 0;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'JfDialSelector ${widget.label}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int get _index =>
      widget.values.indexOf(widget.value).clamp(0, widget.values.length - 1);

  void _step(int delta) {
    if (widget.values.isEmpty) return;
    final next = (_index + delta).clamp(0, widget.values.length - 1);
    if (next == _index) return;
    HapticFeedback.selectionClick();
    widget.onChanged(widget.values[next]);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _step(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _step(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.labelOf(widget.value);
    final prefix = widget.semanticPrefix ?? widget.label;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Semantics(
        label: '$prefix $current',
        value: current,
        increasedValue: _index < widget.values.length - 1
            ? widget.labelOf(widget.values[_index + 1])
            : null,
        decreasedValue: _index > 0
            ? widget.labelOf(widget.values[_index - 1])
            : null,
        onIncrease: _index < widget.values.length - 1 ? () => _step(1) : null,
        onDecrease: _index > 0 ? () => _step(-1) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.label,
              style: JfTypography.micro.copyWith(
                color: JfColors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: JfSpacing.xs),
            DecoratedBox(
              decoration: BoxDecoration(
                color: JfColors.black,
                border: Border.all(
                  color: JfColors.white70,
                  width: JfBorders.primary,
                ),
                borderRadius: JfBorders.square,
              ),
              child: SizedBox(
                height: JfControlSizes.minTap,
                child: Row(
                  children: [
                    _DialEdge(
                      key: ValueKey('jf-dial-prev-${widget.label}'),
                      symbol: '<',
                      onPressed: _index > 0 ? () => _step(-1) : null,
                      semanticLabel: 'Previous ${widget.label}',
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _focusNode.requestFocus(),
                        onHorizontalDragUpdate: (details) {
                          _dragAccum += details.delta.dx;
                          if (_dragAccum > 36) {
                            _dragAccum = 0;
                            _step(1);
                          } else if (_dragAccum < -36) {
                            _dragAccum = 0;
                            _step(-1);
                          }
                        },
                        onHorizontalDragEnd: (_) => _dragAccum = 0,
                        child: Listener(
                          onPointerSignal: (signal) {
                            if (signal is PointerScrollEvent) {
                              if (signal.scrollDelta.dy > 0 ||
                                  signal.scrollDelta.dx > 0) {
                                _step(1);
                              } else if (signal.scrollDelta.dy < 0 ||
                                  signal.scrollDelta.dx < 0) {
                                _step(-1);
                              }
                            }
                          },
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: JfMotion.press,
                              child: Text(
                                current,
                                key: ValueKey(current),
                                textAlign: TextAlign.center,
                                style: JfTypography.controlLabel.copyWith(
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _DialEdge(
                      key: ValueKey('jf-dial-next-${widget.label}'),
                      symbol: '>',
                      onPressed: _index < widget.values.length - 1
                          ? () => _step(1)
                          : null,
                      semanticLabel: 'Next ${widget.label}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialEdge extends StatelessWidget {
  const _DialEdge({
    super.key,
    required this.symbol,
    required this.onPressed,
    required this.semanticLabel,
  });

  final String symbol;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: JfControlSizes.minTap,
          height: JfControlSizes.minTap,
          child: Center(
            child: Text(
              symbol,
              style: JfTypography.controlLabel.copyWith(
                color: enabled ? JfColors.white : JfColors.white38,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
