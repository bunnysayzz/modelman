# modelman Architecture

## Overview

modelman is an MCP (Model Context Protocol) testing tool with a clean separation between frontend (React) and backend (Node.js/Cloudflare Workers).

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Browser (Frontend)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   React Components (UI)                                   │  │
│  │   ├── ServerSidebar.tsx                                   │  │
│  │   ├── ToolsSidebar.tsx                                    │  │
│  │   └── MainArea.tsx                                        │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │   Backend API Client (backendClient.ts)                   │  │
│  │   └── HTTP calls to localhost:8008                       │  │
│  └──────────────────────┬───────────────────────────────────┘  │
└─────────────────────────┼──────────────────────────────────────┘
                          │ HTTP (localhost:8008)
                          │ No CORS issues!
┌─────────────────────────▼──────────────────────────────────────┐
│                   Node.js Backend Server                         │
│              (server/server-node.js on port 8008)               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   REST API (18 endpoints)                                 │  │
│  │   ├── POST /auth/token                                    │  │
│  │   ├── POST /mcp/connect                                   │  │
│  │   ├── POST /mcp/auto-detect                               │  │
│  │   ├── GET  /mcp/tools/:serverId                          │  │
│  │   ├── POST /mcp/execute                                   │  │
│  │   └── ...more endpoints                                   │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │   MCP SDK Client Manager                                  │  │
│  │   ├── Client instances (Map<serverId, Client>)           │  │
│  │   ├── Transport instances (SSE/HTTP)                     │  │
│  │   └── OAuth state management                             │  │
│  └──────────────────────┬───────────────────────────────────┘  │
└─────────────────────────┼──────────────────────────────────────┘
                          │ HTTP/SSE Transports
                          │
┌─────────────────────────▼──────────────────────────────────────┐
│                    External MCP Servers                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   MCP Server 1 (e.g., https://api.example.com/mcp)       │  │
│  │   MCP Server 2 (e.g., https://another-api.com/mcp)       │  │
│  │   MCP Server 3 (with OAuth)                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

```
User Interaction
    ↓
Component (memoized)
    ↓
Zustand Action
    ↓
State Update (selective)
    ↓
Re-render (optimized)
```

## 🎯 Key Performance Optimizations

### 1. State Management
- **Zustand** over Redux (3kb vs 40kb+)
- Selective subscriptions (components only re-render on relevant state changes)
- Persisted storage with partialize (only save what's needed)

### 2. Component Optimization
- Memoization with `React.memo()`
- Functional updates to prevent stale closures
- Lazy loading of modals

### 3. CSS Performance
- GPU-accelerated transforms
- `will-change` for animated elements
- CSS variables for instant theme switching
- Minimal repaints/reflows

### 4. Bundle Optimization
- Vite for fast HMR (Hot Module Replacement)
- Tree-shaking unused code
- Code splitting ready
- Minimal dependencies

## 📦 Dependencies

### Production (Minimal!)
- `react` (19.x) - UI framework
- `react-dom` (19.x) - React DOM rendering
- `zustand` (5.x) - State management (3kb!)
- `@modelcontextprotocol/sdk` - MCP protocol

### Development
- `vite` - Build tool (fast!)
- `typescript` - Type safety
- `@vitejs/plugin-react` - React support

**Total production bundle**: ~150kb (gzipped)

## 🚀 Performance Metrics (Target)

- **First Paint**: < 500ms
- **Interaction to Next Paint**: < 100ms
- **Bundle Size**: < 200kb gzipped
- **Memory Usage**: < 50MB
- **Frame Rate**: 60fps (GPU acceleration)

## 🧪 Testing Strategy (Future)

```
tests/
├── unit/
│   ├── stores/
│   ├── hooks/
│   └── lib/
├── integration/
│   └── components/
└── e2e/
    └── scenarios/
```

## 🎨 CSS Architecture

### Variables System
All colors, spacing, and transitions defined in CSS variables:
- Easy theming
- Instant updates (no JS)
- Consistent design system

### Naming Convention
- Component-based: `.component-name`
- State modifiers: `.active`, `.error`, `.disabled`
- Utility classes: `.animate-fade-in`, `.gpu-accelerated`

### Animation Strategy
- CSS transforms (GPU) over position/margin
- `transition` for simple state changes
- `animation` for complex sequences
- `will-change` for known animations

## 🔌 MCP Integration

### Client Manager Pattern
```typescript
Singleton MCPClientManager
    ├── manages multiple server connections
    ├── connection pooling
    ├── automatic reconnection (future)
    └── error handling
```

### Transport Support
- **stdio**: Local process communication (fastest)
- **SSE**: Server-Sent Events (real-time)
- **HTTP**: Standard REST (cross-platform)

## 🗺️ Component Hierarchy

```
App
├── Sidebar
│   ├── SidebarHeader
│   │   └── AddServerButton → triggers modal
│   ├── ServersList
│   │   └── ServerItem (memoized)
│   └── ToolsList
│       ├── SearchBox
│       └── ToolItem (memoized)
├── MainArea
│   ├── EmptyState (conditional)
│   └── ToolExecutionView
│       ├── SchemaViewer
│       ├── InputSection
│       │   ├── ModeToggle (Form/JSON)
│       │   ├── FormInput
│       │   └── JsonEditor
│       └── ResultSection
│           ├── ResultTabs
│           └── ResultContent
└── AddServerModal (conditional)
```

## 🎯 Development Workflow

1. **Start dev server**: `npm run dev`
2. **Make changes**: Hot reload instant
3. **Check types**: TypeScript in editor
4. **Build**: `npm run build`
5. **Preview**: `npm run preview`

## 📝 Code Style

- **TypeScript**: Strict mode enabled
- **Functional components**: Hooks-based
- **No default exports**: Named exports only (except App)
- **Memo strategically**: Only for expensive renders
- **CSS Modules**: Scoped styles per component

