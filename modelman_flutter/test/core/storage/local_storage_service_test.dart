import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modelman_flutter/core/storage/local_storage_service.dart';

@GenerateMocks([SharedPreferences])
import 'local_storage_service_test.mocks.dart';

void main() {
  group('LocalStorageService', () {
    late LocalStorageService storageService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      storageService = LocalStorageService(mockPrefs);
    });

    test('should get and set theme name', () async {
      when(mockPrefs.setString('theme_name', 'dracula')).thenAnswer((_) async => true);
      when(mockPrefs.getString('theme_name')).thenReturn('dracula');

      await storageService.setThemeName('dracula');
      final themeName = await storageService.getThemeName();

      expect(themeName, 'dracula');
      verify(mockPrefs.setString('theme_name', 'dracula')).called(1);
      verify(mockPrefs.getString('theme_name')).called(1);
    });

    test('should return null when theme name not set', () async {
      when(mockPrefs.getString('theme_name')).thenReturn(null);

      final themeName = await storageService.getThemeName();

      expect(themeName, isNull);
    });

    test('should get and set auth token', () async {
      when(mockPrefs.setString('auth_token', 'test_token')).thenAnswer((_) async => true);
      when(mockPrefs.getString('auth_token')).thenReturn('test_token');

      await storageService.setAuthToken('test_token');
      final token = await storageService.getAuthToken();

      expect(token, 'test_token');
      verify(mockPrefs.setString('auth_token', 'test_token')).called(1);
      verify(mockPrefs.getString('auth_token')).called(1);
    });

    test('should clear auth token', () async {
      when(mockPrefs.remove('auth_token')).thenAnswer((_) async => true);

      await storageService.clearAuthToken();

      verify(mockPrefs.remove('auth_token')).called(1);
    });

    test('should get and set user ID', () async {
      when(mockPrefs.setString('user_id', 'test_user')).thenAnswer((_) async => true);
      when(mockPrefs.getString('user_id')).thenReturn('test_user');

      await storageService.setUserId('test_user');
      final userId = await storageService.getUserId();

      expect(userId, 'test_user');
      verify(mockPrefs.setString('user_id', 'test_user')).called(1);
      verify(mockPrefs.getString('user_id')).called(1);
    });
  });
}
