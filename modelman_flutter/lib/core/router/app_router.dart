import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/auth/presentation/providers/oauth_providers.dart';
import '../../features/servers/presentation/pages/servers_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../layout/main_layout.dart';

/// Provides the application's [GoRouter] configuration.
///
/// Uses a [ShellRoute] so that the sidebar/header layout persists
/// across navigations while the inner content area swaps.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/servers',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/servers',
            name: 'servers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ServersPage(),
            ),
          ),
          GoRoute(
            path: '/tools',
            name: 'tools',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ToolsPage(),
            ),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatPage(),
            ),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
      // OAuth callback — outside the shell (no sidebar)
      GoRoute(
        path: '/oauth/callback',
        name: 'oauth-callback',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return OAuthCallbackPage(params: params);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/servers'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    // Handle deep links for OAuth callback
    redirect: (context, state) {
      final uri = state.uri;
      if (uri.scheme == 'modelman' && uri.path == '/oauth/callback') {
        return '/oauth/callback?${uri.query}';
      }
      return null;
    },
  );
});
