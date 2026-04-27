import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Collapsible console/log panel at the bottom of the content area.
class ConsolePanel extends ConsumerStatefulWidget {
  const ConsolePanel({super.key});

  @override
  ConsumerState<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends ConsumerState<ConsolePanel> {
  bool _isExpanded = false;
  double _height = 180;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = ref.watch(consoleLogsProvider);

    return Column(
      children: [
        // Toggle bar
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          onVerticalDragUpdate: _isExpanded
              ? (details) {
                  setState(() {
                    _height = (_height - details.delta.dy).clamp(80.0, 400.0);
                  });
                }
              : null,
          child: MouseRegion(
            cursor: _isExpanded
                ? SystemMouseCursors.resizeRow
                : SystemMouseCursors.click,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Console',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${logs.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isExpanded)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      onPressed: () =>
                          ref.read(consoleLogsProvider.notifier).state = [],
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Clear',
                    ),
                ],
              ),
            ),
          ),
        ),

        // Log content
        if (_isExpanded)
          Container(
            height: _height,
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'No logs yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.timestamp,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _levelBadge(log.level, theme),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log.message,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _levelBadge(LogLevel level, ThemeData theme) {
    final color = switch (level) {
      LogLevel.info => theme.colorScheme.primary,
      LogLevel.warn => Colors.orange,
      LogLevel.error => theme.colorScheme.error,
      LogLevel.debug => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        level.name.toUpperCase(),
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Log data model ──

enum LogLevel { info, warn, error, debug }

class ConsoleLog {
  final String message;
  final LogLevel level;
  final String timestamp;

  ConsoleLog({
    required this.message,
    required this.level,
    String? timestamp,
  }) : timestamp = timestamp ??
            '${DateTime.now().hour.toString().padLeft(2, '0')}:'
                '${DateTime.now().minute.toString().padLeft(2, '0')}:'
                '${DateTime.now().second.toString().padLeft(2, '0')}';
}

final consoleLogsProvider = StateProvider<List<ConsoleLog>>((ref) => []);
