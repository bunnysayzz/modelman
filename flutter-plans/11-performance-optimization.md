# Performance Optimization

## Overview

This document details performance optimization strategies to ensure a smooth, laggy-free Flutter experience across all platforms.

## Performance Targets

```
┌─────────────────────────────────────────────────────────────┐
│                   Performance Targets                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Metric                       │ Target                        │
│  ─────────────────────────────┼────────────────────────      │
│  Frame Rate                   │ 60 FPS                        │
│  App Startup Time              │ < 3 seconds                   │
│  Page Navigation              │ < 100ms                       │
│  Tool Execution Response       │ < 500ms                       │
│  List Scrolling               │ 60 FPS                        │
│  Memory Usage                 │ < 200 MB                      │
│  APK Size                     │ < 50 MB                       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Optimization Strategies

### 1. Widget Optimization

#### lib/core/performance/widget_optimizer.dart

```dart
import 'package:flutter/material.dart';

// Use const widgets where possible
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Optimized'),
      ],
    );
  }
}

// Avoid unnecessary rebuilds with const
class BadWidget extends StatelessWidget {
  const BadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Not const'), // Rebuilds unnecessarily
      ],
    );
  }
}
```

### 2. ListView Optimization

#### lib/shared/widgets/optimized_list_view.dart

```dart
import 'package:flutter/material.dart';

class OptimizedListView extends StatelessWidget {
  final List<String> items;

  const OptimizedListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use itemExtent for fixed height items
      itemExtent: 56,
      // Add cacheExtent for smooth scrolling
      cacheExtent: 500,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
        );
      },
    );
  }
}
```

### 3. Image Caching

#### lib/core/performance/image_cache_service.dart

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageCacheService {
  static void initialize() {
    // Configure image cache
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 100 * 1024 * 1024; // 100 MB
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  }

  static Widget cachedNetworkImage({
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : (context, url) => const CircularProgressIndicator(),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : (context, url, error) => const Icon(Icons.error),
      maxWidthDiskCache: 300,
      maxHeightDiskCache: 300,
    );
  }
}
```

### 4. Lazy Loading

#### lib/core/performance/lazy_loader.dart

```dart
import 'package:flutter/material.dart';

class LazyLoader extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLoad;

  const LazyLoader({
    super.key,
    required this.child,
    this.onLoad,
  });

  @override
  State<LazyLoader> createState() => _LazyLoaderState();
}

class _LazyLoaderState extends State<LazyLoader> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  void _checkVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = context.findRenderObject() as RenderObject?;
      if (renderObject != null) {
        final isVisible = renderObject.attached;
        if (isVisible && !_isVisible) {
          setState(() => _isVisible = true);
          widget.onLoad?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
```

### 5. Isolate for Heavy Operations

#### lib/core/performance/isolate_service.dart

```dart
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsolateService {
  // Run heavy computation in isolate
  static Future<T> runInIsolate<T>(
    T Function() computation,
  ) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _isolateEntryPoint<T>,
      _IsolateMessage(
        computation: computation,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as T;
    receivePort.close();
    return result;
  }

  static void _isolateEntryPoint<T>(_IsolateMessage message) {
    final result = message.computation();
    message.sendPort.send(result);
  }
}

class _IsolateMessage {
  final Function computation;
  final SendPort sendPort;

  _IsolateMessage({
    required this.computation,
    required this.sendPort,
  });
}

// Example: JSON parsing in isolate
Future<Map<String, dynamic>> parseJsonInIsolate(String jsonString) async {
  return await IsolateService.runInIsolate(() {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  });
}
```

### 6. Debouncing and Throttling

#### lib/core/performance/debounce_service.dart

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebounceService {
  Timer? _timer;

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class ThrottleService {
  bool _isThrottled = false;

  void throttle(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    if (_isThrottled) return;
    
    _isThrottled = true;
    callback();
    
    Timer(duration, () {
      _isThrottled = false;
    });
  }
}

final debounceServiceProvider = Provider<DebounceService>((ref) {
  final service = DebounceService();
  ref.onDispose(() => service.dispose());
  return service;
});
```

### 7. State Management Optimization

#### lib/core/performance/state_optimizer.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use select to only rebuild when specific value changes
class OptimizedWidget extends ConsumerWidget {
  const OptimizedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when selectedServerId changes
    final selectedServerId = ref.watch(
      selectedServerProvider.select((state) => state),
    );

    return Text('Selected: $selectedServerId');
  }
}

// Use family for parameterized providers
final toolByNameProvider = Provider.family<ToolSchema?, String>((ref, name) {
  final tools = ref.watch(toolsProvider);
  for (final serverTools in tools.values) {
    final tool = serverTools.firstWhere(
      (t) => t.name == name,
      orElse: () => null as ToolSchema,
    );
    if (tool != null) return tool;
  }
  return null;
});
```

### 8. Memory Management

#### lib/core/performance/memory_manager.dart

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryManager {
  static const int maxMemoryUsage = 200 * 1024 * 1024; // 200 MB

  static Future<int> getCurrentMemoryUsage() async {
    if (Platform.isAndroid) {
      // Use platform channel to get memory info
      return 0;
    } else if (Platform.isIOS) {
      // Use platform channel to get memory info
      return 0;
    }
    return 0;
  }

  static bool isMemoryUsageHigh(int currentUsage) {
    return currentUsage > maxMemoryUsage;
  }

  static void clearCaches() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

final memoryManagerProvider = Provider<MemoryManager>((ref) {
  return MemoryManager();
});
```

### 9. Network Optimization

#### lib/core/performance/network_optimizer.dart

```dart
import 'package:dio/dio.dart';

class NetworkOptimizer {
  static Dio createOptimizedDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
    ));

    // Add response caching
    dio.interceptors.add(CacheInterceptor());

    // Add request compression
    dio.interceptors.add(CompressionInterceptor());

    return dio;
  }
}

class CacheInterceptor extends Interceptor {
  final _cache = <String, Response>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = _getCacheKey(options);
    
    if (_cache.containsKey(cacheKey)) {
      return handler.resolve(_cache[cacheKey]!);
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final cacheKey = _getCacheKey(response.requestOptions);
    _cache[cacheKey] = response;
    handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}:${options.data}';
  }
}

class CompressionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add compression headers
    options.headers['Accept-Encoding'] = 'gzip, deflate, br';
    handler.next(options);
  }
}
```

### 10. Build Optimization

### pubspec.yaml (Optimized)

```yaml
# Use --release mode for production
# flutter build apk --release
# flutter build ios --release

# Split APKs per architecture
# flutter build apk --split-per-abi

# Reduce app size
flutter:
  uses-material-design: true
  
  # Remove unused resources
  assets:
    - assets/images/
    - assets/icons/
  
  # Optimize fonts
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
```

### android/app/build.gradle (Optimized)

```gradle
android {
    // Enable code shrinking
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    // Optimize APK size
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk false
        }
    }
    
    // Optimize build speed
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### ios/Runner.xcodeproj (Optimized)

```bash
# Enable bitcode
# Enable app thinning
# Optimize asset catalogs
```

## Performance Monitoring

### lib/core/performance/performance_monitor.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static void logFrameRate() {
    FlutterBinding.instance.addTimingsCallback((timings) {
      for (final frame in timings) {
        if (frame.duration.inMilliseconds > 16) {
          // Frame took longer than 16ms (60 FPS target)
          debugPrint('Slow frame: ${frame.duration.inMilliseconds}ms');
        }
      }
    });
  }

  static void logMemoryUsage() {
    if (kDebugMode) {
      // Log memory usage in debug mode
    }
  }
}

// Initialize in main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    PerformanceMonitor.logFrameRate();
    PerformanceMonitor.logMemoryUsage();
  }
  
  runApp(const ProviderScope(child: HootApp()));
}
```

## Profiling Tools

### Using Flutter DevTools

```bash
# Run app with profiling
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Best Practices Checklist

- [ ] Use const widgets wherever possible
- [ ] Implement lazy loading for long lists
- [ ] Cache images and network responses
- [ ] Use Isolates for heavy computations
- [ ] Debounce user inputs (search, typing)
- [ ] Optimize state rebuilds with select()
- [ ] Clear caches when memory is high
- [ ] Enable code shrinking for release builds
- [ ] Split APKs per ABI for smaller downloads
- [ ] Profile with Flutter DevTools
- [ ] Monitor frame rate in production
- [ ] Use itemExtent for ListView
- [ ] Avoid rebuilding entire widget trees
- [ ] Use AutomaticKeepAliveClientMixin when needed
- [ ] Optimize image sizes and formats
- [ ] Use compressed assets

## Common Performance Issues and Solutions

| Issue | Solution |
|-------|----------|
| Janky scrolling | Use ListView.builder with itemExtent |
| Slow app startup | Lazy load features, use deferred loading |
| High memory usage | Clear caches, use image compression |
| Slow JSON parsing | Use Isolates for parsing |
| Network lag | Implement caching and debouncing |
| UI freezes on heavy work | Move to Isolates or use compute function |

## Performance Testing

### test/performance/list_scroll_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:hoot_flutter/shared/widgets/optimized_list_view.dart';

void main() {
  testWidgets('ListView scrolls smoothly', (tester) async {
    final items = List.generate(1000, (i) => 'Item $i');
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OptimizedListView(items: items),
        ),
      ),
    );

    // Measure scroll performance
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 100; i++) {
      await tester.fling(find.byType(OptimizedListView), Offset(0, -500), 10000);
      await tester.pump();
    }
    
    stopwatch.stop();
    
    // Should complete in reasonable time
    expect(stopwatch.elapsedMilliseconds, lessThan(5000));
  });
}
```

## Migration Checklist

- [ ] Implement widget optimization patterns
- [ ] Optimize ListView implementations
- [ ] Set up image caching
- [ ] Implement lazy loading
- [ ] Use Isolates for heavy operations
- [ ] Add debouncing/throttling
- [ ] Optimize state management
- [ ] Implement memory management
- [ ] Optimize network requests
- [ ] Configure build optimizations
- [ ] Set up performance monitoring
- [ ] Profile with DevTools
- [ ] Test performance on all platforms
- [ ] Optimize app bundle size

## Next Steps

1. Review `12-testing-strategy.md` for testing approaches
2. Set up continuous performance monitoring
3. Implement A/B testing for optimizations
4. Create performance regression tests
