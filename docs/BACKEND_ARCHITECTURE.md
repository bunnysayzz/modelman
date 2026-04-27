# Backend MCP Architecture

## Overview

The modelman MCP client has been redesigned to eliminate CORS issues by using a **Node.js backend relay architecture**. Instead of the browser connecting directly to MCP servers, it now communicates with a local Node.js backend that acts as the MCP client.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser App                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   React Components (UI)                                   │  │
│  │   ├── ServerSidebar.tsx                                   │  │
│  │   ├── ToolsSidebar.tsx                                    │  │
│  │   └── MainArea.tsx                                        │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │   Frontend MCP Client (mcpClient.ts)                      │  │
│  │   └── Acts as relay to backend                           │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │   Backend API Client (backendClient.ts)                   │  │
│  │   └── HTTP calls to localhost:3002                       │  │
│  └──────────────────────┬───────────────────────────────────┘  │
└─────────────────────────┼──────────────────────────────────────┘
                          │ HTTP (localhost:3002)
                          │ No CORS issues!
┌─────────────────────────▼──────────────────────────────────────┐
│                   Node.js Backend Server                         │
│              (mcp-backend-server.js on port 3002)               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │   REST API                                                │  │
│  │   ├── POST /mcp/connect                                   │  │
│  │   ├── POST /mcp/disconnect                                │  │
│  │   ├── GET  /mcp/tools/:serverId                          │  │
│  │   ├── POST /mcp/execute                                   │  │
│  │   ├── GET  /mcp/status/:serverId                         │  │
│  │   └── GET  /mcp/connections                              │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │   MCP SDK Client Manager                                  │  │
│  │   ├── Client instances (Map<serverId, Client>)           │  │
│  │   ├── Transport instances (SSE/HTTP)                     │  │
│  │   └── OAuth state management                             │  │
│  └──────────────────────┬───────────────────────────────────┘  │
└─────────────────────────┼──────────────────────────────────────┘
                          │ StreamableHTTPClientTransport
                          │ or SSEClientTransport
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

## Key Components

### Backend Server (`server/server-node.js`)

**Location**: `server/server-node.js`  
**Port**: 8008 (configurable via `PORT` env var)  
**Purpose**: Acts as the actual MCP client, managing connections to MCP servers

**Features**:
- ✅ Full MCP SDK integration (SSE & HTTP transports)
- ✅ OAuth 2.1 support with authorization code flow
- ✅ Multiple concurrent server connections
- ✅ Session management (stores active connections)
- ✅ Graceful shutdown and cleanup
- ✅ No CORS issues (server-to-server communication)

**API Endpoints**:
- `POST /mcp/connect` - Connect to an MCP server
- `POST /mcp/disconnect` - Disconnect from a server
- `POST /mcp/auto-detect` - Auto-detect server configuration
- `GET /mcp/tools/:serverId` - List available tools
- `POST /mcp/execute` - Execute a tool
- `GET /mcp/status/:serverId` - Check connection status
- `GET /mcp/connections` - List all active connections
- `GET /health` - Health check
- ...and more (18 endpoints total)

### 2. Backend API Client (`src/lib/backendClient.ts`)

**Purpose**: Browser-side HTTP client for communicating with the backend

**Functions**:
- `isBackendAvailable()` - Check if backend is running
- `connectToServer()` - Request connection to MCP server
- `disconnectFromServer()` - Disconnect from server
- `listTools()` - Fetch available tools
- `executeTool()` - Execute a tool
- `getConnectionStatus()` - Check connection status
- `getConnections()` - Get all connections

### 3. Frontend MCP Client (`src/lib/mcpClient.ts`)

**Purpose**: Relay layer between React components and backend API

**Changes from previous version**:
- ❌ No longer creates `Client` instances directly
- ❌ No longer manages transports
- ✅ Delegates all MCP operations to backend
- ✅ Still manages OAuth provider instances (for URL generation)
- ✅ Maintains connection state

### 4. React Hooks (`src/hooks/useMCP.ts`)

**No changes required!** The hooks continue to use the same `mcpClient` interface, which now transparently relays to the backend.

## Data Flow

### Connection Flow

```
1. User clicks "Connect" in UI
   ↓
2. mcpClient.connect() relays to backendClient
   ↓
3. HTTP POST to localhost:8008/mcp/connect
   ↓
4. Backend creates MCP Client + Transport
   ↓
5. Backend connects using MCP SDK
   ↓
6. Response sent back to browser
   ↓
7. UI updates connection status
```

### Tool Execution Flow

```
1. User fills form and clicks "Execute"
   ↓
2. mcpClient.executeTool() relays to backendClient
   ↓
3. HTTP POST to localhost:8008/mcp/execute
   ↓
4. Backend calls client.callTool()
   ↓
5. MCP SDK sends request to external server
   ↓
6. Response received and returned to browser
   ↓
7. UI displays result
```

### OAuth Flow

```
1. User connects to OAuth-enabled server
   ↓
2. Backend returns 401 UnauthorizedError
   ↓
3. Frontend detects OAuth requirement
   ↓
4. OAuthProvider generates authorization URL
   ↓
5. User redirected to authorization page
   ↓
6. User authorizes, redirected back with code
   ↓
7. Frontend reconnects with authorization code
   ↓
8. Backend calls transport.finishAuth(code)
   ↓
9. Connection established with OAuth tokens
```

## Benefits of This Architecture

### 1. **No More CORS Issues** 🎉
- Browser communicates with local backend (same origin allowed)
- Backend communicates server-to-server (no CORS restrictions)
- Works with any MCP server, regardless of CORS headers

### 2. **Security** 🔒
- OAuth tokens stored in backend memory (never in browser)
- Credentials and auth headers not exposed to browser
- More secure than browser-based authentication

### 3. **Maintainability** 🛠️
- Clean separation of concerns
- Backend handles MCP protocol complexity
- Frontend focuses on UI/UX

### 4. **Compatibility** ✅
- Works with all MCP transports (SSE, HTTP)
- Full OAuth 2.1 support maintained
- No breaking changes to existing MCP servers

### 5. **Performance** ⚡
- Backend maintains persistent connections
- No need to reconnect on page refresh (future enhancement)
- Efficient connection pooling

## Running the Application

### Development Mode (with backend)

```bash
# Start both backend and frontend together
npm run dev:full
```

This runs:
- Backend server on `http://localhost:8008`
- Vite dev server on `http://localhost:8009`

### Manual Start

```bash
# Terminal 1: Start backend
npm run server

# Terminal 2: Start frontend
npm run dev
```


## Migration Notes

### What Changed

1. **Backend server required**: You must run `npm run backend` or `npm run dev:full`
2. **No direct MCP SDK usage in browser**: All SDK operations moved to backend
3. **New API client**: `backendClient.ts` handles HTTP communication

### What Stayed the Same

1. **React components**: No changes needed
2. **Hooks**: Same interface, same usage
3. **Store**: No changes to Zustand store
4. **OAuth flow**: Still works identically from user perspective
5. **UI/UX**: No changes to user experience

### Breaking Changes

None! The API remains the same from the component perspective.

## Troublesmodelmaning

### Backend not running

**Error**: "Backend server is not running. Please start it with: npm run server"

**Solution**: 
```bash
npm run server
```

### Port 8008 already in use

**Error**: "Port 8008 is already in use!"

**Solution**:
```bash
# Find process using port 8008
lsof -ti:8008

# Kill the process
lsof -ti:8008 | xargs kill -9

# Restart backend
npm run server
```

### Connection fails even with backend running

**Check**:
1. Backend health: `curl http://localhost:8008/health`
2. Check backend logs for errors
3. Verify MCP server URL is correct
4. Check authentication configuration

## Future Enhancements

### Persistent Connections
- Store connection state in database
- Reconnect to servers after browser refresh
- Background connection health checks

### Connection Pooling
- Reuse connections across browser sessions
- Share connections between multiple users (optional)

### Caching
- Cache tool schemas
- Cache frequently used tool results
- Reduce redundant API calls

### WebSocket Support
- Real-time updates from MCP servers
- Live connection status
- Streaming tool results

## Testing

### Test Backend Health

```bash
curl http://localhost:8008/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "modelman Backend Server is running",
  "port": 8008,
  "activeConnections": 0
}
```

### Test Connection

```bash
curl -X POST http://localhost:8008/mcp/connect \
  -H "Content-Type: application/json" \
  -d '{
    "serverId": "test-server",
    "serverName": "Test Server",
    "url": "https://example.com/mcp",
    "transport": "http",
    "auth": { "type": "none" }
  }'
```

### Test Tool Listing

```bash
curl http://localhost:8008/mcp/tools/test-server
```

## Architecture Decisions

### Why Node.js Backend?

1. **MCP SDK is Node-first**: Official SDK works best in Node.js environment
2. **No CORS limitations**: Server-to-server communication
3. **Better security**: Keep credentials and tokens server-side
4. **Persistent connections**: Can maintain connections beyond browser session

### Why HTTP API instead of WebSocket?

1. **Simplicity**: REST API is easier to understand and debug
2. **Stateless**: Each request is independent
3. **Compatibility**: Works everywhere, no special configuration
4. **Future upgrade path**: Can add WebSocket later for real-time features

### Why Port 8008?

- Port 8008 is commonly used for backend services
- Can be changed if needed (update `PORT` env var in backend)

## Conclusion

The new backend relay architecture provides a robust, secure, and CORS-free solution for connecting to MCP servers from the browser. It maintains all existing functionality while providing better security and reliability.

The MCP SDK usage remains exactly as before on the backend, ensuring compatibility and leveraging all the SDK's features including OAuth, multiple transports, and connection management.

