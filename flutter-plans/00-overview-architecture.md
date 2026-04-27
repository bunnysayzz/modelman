# modelman → Flutter: Overview & Architecture

## Executive Summary

This document outlines the comprehensive plan to port modelman (React/TypeScript web app) to Flutter multi-platform application.

## Current Architecture (React)

```
┌─────────────────────────────────────────────────────────────┐
│                     modelman Web Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   React 19   │      │   Zustand    │      │  Vite     │ │
│  │  Frontend    │◄────►│  State Mgmt  │◄────►│  Build    │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ HTTP/SSE              │ localStorage          │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Node.js/Express Backend                    │ │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────────────┐   │ │
│  │  │ MCP SDK  │  │ SQLite   │  │ JWT Auth           │   │ │
│  │  └──────────┘  └──────────┘  └────────────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Target Architecture (Flutter)

```
┌─────────────────────────────────────────────────────────────┐
│                   modelman Flutter Architecture                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │   Riverpod   │      │  Flutter   │ │
│  │   UI Layer   │◄────►│  State Mgmt  │◄────►│  Build     │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ HTTP/WebSocket       │ SharedPreferences/    │     │
│         │                      │ SQLite                │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Existing Node.js Backend                   │ │
│  │  (REUSED - No changes needed)                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Target Platforms:                                           │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                         │ │
│  │ iOS │ │Android│ │ Web │ │Desktop│                       │ │
│  └─────┘ └─────┘ └─────┘ └─────┘                         │ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Technology Mapping

| React/TypeScript | Flutter/Dart | Purpose |
|-----------------|--------------|---------|
| React 19 | Flutter 3.x | UI Framework |
| TypeScript | Dart (sound null safety) | Type Safety |
| Zustand | Riverpod 2.x | State Management |
| Vite | Flutter CLI | Build Tool |
| Express HTTP Client | Dio/HTTP | API Calls |
| Server-Sent Events | web_socket_channel | Real-time Updates |
| localStorage | SharedPreferences | Simple Storage |
| Zustand Persist | hydrated_riverpod | State Persistence |
| SQLite (backend) | sqflite | Local Database |
| jose (JWT) | jose/jwt_decoder | JWT Handling |
| react-markdown | flutter_markdown | Markdown Rendering |
| react-syntax-highlighter | flutter_highlight | Code Highlighting |
| lucide-react | flutter_svg/icons | Icons |
| react-router-dom | GoRouter/auto_route | Navigation |

## Component Mapping Diagram

```
React Components                    Flutter Components
─────────────────                   ─────────────────
App.tsx                          →  main.dart + App widget
ServerSidebar.tsx               →  lib/features/servers/presentation/server_sidebar.dart
ToolsSidebar.tsx                 →  lib/features/tools/presentation/tools_sidebar.dart
MainArea.tsx                     →  lib/features/tools/presentation/main_area.dart
HybridInterface.tsx              →  lib/features/chat/presentation/hybrid_interface.dart
AddServerModal.tsx               →  lib/features/servers/presentation/add_server_modal.dart
EditServerModal.tsx              →  lib/features/servers/presentation/edit_server_modal.dart
OAuthCallback.tsx                →  lib/features/auth/presentation/oauth_callback.dart
JsonEditor.tsx                   →  lib/shared/widgets/json_editor.dart
JsonViewer.tsx                   →  lib/shared/widgets/json_viewer.dart
MarkdownRenderer.tsx             →  lib/shared/widgets/markdown_renderer.dart
ThemeSwitcher.tsx                →  lib/shared/widgets/theme_switcher.dart
```

## State Management Mapping

### Current Zustand Store (appStore.ts)
```typescript
interface AppStore {
  servers: ServerConfig[]
  selectedServerId: string | null
  selectedToolName: string | null
  tools: Record<string, ToolSchema[]>
  history: ExecutionHistory[]
  searchQuery: string
  // ... actions
}
```

### Target Riverpod Structure
```dart
// lib/core/state/providers.dart
@riverpod
class Servers extends _$Servers {
  @override
  List<ServerConfig> build() => [];
  
  void addServer(ServerConfig server) { /* ... */ }
  void removeServer(String id) { /* ... */ }
}

@riverpod
class SelectedServer extends _$SelectedServer {
  @override
  String? build() => null;
  
  void setServer(String? id) { /* ... */ }
}

@riverpod
class Tools extends _$Tools {
  @override
  Map<String, List<ToolSchema>> build() => {};
  
  void setTools(String serverId, List<ToolSchema> tools) { /* ... */ }
}
```

## Directory Structure

```
modelman_flutter/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart
│   │   ├── constants/
│   │   │   └── api_constants.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── websocket_client.dart
│   │   ├── state/
│   │   │   ├── providers.dart
│   │   │   └── state_notifiers.dart
│   │   ├── storage/
│   │   │   ├── local_storage_service.dart
│   │   │   └── secure_storage_service.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── theme_data.dart
│   │   └── router/
│   │       └── app_router.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   └── models/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       └── pages/
│   │   ├── servers/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── tools/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── oauth/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── json_editor.dart
│   │   │   ├── json_viewer.dart
│   │   │   ├── markdown_renderer.dart
│   │   │   └── loading_indicator.dart
│   │   ├── models/
│   │   │   └── common_models.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       └── validation_utils.dart
│   └── l10n/
│       └── app_en.arb
├── test/
├── integration_test/
├── pubspec.yaml
└── analysis_options.yaml
```

## Implementation Phases

### Phase 1: Foundation (Weeks 1-3)
- [ ] Project setup and structure
- [ ] Dependency configuration
- [ ] Core services (network, storage, theme)
- [ ] State management setup
- [ ] Routing configuration

### Phase 2: Backend Integration (Weeks 4-7)
- [ ] API client implementation
- [ ] WebSocket/SSE client
- [ ] Error handling
- [ ] Authentication flow
- [ ] OAuth integration

### Phase 3: Core Features (Weeks 8-15)
- [ ] Server management (add, edit, delete, connect)
- [ ] Tool listing and filtering
- [ ] Tool execution
- [ ] JSON editor/viewer
- [ ] Execution history

### Phase 4: Advanced Features (Weeks 16-20)
- [ ] Chat interface
- [ ] AI integration
- [ ] Tool filtering with AI
- [ ] URL sharing
- [ ] Keyboard shortcuts

### Phase 5: Polish (Weeks 21-24)
- [ ] Theme system
- [ ] Animations
- [ ] Performance optimization
- [ ] Platform-specific adjustments
- [ ] Testing

## Key Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Real-time SSE updates | Use `web_socket_channel` with custom SSE parser |
| Complex state management | Riverpod with code generation for type safety |
| OAuth on mobile | `flutter_appauth` with deep linking |
| JSON syntax highlighting | `flutter_highlight` with custom theme |
| Markdown rendering | `flutter_markdown` with custom builders |
| Large lists performance | `ListView.builder` with itemExtent |
| Platform differences | Platform channels for native features |
| State persistence | `hydrated_riverpod` with Hive/SharedPreferences |

## Success Criteria

- [ ] All core features from React app ported
- [ ] Smooth 60fps performance on all platforms
- [ ] OAuth 2.1 flow working on iOS/Android
- [ ] Real-time tool execution updates
- [ ] 8 themes implemented
- [ ] State persistence working
- [ ] App passes all platform reviews

## Next Steps

1. Review `01-project-setup-structure.md` for detailed project setup
2. Follow the implementation phases sequentially
3. Refer to specific component guides for detailed code mappings
4. Use the testing strategy in `12-testing-strategy.md`
