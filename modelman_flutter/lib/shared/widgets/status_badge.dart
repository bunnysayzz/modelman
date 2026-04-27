import 'package:flutter/material.dart';

/// A colored status badge for server connection and tool execution states.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, bgColor) = _getColors(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors(ThemeData theme) {
    return switch (type) {
      StatusType.connected => (
          const Color(0xFF4CAF50),
          const Color(0xFF4CAF50).withOpacity(0.12),
        ),
      StatusType.disconnected => (
          Colors.grey,
          Colors.grey.withOpacity(0.12),
        ),
      StatusType.connecting => (
          Colors.orange,
          Colors.orange.withOpacity(0.12),
        ),
      StatusType.error => (
          theme.colorScheme.error,
          theme.colorScheme.error.withOpacity(0.12),
        ),
      StatusType.success => (
          const Color(0xFF4CAF50),
          const Color(0xFF4CAF50).withOpacity(0.12),
        ),
      StatusType.executing => (
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.12),
        ),
    };
  }
}

enum StatusType {
  connected,
  disconnected,
  connecting,
  error,
  success,
  executing,
}
