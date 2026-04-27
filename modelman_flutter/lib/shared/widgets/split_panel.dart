import 'package:flutter/material.dart';

/// A horizontally resizable split panel for request/response views.
///
/// The left panel typically shows request parameters and the right
/// panel shows the response. A draggable divider sits between them.
class SplitPanel extends StatefulWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double initialLeftRatio;
  final double minLeftWidth;
  final double minRightWidth;

  const SplitPanel({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.initialLeftRatio = 0.45,
    this.minLeftWidth = 200,
    this.minRightWidth = 200,
  });

  @override
  State<SplitPanel> createState() => _SplitPanelState();
}

class _SplitPanelState extends State<SplitPanel> {
  late double _leftRatio;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _leftRatio = widget.initialLeftRatio;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dividerWidth = 6.0;
        final usableWidth = totalWidth - dividerWidth;
        var leftWidth = usableWidth * _leftRatio;
        var rightWidth = usableWidth - leftWidth;

        // Enforce minimums
        if (leftWidth < widget.minLeftWidth) {
          leftWidth = widget.minLeftWidth;
          rightWidth = usableWidth - leftWidth;
        }
        if (rightWidth < widget.minRightWidth) {
          rightWidth = widget.minRightWidth;
          leftWidth = usableWidth - rightWidth;
        }

        return Row(
          children: [
            // Left panel
            SizedBox(
              width: leftWidth,
              child: widget.leftChild,
            ),

            // Draggable divider
            GestureDetector(
              onHorizontalDragStart: (_) =>
                  setState(() => _isDragging = true),
              onHorizontalDragEnd: (_) =>
                  setState(() => _isDragging = false),
              onHorizontalDragUpdate: (details) {
                setState(() {
                  final newLeft =
                      (leftWidth + details.delta.dx).clamp(
                    widget.minLeftWidth,
                    usableWidth - widget.minRightWidth,
                  );
                  _leftRatio = newLeft / usableWidth;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: dividerWidth,
                  color: _isDragging
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.dividerColor,
                ),
              ),
            ),

            // Right panel
            SizedBox(
              width: rightWidth,
              child: widget.rightChild,
            ),
          ],
        );
      },
    );
  }
}
