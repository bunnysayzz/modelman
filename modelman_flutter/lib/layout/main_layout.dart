import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'tab_bar_panel.dart';
import 'console_panel.dart';

/// Sidebar navigation section identifiers.
enum SidebarSection {
  servers,
  tools,
  chat,
  history,
  settings,
}

/// Provider for the currently active sidebar section.
final sidebarSectionProvider = StateProvider<SidebarSection>(
  (ref) => SidebarSection.servers,
);

/// Responsive breakpoints.
const double _kMobileBreakpoint = 600;
const double _kTabletBreakpoint = 900;

/// Postman-like main layout with header bar, tab bar, sidebar,
/// content area, and collapsible console panel.
///
/// Fully responsive: sidebar collapses to icons on tablet,
/// becomes a bottom nav or drawer on mobile.
/// Supports keyboard shortcuts: Cmd+1-5 for nav, Cmd+K for search.
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kMobileBreakpoint;
    final isTablet = width >= _kMobileBreakpoint && width < _kTabletBreakpoint;

    if (isMobile) {
      return _MobileLayout(theme: theme, child: child);
    }

    // Desktop / Tablet with keyboard shortcuts
    final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return CallbackShortcuts(
      bindings: _buildShortcuts(context, ref, isApple),
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              // ── Header Bar ──────────────────────────────────────
              _HeaderBar(theme: theme),

              // ── Body: Sidebar + Content ─────────────────────────
              Expanded(
                child: Row(
                  children: [
                    _Sidebar(theme: theme, collapsed: isTablet),
                    VerticalDivider(
                        width: 1, thickness: 1, color: theme.dividerColor),
                    Expanded(
                      child: Column(
                        children: [
                          // Tab bar
                          const TabBarPanel(),

                          // Main content
                          Expanded(child: child),

                          // Console log panel
                          const ConsolePanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build keyboard shortcut bindings.
  Map<ShortcutActivator, VoidCallback> _buildShortcuts(
    BuildContext context,
    WidgetRef ref,
    bool isApple,
  ) {
    void navigateTo(int index) {
      const sections = SidebarSection.values;
      const routes = ['/servers', '/tools', '/chat', '/history', '/settings'];
      if (index < sections.length) {
        ref.read(sidebarSectionProvider.notifier).state = sections[index];
        context.go(routes[index]);
      }
    }

    return {
      // Cmd/Ctrl + 1-5 for navigation
      SingleActivator(LogicalKeyboardKey.digit1,
          meta: isApple, control: !isApple): () => navigateTo(0),
      SingleActivator(LogicalKeyboardKey.digit2,
          meta: isApple, control: !isApple): () => navigateTo(1),
      SingleActivator(LogicalKeyboardKey.digit3,
          meta: isApple, control: !isApple): () => navigateTo(2),
      SingleActivator(LogicalKeyboardKey.digit4,
          meta: isApple, control: !isApple): () => navigateTo(3),
      SingleActivator(LogicalKeyboardKey.digit5,
          meta: isApple, control: !isApple): () => navigateTo(4),
    };
  }
}

// ═══════════════════════════════════════════════════════════════
//  MOBILE LAYOUT — uses bottom navigation
// ═══════════════════════════════════════════════════════════════

class _MobileLayout extends ConsumerWidget {
  final ThemeData theme;
  final Widget child;

  const _MobileLayout({required this.theme, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sidebarSectionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.dns_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Modelman',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () {
                      ref.read(sidebarSectionProvider.notifier).state =
                          SidebarSection.settings;
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
            // Content
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sectionIndex(selected),
        onDestinationSelected: (i) => _navigateTo(context, ref, i),
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dns_rounded, size: 20), label: 'Servers'),
          NavigationDestination(icon: Icon(Icons.build_rounded, size: 20), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline, size: 20), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.history_rounded, size: 20), label: 'History'),
        ],
      ),
    );
  }

  int _sectionIndex(SidebarSection section) {
    return switch (section) {
      SidebarSection.servers => 0,
      SidebarSection.tools => 1,
      SidebarSection.chat => 2,
      SidebarSection.history => 3,
      SidebarSection.settings => 0,
    };
  }

  void _navigateTo(BuildContext context, WidgetRef ref, int index) {
    const routes = ['/servers', '/tools', '/chat', '/history'];
    const sections = [
      SidebarSection.servers,
      SidebarSection.tools,
      SidebarSection.chat,
      SidebarSection.history,
    ];
    ref.read(sidebarSectionProvider.notifier).state = sections[index];
    context.go(routes[index]);
  }
}

// ═══════════════════════════════════════════════════════════════
//  HEADER BAR — responsive
// ═══════════════════════════════════════════════════════════════

class _HeaderBar extends StatelessWidget {
  final ThemeData theme;

  const _HeaderBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSearch = width > 700;
    final showWorkspaceBadge = width > 850;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          Icon(Icons.dns_rounded, color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 10),
          Text(
            'Modelman',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),

          if (showWorkspaceBadge) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_rounded, size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'My Workspace',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Search — only when there's room
          if (showSearch) ...[
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search servers, tools...',
                      prefixIcon: Icon(Icons.search, size: 18,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Theme indicator
          IconButton(
            icon: Icon(Icons.palette_outlined, size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onPressed: () => context.go('/settings'),
            tooltip: 'Themes',
          ),

          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.person, size: 18, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SIDEBAR — supports collapsed (icon-only) mode
// ═══════════════════════════════════════════════════════════════

class _Sidebar extends ConsumerWidget {
  final ThemeData theme;
  final bool collapsed;

  const _Sidebar({required this.theme, this.collapsed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sidebarSectionProvider);
    final sidebarWidth = collapsed ? 64.0 : 200.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SidebarItem(
            icon: Icons.dns_rounded,
            label: 'Servers',
            isSelected: selected == SidebarSection.servers,
            collapsed: collapsed,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).state =
                  SidebarSection.servers;
              context.go('/servers');
            },
          ),
          _SidebarItem(
            icon: Icons.build_rounded,
            label: 'Tools',
            isSelected: selected == SidebarSection.tools,
            collapsed: collapsed,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).state =
                  SidebarSection.tools;
              context.go('/tools');
            },
          ),
          _SidebarItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            isSelected: selected == SidebarSection.chat,
            collapsed: collapsed,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).state =
                  SidebarSection.chat;
              context.go('/chat');
            },
          ),
          _SidebarItem(
            icon: Icons.history_rounded,
            label: 'History',
            isSelected: selected == SidebarSection.history,
            collapsed: collapsed,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).state =
                  SidebarSection.history;
              context.go('/history');
            },
          ),
          const Spacer(),
          Divider(height: 1, color: theme.dividerColor),
          _SidebarItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isSelected: selected == SidebarSection.settings,
            collapsed: collapsed,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).state =
                  SidebarSection.settings;
              context.go('/settings');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.collapsed = false,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.isSelected;
    final color = isActive
        ? theme.colorScheme.primary
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.85)
            : theme.colorScheme.onSurface.withOpacity(0.65);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Tooltip(
        message: widget.collapsed ? widget.label : '',
        waitDuration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 6 : 8,
              vertical: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                  : _hovering
                      ? theme.colorScheme.onSurface.withOpacity(0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.collapsed
                ? Center(child: Icon(widget.icon, size: 20, color: color))
                : Row(
                    children: [
                      Icon(widget.icon, size: 20, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
