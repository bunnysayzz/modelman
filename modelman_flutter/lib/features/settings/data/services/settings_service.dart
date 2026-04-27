import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/settings_model.dart';

/// Notifier for the global app settings.
///
/// Loads settings from SharedPreferences on initialization and
/// persists every change automatically.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageService _storage;

  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _load();
  }

  static const _key = 'app_settings';

  void _load() {
    try {
      final raw = _storage.prefs.getString(_key);
      if (raw != null) {
        state = AppSettings.fromJson(json.decode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Keep defaults
    }
  }

  /// Updates settings via a builder pattern and auto-saves.
  Future<void> update(AppSettings Function(AppSettings) updater) async {
    state = updater(state);
    await _save();
  }

  Future<void> _save() async {
    await _storage.prefs.setString(_key, json.encode(state.toJson()));
  }

  /// Resets all settings to factory defaults.
  Future<void> reset() async {
    state = const AppSettings();
    await _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsNotifier(storage);
});
