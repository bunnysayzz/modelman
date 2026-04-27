import '../config/app_config.dart';

/// Centralized API endpoint constants.
///
/// Maps all backend routes from the Node.js/Express server to
/// string constants used by the Dio API service layer.
class ApiConstants {
  ApiConstants._();

  // Base URL
  static String get baseUrl => AppConfig.backendUrl;

  // Health
  static const String health = '/health';

  // Authentication
  static const String authToken = '/auth/token';

  // MCP Server Operations
  static const String mcpAutoDetect = '/mcp/auto-detect';
  static const String mcpConnect = '/mcp/connect';
  static const String mcpDisconnect = '/mcp/disconnect';
  static const String mcpTools = '/mcp/tools';
  static const String mcpExecute = '/mcp/execute';
  static const String mcpStatus = '/mcp/status';
  static const String mcpConnections = '/mcp/connections';
  static const String mcpServerInfo = '/mcp/server-info';
  static const String mcpOAuthMetadata = '/mcp/oauth-metadata';
  static const String mcpFavicon = '/mcp/favicon';
  static const String mcpFaviconProxy = '/mcp/favicon-proxy';

  // Tool Filter Endpoints
  static const String toolFilterInitialize = '/mcp/tool-filter/initialize';
  static const String toolFilterFilter = '/mcp/tool-filter/filter';
  static const String toolFilterStats = '/mcp/tool-filter/stats';
  static const String toolFilterClearCache = '/mcp/tool-filter/clear-cache';

  // Chat/AI Endpoints
  static const String chatSend = '/chat/send';
  static const String chatStream = '/chat/stream';

  // Headers
  static const String contentType = 'application/json';
  static const String authHeader = 'x-hoot-token';
}
