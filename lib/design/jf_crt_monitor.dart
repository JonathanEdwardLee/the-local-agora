import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';
import 'jf_waiting_scan_prompt.dart';

/// Custom machine scrollbar tied to a real [ScrollController].
class JfMachineScrollbar extends StatelessWidget {
  const JfMachineScrollbar({
    super.key,
    required this.controller,
    required this.trackHeight,
  });

  final ScrollController controller;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        ScrollPosition? position;
        if (controller.hasClients) {
          final positions = controller.positions;
          if (positions.isNotEmpty) {
            position = positions.first;
          }
        }

        final hasMetrics =
            position != null && position.hasContentDimensions && position.hasPixels;
        final max = hasMetrics ? position.maxScrollExtent : 0.0;
        final canScroll = max > 0.5;
        final extent = hasMetrics ? position.extentInside : trackHeight;
        final offset = hasMetrics ? position.pixels : 0.0;

        double thumbHeight = trackHeight * 0.35;
        double thumbTop = 0;
        if (canScroll && hasMetrics) {
          final ratio = extent / (extent + max);
          thumbHeight = (trackHeight * ratio).clamp(18.0, trackHeight * 0.6);
          final travel = trackHeight - thumbHeight;
          thumbTop = (offset / max) * travel;
        }

        return Semantics(
          label: canScroll ? 'Monitor scroll control' : 'Monitor scroll idle',
          child: SizedBox(
            width: 18,
            height: trackHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: JfColors.black,
                border: Border.all(
                  color: JfColors.white54,
                  width: JfBorders.secondary,
                ),
                borderRadius: JfBorders.square,
              ),
              child: Stack(
                children: [
                  if (canScroll)
                    Positioned(
                      top: thumbTop,
                      left: 2,
                      right: 2,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (!controller.hasClients) return;
                          final pos = controller.position;
                          if (!pos.hasContentDimensions) return;
                          final travel = trackHeight - thumbHeight;
                          if (travel <= 0) return;
                          final delta =
                              details.delta.dy / travel * pos.maxScrollExtent;
                          controller.jumpTo(
                            (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent),
                          );
                        },
                        child: Container(
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            color: JfColors.white70,
                            border: Border.all(
                              color: JfColors.white,
                              width: JfBorders.secondary,
                            ),
                            borderRadius: JfBorders.square,
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: 4,
                      left: 3,
                      right: 3,
                      bottom: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: JfColors.white12,
                          border: Border.all(
                            color: JfColors.white24,
                            width: JfBorders.secondary,
                          ),
                          borderRadius: JfBorders.square,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 02 — retro CRT monitor assembly (square outer, rounded inner screen).
class JfCrtMonitor extends StatefulWidget {
  const JfCrtMonitor({
    super.key,
    required this.lines,
    this.height = 180,
    this.warning = false,
    this.showWaitingPrompt = true,
    this.forceStaticPrompt,
  });

  final List<String> lines;
  final double height;
  final bool warning;
  final bool showWaitingPrompt;
  final bool? forceStaticPrompt;

  static const double innerRadius = 14;

  @override
  State<JfCrtMonitor> createState() => _JfCrtMonitorState();
}

class _JfCrtMonitorState extends State<JfCrtMonitor> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.warning ? JfColors.amber : JfColors.white;
    final screenHeight = widget.height - 20;
    final itemCount = widget.lines.length + (widget.showWaitingPrompt ? 1 : 0);

    return Semantics(
      label: 'Machine monitor',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: JfColors.black,
            border: Border.all(color: borderColor, width: JfBorders.primary),
            borderRadius: JfBorders.square,
          ),
          child: Padding(
            padding: const EdgeInsets.all(JfSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: screenHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: JfColors.black,
                        border: Border.all(
                          color: JfColors.white54,
                          width: JfBorders.secondary,
                        ),
                        borderRadius:
                            BorderRadius.circular(JfCrtMonitor.innerRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          JfCrtMonitor.innerRadius - 1,
                        ),
                        child: ListView.builder(
                          controller: _controller,
                          padding: const EdgeInsets.all(JfSpacing.sm),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (widget.showWaitingPrompt && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: JfWaitingScanPrompt(
                                  warning: widget.warning,
                                  forceStatic: widget.forceStaticPrompt,
                                ),
                              );
                            }
                            final lineIndex =
                                widget.showWaitingPrompt ? index - 1 : index;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.lines[lineIndex],
                                style: JfTypography.supporting.copyWith(
                                  color: widget.warning
                                      ? JfColors.amber
                                      : JfColors.white70,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: JfSpacing.sm),
                JfMachineScrollbar(
                  controller: _controller,
                  trackHeight: screenHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
