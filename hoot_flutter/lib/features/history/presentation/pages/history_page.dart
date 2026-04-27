import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tools/presentation/providers/tool_providers.dart';
import '../../../tools/data/models/tool_model.dart';


/// History page showing past tool executions.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(executionHistoryProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final edgePadding = width < 600 ? 12.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(edgePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Execution History',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (history.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    ref.read(executionHistoryProvider.notifier).state = [];
                  },
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: theme.colorScheme.error),
                  label: Text('Clear All',
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // History list
          Expanded(
            child: history.isEmpty
                ? _emptyState(theme)
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _HistoryCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No execution history',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tool executions will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final ToolExecutionResult item;
  const _HistoryCard({required this.item});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(
                    item.isError ? Icons.error_outline : Icons.check_circle_outline,
                    size: 18,
                    color: item.isError
                        ? theme.colorScheme.error
                        : const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.toolName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.duration.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(item.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),

              // Expanded detail
              if (_expanded) ...[
                const SizedBox(height: 12),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 8),
                Text('Arguments',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    )),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    const JsonEncoder.withIndent('  ')
                        .convert(item.arguments),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.isError ? 'Error' : 'Result',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    )),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.isError
                        ? theme.colorScheme.error.withOpacity(0.1)
                        : theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    item.isError
                        ? item.error ?? 'Unknown error'
                        : const JsonEncoder.withIndent('  ')
                            .convert(item.result),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: item.isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
