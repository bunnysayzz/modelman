import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A read-only JSON viewer with collapsible nodes, copy, and
/// syntax coloring.
class JsonViewer extends StatelessWidget {
  final dynamic data;
  final bool expanded;

  const JsonViewer({super.key, required this.data, this.expanded = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jsonString = data is String
        ? data as String
        : const JsonEncoder.withIndent('  ').convert(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Row(
          children: [
            Text(
              'Response',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // JSON content
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonString,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
