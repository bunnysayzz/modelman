import 'dart:convert';
import 'package:flutter/material.dart';

/// A simple JSON editor with syntax highlighting and validation.
///
/// Provides a multi-line text field that validates JSON on change
/// and reports validity via [onChanged].
class JsonEditor extends StatefulWidget {
  final Map<String, dynamic>? initialValue;
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final bool readOnly;
  final String? hintText;

  const JsonEditor({
    super.key,
    this.initialValue,
    this.onChanged,
    this.readOnly = false,
    this.hintText,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  late TextEditingController _controller;
  bool _isValid = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue != null
        ? const JsonEncoder.withIndent('  ').convert(widget.initialValue)
        : '';
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _isValid = true;
        _errorMessage = null;
      });
      widget.onChanged?.call({});
      return;
    }

    try {
      final parsed = json.decode(text) as Map<String, dynamic>;
      setState(() {
        _isValid = true;
        _errorMessage = null;
      });
      widget.onChanged?.call(parsed);
    } catch (e) {
      setState(() {
        _isValid = false;
        _errorMessage = e.toString().replaceAll('FormatException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              _isValid ? Icons.check_circle_outline : Icons.error_outline,
              size: 14,
              color: _isValid
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(width: 6),
            Text(
              _isValid ? 'Valid JSON' : 'Invalid JSON',
              style: TextStyle(
                fontSize: 11,
                color: _isValid
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!widget.readOnly)
              IconButton(
                icon: const Icon(Icons.format_align_left, size: 16),
                onPressed: _formatJson,
                tooltip: 'Format',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
          ],
        ),
        const SizedBox(height: 4),

        // Editor
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isValid
                    ? theme.dividerColor
                    : theme.colorScheme.error.withOpacity(0.5),
              ),
            ),
            child: TextField(
              controller: _controller,
              readOnly: widget.readOnly,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText ?? '{\n  \n}',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  fontFamily: 'monospace',
                ),
              ),
              onChanged: _validate,
            ),
          ),
        ),

        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.error,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _formatJson() {
    try {
      final parsed = json.decode(_controller.text);
      _controller.text =
          const JsonEncoder.withIndent('  ').convert(parsed);
      _validate(_controller.text);
    } catch (_) {
      // Can't format invalid JSON
    }
  }
}
