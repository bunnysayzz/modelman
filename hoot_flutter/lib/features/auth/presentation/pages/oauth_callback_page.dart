import 'package:flutter/material.dart';

/// OAuth callback handler page.
///
/// This page is loaded when the app receives an OAuth redirect
/// (via deep link `hoot://oauth/callback`). It extracts the
/// authorization code and completes the flow.
class OAuthCallbackPage extends StatefulWidget {
  final Map<String, String> params;

  const OAuthCallbackPage({super.key, required this.params});

  @override
  State<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends State<OAuthCallbackPage> {
  String _status = 'Processing OAuth callback...';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final code = widget.params['code'];
    final error = widget.params['error'];
    final _ = widget.params['state']; // Reserved for CSRF validation

    if (error != null) {
      setState(() {
        _status = 'OAuth Error: $error';
        _isError = true;
      });
      return;
    }

    if (code == null) {
      setState(() {
        _status = 'No authorization code received';
        _isError = true;
      });
      return;
    }

    setState(() {
      _status = 'Authorization successful! Redirecting...';
    });

    // TODO: Exchange code for token and navigate back
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isError)
              const CircularProgressIndicator()
            else
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              _status,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _isError ? theme.colorScheme.error : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isError) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
