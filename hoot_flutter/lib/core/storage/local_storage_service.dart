import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

/// Wraps [SharedPreferences] to provide typed access to persistent
/// key-value data: auth tokens, user ID, server configs, theme, etc.
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Direct access for services that need to store JSON blobs.
  SharedPreferences get prefs => _prefs;

  // ── Auth Token ──────────────────────────────────────────────

  Future<String?> getAuthToken() async {
    return _prefs.getString('auth_token');
  }

  Future<void> setAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove('auth_token');
  }

  // ── User ID ─────────────────────────────────────────────────

  Future<String?> getUserId() async {
    return _prefs.getString('user_id');
  }

  Future<void> setUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  // ── Server Configs ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getServerConfigs() async {
    final data = _prefs.getString('server_configs');
    if (data == null) return [];
    try {
      return List<Map<String, dynamic>>.from(
        (json.decode(data) as List).map((e) => e as Map<String, dynamic>),
      );
    } catch (_) {
      return [];
    }
  }

  Future<void> setServerConfigs(List<Map<String, dynamic>> configs) async {
    await _prefs.setString('server_configs', json.encode(configs));
  }

  // ── Theme ───────────────────────────────────────────────────

  Future<String?> getThemeName() async {
    return _prefs.getString('theme_name');
  }

  Future<void> setThemeName(String themeName) async {
    await _prefs.setString('theme_name', themeName);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString('theme_mode');
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  // ── Tool Filter Config ──────────────────────────────────────

  Future<Map<String, dynamic>?> getToolFilterConfig() async {
    final data = _prefs.getString('tool_filter_config');
    if (data == null) return null;
    try {
      return json.decode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setToolFilterConfig(Map<String, dynamic> config) async {
    await _prefs.setString('tool_filter_config', json.encode(config));
  }

  // ── UI State ────────────────────────────────────────────────

  Future<bool> getSidebarCollapsed() async {
    return _prefs.getBool('sidebar_collapsed') ?? false;
  }

  Future<void> setSidebarCollapsed(bool collapsed) async {
    await _prefs.setBool('sidebar_collapsed', collapsed);
  }

  // ── Clear All ───────────────────────────────────────────────

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

/// Provider for [LocalStorageService].
///
/// Must be overridden in the root [ProviderScope] after calling
/// `SharedPreferences.getInstance()` in `main()`.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageServiceProvider must be overridden in ProviderScope. '
    'Call SharedPreferences.getInstance() in main() and pass it via overrideWithValue.',
  );
});
