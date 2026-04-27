# Testing Strategy

## Overview

This document details the comprehensive testing strategy for the Flutter app to ensure quality across all platforms.

## Testing Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│                   Testing Pyramid                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                    ┌──────────────┐                          │
│                    │   E2E Tests   │                          │
│                    │    (10%)     │                          │
│                    └──────────────┘                          │
│                           ▲                                  │
│                    ┌──────────────┐                          │
│                    │ Integration   │                          │
│                    │   Tests       │                          │
│                    │    (30%)     │                          │
│                    └──────────────┘                          │
│                           ▲                                  │
│                    ┌──────────────┐                          │
│                    │  Unit Tests   │                          │
│                    │    (60%)     │                          │
│                    └──────────────┘                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Test Structure

```
test/
├── unit/
│   ├── core/
│   │   ├── network/
│   │   ├── storage/
│   │   └── theme/
│   ├── features/
│   │   ├── auth/
│   │   ├── servers/
│   │   ├── tools/
│   │   └── chat/
│   └── shared/
│       └── widgets/
├── integration/
│   ├── api/
│   └── storage/
└── widget/
    └── components/

integration_test/
├── app_flow_test.dart
├── auth_flow_test.dart
└── mcp_flow_test.dart
```

## Unit Testing

### test/unit/features/servers/server_repository_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:modelman_flutter/features/servers/data/repositories/server_repository.dart';
import 'package:modelman_flutter/core/network/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late ServerRepository repository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    repository = ServerRepository(mockApiService);
  });

  group('ServerRepository', () {
    test('autoDetectServer returns ServerConfig', () async {
      when(mockApiService.autoDetectServer(any)).thenAnswer(
        (_) async => {
          'name': 'Test Server',
          'transport': 'http',
        },
      );

      final result = await repository.autoDetectServer('http://test.com');
      
      expect(result.name, 'Test Server');
      expect(result.transport, 'http');
      verify(mockApiService.autoDetectServer('http://test.com')).called(1);
    });

    test('connectToServer handles success', () async {
      when(mockApiService.connectToServer(
        serverId: anyNamed('serverId'),
        serverName: anyNamed('serverName'),
        url: anyNamed('url'),
        transport: anyNamed('transport'),
        auth: anyNamed('auth'),
        authorizationCode: anyNamed('authorizationCode'),
      )).thenAnswer(
        (_) async => {'success': true},
      );

      final result = await repository.connectToServer(
        serverId: 'test-1',
        serverName: 'Test',
        url: 'http://test.com',
        transport: 'http',
      );

      expect(result.success, true);
    });

    test('connectToServer handles OAuth required', () async {
      when(mockApiService.connectToServer(
        any,
        auth: anyNamed('auth'),
        authorizationCode: anyNamed('authorizationCode'),
      )).thenThrow(
        DioException(
          response: Response(
            data: {'error': 'UnauthorizedError', 'needsAuth': true},
            statusCode: 401,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.connectToServer(
          serverId: 'test-1',
          serverName: 'Test',
          url: 'http://test.com',
          transport: 'http',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

### test/unit/core/state/providers_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelman_flutter/core/state/providers.dart';
import 'package:modelman_flutter/features/servers/data/models/server_model.dart';

void main() {
  test('ServersProvider - addServer', () {
    final container = ProviderContainer();
    
    container.read(serversProvider.notifier).addServer(
      const ServerConfig(
        id: '1',
        name: 'Test Server',
        url: 'http://test.com',
      ),
    );
    
    final servers = container.read(serversProvider);
    expect(servers.length, 1);
    expect(servers.first.name, 'Test Server');
  });

  test('SelectedServerProvider - setServer', () {
    final container = ProviderContainer();
    
    container.read(selectedServerProvider.notifier).setServer('server-123');
    
    final selectedId = container.read(selectedServerProvider);
    expect(selectedId, 'server-123');
  });

  test('ToolsProvider - setTools', () {
    final container = ProviderContainer();
    
    container.read(toolsProvider.notifier).setTools(
      'server-1',
      [
        const ToolSchema(name: 'tool1'),
        const ToolSchema(name: 'tool2'),
      ],
    );
    
    final tools = container.read(toolsProvider);
    expect(tools['server-1']?.length, 2);
  });
}
```

## Widget Testing

### test/widget/shared/widgets/json_editor_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/shared/widgets/json_editor.dart';

void main() {
  testWidgets('JsonEditor renders initial value', (tester) async {
    const initialValue = '{"test": "value"}';
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonEditor(
            initialValue: initialValue,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(initialValue), findsOneWidget);
  });

  testWidgets('JsonEditor validates JSON', (tester) async {
    bool isValid = true;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonEditor(
            initialValue: '{"test": "value"}',
            onChanged: (value) {
              try {
                jsonDecode(value);
                isValid = true;
              } catch (e) {
                isValid = false;
              }
            },
          ),
        ),
      ),
    );

    expect(isValid, true);
  });

  testWidgets('JsonEditor shows error for invalid JSON', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonEditor(
            initialValue: '{invalid json}',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.error), findsOneWidget);
  });
}
```

### test/widget/features/servers/server_tile_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/features/servers/presentation/widgets/server_tile.dart';
import 'package:modelman_flutter/features/servers/data/models/server_model.dart';

void main() {
  testWidgets('ServerTile displays server name', (tester) async {
    const server = ServerConfig(
      id: '1',
      name: 'Test Server',
      url: 'http://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServerTile(
            server: server,
            isSelected: false,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Server'), findsOneWidget);
    expect(find.text('http://test.com'), findsOneWidget);
  });

  testWidgets('ServerTile shows connected indicator', (tester) async {
    const server = ServerConfig(
      id: '1',
      name: 'Test Server',
      url: 'http://test.com',
      connected: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServerTile(
            server: server,
            isSelected: false,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
  });

  testWidgets('ServerTile calls onTap when tapped', (tester) async {
    bool tapped = false;
    
    const server = ServerConfig(
      id: '1',
      name: 'Test Server',
      url: 'http://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServerTile(
            server: server,
            isSelected: false,
            onTap: () => tapped = true,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ServerTile));
    expect(tapped, true);
  });
}
```

## Integration Testing

### test/integration/api/mcp_api_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/core/network/api_service.dart';

void main() {
  test('API Service - health check', () async {
    final apiService = ApiService(Dio());
    
    final result = await apiService.healthCheck();
    
    expect(result['status'], 'ok');
  });
}
```

### test/integration/storage/hive_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modelman_flutter/core/storage/hive_service.dart';
import 'package:modelman_flutter/features/servers/data/models/server_model.dart';

void main() {
  group('HiveService Integration', () {
    late HiveService hiveService;

    setUpAll(() async {
      await Hive.initFlutter();
      await Hive.openBox('test_servers');
      hiveService = HiveService();
    });

    tearDownAll(() async {
      await Hive.deleteBox('test_servers');
    });

    test('save and retrieve server', () async {
      final server = ServerConfig(
        id: 'test-1',
        name: 'Test Server',
        url: 'http://test.com',
      );

      await hiveService.addServer(server);
      final servers = await hiveService.getServers();

      expect(servers.length, 1);
      expect(servers.first.id, 'test-1');
    });

    test('delete server', () async {
      final server = ServerConfig(
        id: 'test-1',
        name: 'Test Server',
        url: 'http://test.com',
      );

      await hiveService.addServer(server);
      await hiveService.removeServer('test-1');
      final servers = await hiveService.getServers();

      expect(servers.length, 0);
    });
  });
}
```

## End-to-End Testing

### integration_test/app_flow_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelman_flutter/main.dart';

void main() {
  testWidgets('App flow - add server and connect', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: modelmanApp(),
      ),
    );

    // Wait for app to load
    await tester.pumpAndSettle();

    // Verify servers page is displayed
    expect(find.text('Servers'), findsOneWidget);

    // Tap add server button
    await tester.tap(find.text('Add Server'));
    await tester.pumpAndSettle();

    // Enter server details
    await tester.enterText(find.byKey('server-name'), 'Test Server');
    await tester.enterText(find.byKey('server-url'), 'http://test.com');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    // Verify server is added
    expect(find.text('Test Server'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
  });

  testWidgets('App flow - execute tool', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: modelmanApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Add and connect to server (mock)
    // Select tool
    // Execute tool
    // Verify results
  });
}
```

### integration_test/auth_flow_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelman_flutter/main.dart';

void main() {
  testWidgets('OAuth flow - initiate and complete', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: modelmanApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Add server with OAuth
    // Navigate to OAuth config
    // Enter OAuth details
    // Initiate OAuth flow
    // Verify redirect
    // Complete OAuth
    // Verify connection
  });
}
```

## Golden Testing

### test/widget/themes/theme_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelman_flutter/main.dart';
import 'package:modelman_flutter/core/theme/app_theme.dart';

void main() {
  testWidgets('Golden test - light theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedThemeProvider.overrideWith((ref) => AppTheme.duotoneLight),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/light_theme.png'),
    );
  });

  testWidgets('Golden test - dark theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedThemeProvider.overrideWith((ref) => AppTheme.duotoneDark),
        ],
        child: const MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/dark_theme.png'),
    );
  });
}
```

## Mock Testing Setup

### test/mocks/mocks.dart

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:modelman_flutter/core/network/api_service.dart';

@GenerateMocks([ApiService, Dio])
import 'mocks.mocks.dart';
```

## Test Configuration

### test/test_config.dart

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Configuration', () {
    test('Flutter test is configured', () {
      expect(binding, isNotNull);
    });
  });
}
```

## Running Tests

### Run all tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/

# E2E tests
flutter test integration_test/

# With coverage
flutter test --coverage

# Specific test file
flutter test test/unit/features/servers/server_repository_test.dart

# With platform specified
flutter test --platform chrome
```

## Continuous Integration

### .github/workflows/test.yml

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Test Coverage Goals

```
┌─────────────────────────────────────────────────────────────┐
│                   Coverage Targets                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Module                       │ Target Coverage               │
│  ─────────────────────────────┼────────────────────────      │
│  Core (network, storage)       │ 90%                          │
│  Features (auth, servers, etc.) │ 85%                          │
│  Shared widgets                │ 80%                          │
│  Overall                       │ 85%                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Testing Best Practices

- [ ] Write tests before implementation (TDD)
- [ ] Keep tests independent
- [ ] Use descriptive test names
- [ ] Mock external dependencies
- [ ] Test both success and failure cases
- [ ] Use golden tests for UI
- [ ] Run tests in CI/CD
- [ ] Maintain test coverage > 80%
- [ ] Update tests when refactoring
- [ ] Use test doubles appropriately

## Migration Checklist

- [ ] Set up test structure
- [ ] Configure test dependencies
- [ ] Write unit tests for core services
- [ ] Write unit tests for features
- [ ] Write widget tests for components
- [ ] Write integration tests for API
- [ ] Write integration tests for storage
- [ ] Write E2E tests for critical flows
- [ ] Set up golden tests for UI
- [ ] Configure mock testing
- [ ] Set up CI/CD for tests
- [ ] Achieve target coverage
- [ ] Document test strategy

## Next Steps

1. Review `13-deployment-checklist.md` for deployment guide
2. Set up automated testing pipeline
3. Implement visual regression testing
4. Add performance tests
