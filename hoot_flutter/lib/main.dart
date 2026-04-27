import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/theme_provider.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Error Handling ──────────────────────────────
  // Catches all uncaught Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
    // In production: report to Sentry/Crashlytics
  };

  // Catches all uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformError] $error');
    debugPrint(stack.toString());
    // In production: report to Sentry/Crashlytics
    return true; // Prevents app crash
  };

  // Initialize SharedPreferences before the app starts
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  // Restore the saved theme (if any)
  final savedThemeName = await storageService.getThemeName();

  // Wrap in error zone for full async error coverage
  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storageService),
          ],
          child: HootApp(initialThemeName: savedThemeName),
        ),
      );
    },
    (error, stack) {
      debugPrint('[ZoneError] $error');
      debugPrint(stack.toString());
      // In production: report to Sentry/Crashlytics
    },
  );
}

/// Global navigator key for showing snackbars from anywhere.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global scaffold messenger key for snackbar notifications.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Shows a snackbar error notification from anywhere in the app.
void showErrorSnackbar(String message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white70,
        onPressed: () {},
      ),
    ),
  );
}

/// Shows a success snackbar from anywhere.
void showSuccessSnackbar(String message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Root application widget.
///
/// Configures [MaterialApp.router] with the current theme and
/// GoRouter for navigation. Restores the previously selected theme
/// on first build. Includes global error boundary.
class HootApp extends ConsumerStatefulWidget {
  final String? initialThemeName;

  const HootApp({super.key, this.initialThemeName});

  @override
  ConsumerState<HootApp> createState() => _HootAppState();
}

class _HootAppState extends ConsumerState<HootApp> {
  @override
  void initState() {
    super.initState();
    // Restore saved theme
    if (widget.initialThemeName != null) {
      Future.microtask(() {
        ref
            .read(selectedThemeProvider.notifier)
            .setThemeByName(widget.initialThemeName!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeData = ref.watch(currentThemeDataProvider);
    ref.watch(selectedThemeProvider);

    // Persist theme changes
    ref.listen<AppThemeType>(selectedThemeProvider, (prev, next) {
      if (prev != next) {
        ref.read(localStorageServiceProvider).setThemeName(next.name);
      }
    });

    return MaterialApp.router(
      title: 'Hoot — MCP Testing Tool',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: themeData,
      darkTheme: themeData,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
