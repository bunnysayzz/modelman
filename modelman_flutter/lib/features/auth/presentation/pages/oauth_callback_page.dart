import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

/// OAuth callback handler page.
///
/// This page is loaded when the app receives an OAuth redirect
/// (via deep link `modelman://oauth/callback`). It extracts the
/// authorization code and completes the flow.
class OAuthCallbackPage extends ConsumerStatefulWidget {
  final Map<String, String> params;

  const OAuthCallbackPage({super.key, required this.params});

  @override
  ConsumerState<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends ConsumerState<OAuthCallbackPage> {
  String _status = 'Processing OAuth callback...';
  bool _isError = false;
  String? _serverId;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final code = widget.params['code'];
    final error = widget.params['error'];
    final state = widget.params['state'];
    final serverId = widget.params['server_id'];

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

    if (serverId == null) {
      setState(() {
        _status = 'Missing server ID';
        _isError = true;
      });
      return;
    }

    _serverId = serverId;

    setState(() {
      _status = 'Exchanging authorization code for token...';
    });

    try {
      final auth = ref.read(authServiceProvider);
      final result = await auth.exchangeCode(
        serverId: serverId,
        authorizationCode: code,
      );

      if (result['success'] == true) {
        setState(() {
          _status = 'Authorization successful! Redirecting...';
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/servers');
        }
      } else {
        setState(() {
          _status = 'Failed to exchange code: ${result['error'] ?? 'Unknown error'}';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error during token exchange: ${e.toString()}';
        _isError = true;
      });
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
                onPressed: () => context.go('/servers'),
                child: const Text('Go to Servers'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
