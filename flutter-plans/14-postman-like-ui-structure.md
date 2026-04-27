# Postman-Like UI Structure

## Overview

This document details the Postman-inspired UI structure for modelman, ensuring a professional, properly structured interface with navigation, workspaces, and organized layout.

## Postman UI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Postman-Like Layout                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  HEADER BAR (Top)                                       │ │
│  │  - Logo | Workspace Selector | Search | User Menu      │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌──────────┬──────────────────────────────────────────────┐ │
│  │          │                                              │ │
│  │  SIDEBAR │              MAIN CONTENT AREA               │ │
│  │          │                                              │ │
│  │  ┌────┐  │  ┌────────────────────────────────────────┐  │ │
│  │  │Nav │  │  │  TAB BAR                              │  │ │
│  │  │    │  │  │  - Server 1 [x]  |  Tool 2 [x]  | +   │  │ │
│  │  ├────┤  │  └────────────────────────────────────────┘  │ │
│  │  │    │  │                                              │ │
│  │  │Serv│  │  ┌────────────────────────────────────────┐  │ │
│  │  │ers │  │  │  REQUEST/RESPONSE PANEL                 │  │ │
│  │  │    │  │  │  ┌──────────┬─────────────────────┐     │  │ │
│  │  ├────┤  │  │  │          │                      │     │  │ │
│  │  │    │  │  │  │  LEFT    │       RIGHT          │     │  │ │
│  │  │Tool│  │  │  │  PANEL   │       PANEL          │     │  │ │
│  │  │s   │  │  │  │          │                      │     │  │ │
│  │  │    │  │  │  │ Params   │  Response Body       │     │  │ │
│  │  ├────┤  │  │  │ Headers   │  Response Headers    │     │  │ │
│  │  │    │  │  │  │ Auth     │  Response Time       │     │  │ │
│  │  │Hist│  │  │  │ Body     │  Response Size       │     │  │ │
│  │  │ory │  │  │  │          │                      │     │  │ │
│  │  │    │  │  │  └──────────┴─────────────────────┘     │  │ │
│  │  ├────┤  │  │                                          │  │ │
│  │  │    │  │  │  ┌────────────────────────────────────┐ │  │ │
│  │  │Sett│  │  │  │  ACTION BAR (Send, Save, etc.)     │ │  │ │
│  │  │ings│  │  │  └────────────────────────────────────┘ │  │ │
│  │  └────┘  │  └────────────────────────────────────────┘  │ │
│  │          │                                              │ │
│  │          │  ┌────────────────────────────────────────┐  │ │
│  │          │  │  CONSOLE/LOG PANEL (Collapsible)       │  │ │
│  │          │  └────────────────────────────────────────┘  │ │
│  │          │                                              │ │
│  └──────────┴──────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Main Layout Structure

### lib/main_layout.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'layout/header_bar.dart';
import 'layout/sidebar.dart';
import 'layout/tab_bar.dart';
import 'layout/content_area.dart';
import 'layout/console_panel.dart';

class PostmanLayout extends ConsumerStatefulWidget {
  const PostmanLayout({super.key});

  @override
  ConsumerState<PostmanLayout> createState() => _PostmanLayoutState();
}

class _PostmanLayoutState extends ConsumerState<PostmanLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Bar
          const HeaderBar(),
          
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                const Sidebar(),
                
                // Main Area
                Expanded(
                  child: Column(
                    children: [
                      // Tab Bar
                      const TabBarPanel(),
                      
                      // Content Area
                      const Expanded(
                        child: ContentArea(),
                      ),
                      
                      // Console Panel (Collapsible)
                      const ConsolePanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Header Bar

### lib/layout/header_bar.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderBar extends ConsumerWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.dns, size: 24),
                const SizedBox(width: 8),
                Text(
                  'modelman',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          
          // Workspace Selector
          const WorkspaceSelector(),
          
          const Spacer(),
          
          // Search
          const HeaderSearch(),
          
          const SizedBox(width: 16),
          
          // User Menu
          const UserMenu(),
        ],
      ),
    );
  }
}

class WorkspaceSelector extends ConsumerWidget {
  const WorkspaceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open, size: 18),
          const SizedBox(width: 8),
          Text(
            'My Workspace',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}

class HeaderSearch extends StatelessWidget {
  const HeaderSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      onSelected: (value) {
        switch (value) {
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            // Handle logout
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }
}
```

## Sidebar Navigation

### lib/layout/sidebar.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(sidebarSectionProvider);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SidebarItem(
            icon: Icons.dns,
            label: 'Servers',
            isSelected: selectedSection == SidebarSection.servers,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).setSection(SidebarSection.servers);
            },
          ),
          _SidebarItem(
            icon: Icons.build,
            label: 'Tools',
            isSelected: selectedSection == SidebarSection.tools,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).setSection(SidebarSection.tools);
            },
          ),
          _SidebarItem(
            icon: Icons.chat,
            label: 'Chat',
            isSelected: selectedSection == SidebarSection.chat,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).setSection(SidebarSection.chat);
            },
          ),
          _SidebarItem(
            icon: Icons.history,
            label: 'History',
            isSelected: selectedSection == SidebarSection.history,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).setSection(SidebarSection.history);
            },
          ),
          _SidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: selectedSection == SidebarSection.settings,
            onTap: () {
              ref.read(sidebarSectionProvider.notifier).setSection(SidebarSection.settings);
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SidebarSection {
  servers,
  tools,
  chat,
  history,
  settings,
}

@riverpod
class SidebarSection extends _$SidebarSection {
  @override
  SidebarSection build() => SidebarSection.servers;

  void setSection(SidebarSection section) {
    state = section;
  }
}
```

## Tab Bar Panel

### lib/layout/tab_bar.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabBarPanel extends ConsumerWidget {
  const TabBarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(openTabsProvider);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length + 1,
        itemBuilder: (context, index) {
          if (index == tabs.length) {
            // Add new tab button
            return _AddTabButton();
          }

          final tab = tabs[index];
          return _TabItem(
            tab: tab,
            isSelected: index == tabs.length - 1,
            onClose: () {
              ref.read(openTabsProvider.notifier).closeTab(tab.id);
            },
            onTap: () {
              ref.read(openTabsProvider.notifier).selectTab(tab.id);
            },
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surfaceVariant,
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            top: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForType(tab.type),
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              tab.title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(TabType type) {
    switch (type) {
      case TabType.server:
        return Icons.dns;
      case TabType.tool:
        return Icons.build;
      case TabType.chat:
        return Icons.chat;
    }
  }
}

class _AddTabButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Show add tab menu
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border(
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class TabItem {
  final String id;
  final String title;
  final TabType type;
  final dynamic data;

  TabItem({
    required this.id,
    required this.title,
    required this.type,
    this.data,
  });
}

enum TabType { server, tool, chat }

@riverpod
class OpenTabs extends _$OpenTabs {
  @override
  List<TabItem> build() => [];

  void addTab(TabItem tab) {
    state = [...state, tab];
  }

  void closeTab(String tabId) {
    state = state.where((t) => t.id != tabId).toList();
  }

  void selectTab(String tabId) {
    // Move tab to end (selected)
    final index = state.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      final tab = state[index];
      state = [
        ...state.sublist(0, index),
        ...state.sublist(index + 1),
        tab,
      ];
    }
  }
}
```

## Content Area with Split Panels

### lib/layout/content_area.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'panels/left_panel.dart';
import 'panels/right_panel.dart';
import 'panels/action_bar.dart';

class ContentArea extends ConsumerWidget {
  const ContentArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Action Bar
        const ActionBar(),
        
        // Split Panels
        Expanded(
          child: Row(
            children: [
              // Left Panel (Request/Params)
              const Expanded(
                flex: 1,
                child: LeftPanel(),
              ),
              
              // Resizable Divider
              _ResizeDivider(
                onResize: (width) {
                  ref.read(panelWidthProvider.notifier).setLeftWidth(width);
                },
              ),
              
              // Right Panel (Response)
              Expanded(
                flex: 1,
                child: RightPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResizeDivider extends StatefulWidget {
  final ValueChanged<double> onResize;

  const _ResizeDivider({required this.onResize});

  @override
  State<_ResizeDivider> createState() => _ResizeDividerState();
}

class _ResizeDividerState extends State<_ResizeDivider> {
  double _startX = 0;
  double _startWidth = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startX = details.globalPosition.dx;
        _startWidth = MediaQuery.of(context).size.width / 2;
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.globalPosition.dx - _startX;
        widget.onResize(_startWidth + delta);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
          ),
          child: Center(
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@riverpod
class PanelWidth extends _$PanelWidth {
  @override
  double build() => 0.5;

  void setLeftWidth(double width) {
    final screenWidth = MediaQueryData.fromContext(context).size.width;
    state = width / screenWidth;
  }
}
```

## Left Panel (Request/Params)

### lib/layout/panels/left_panel.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(leftPanelTabProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Tab Headers
          _LeftPanelTabs(
            selectedTab: selectedTab,
            onTabChanged: (tab) {
              ref.read(leftPanelTabProvider.notifier).setTab(tab);
            },
          ),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(selectedTab),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(LeftPanelTab tab) {
    switch (tab) {
      case LeftPanelTab.params:
        return const ParamsTab();
      case LeftPanelTab.headers:
        return const HeadersTab();
      case LeftPanelTab.auth:
        return const AuthTab();
      case LeftPanelTab.body:
        return const BodyTab();
    }
  }
}

enum LeftPanelTab { params, headers, auth, body }

@riverpod
class LeftPanelTab extends _$LeftPanelTab {
  @override
  LeftPanelTab build() => LeftPanelTab.params;

  void setTab(LeftPanelTab tab) {
    state = tab;
  }
}

class _LeftPanelTabs extends StatelessWidget {
  final LeftPanelTab selectedTab;
  final ValueChanged<LeftPanelTab> onTabChanged;

  const _LeftPanelTabs({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Row(
        children: LeftPanelTab.values.map((tab) {
          return _TabHeader(
            label: tab.name.toUpperCase(),
            isSelected: selectedTab == tab,
            onTap: () => onTabChanged(tab),
          );
        }).toList(),
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabHeader({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          border: Border(
            bottom: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// Tab content widgets
class ParamsTab extends StatelessWidget {
  const ParamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class HeadersTab extends StatelessWidget {
  const HeadersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AuthTab extends StatelessWidget {
  const AuthTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

## Right Panel (Response)

### lib/layout/panels/right_panel.dart

```dart
import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          // Response Status Bar
          _ResponseStatus(),
          
          // Response Body
          Expanded(
            child: _ResponseBody(),
          ),
          
          // Response Metadata
          _ResponseMetadata(),
        ],
      ),
    );
  }
}

class _ResponseStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '200 OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text('145ms'),
          const SizedBox(width: 16),
          const Text('2.4 KB'),
        ],
      ),
    );
  }
}

class _ResponseBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _ResponseMetadata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text('Headers'),
          const SizedBox(width: 16),
          const Text('Cookies'),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
```

## Console Panel (Collapsible)

### lib/layout/console_panel.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsolePanel extends ConsumerWidget {
  const ConsolePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(consoleVisibleProvider);
    final height = ref.watch(consoleHeightProvider);

    if (!isVisible) {
      return _ConsoleToggle(
        onTap: () {
          ref.read(consoleVisibleProvider.notifier).toggle();
        },
      );
    }

    return Column(
      children: [
        _ConsoleToggle(
          onTap: () {
            ref.read(consoleVisibleProvider.notifier).toggle();
          },
        ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Console Header
              _ConsoleHeader(
                onResize: (newHeight) {
                  ref.read(consoleHeightProvider.notifier).setHeight(newHeight);
                },
              ),
              
              // Console Content
              const Expanded(
                child: _ConsoleContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsoleToggle extends StatelessWidget {
  final VoidCallback onTap;

  const _ConsoleToggle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.terminal,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            'Console',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            child: Icon(
              Icons.expand_more,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleHeader extends StatelessWidget {
  final ValueChanged<double> onResize;

  const _ConsoleHeader({required this.onResize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        onResize(details.delta.dy);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Text('Console Logs'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () {
                // Clear console
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsoleContent extends StatelessWidget {
  const _ConsoleContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _LogEntry(
          timestamp: '10:23:45',
          level: LogLevel.info,
          message: 'GET /api/servers - 200 OK',
        ),
        _LogEntry(
          timestamp: '10:23:46',
          level: LogLevel.success,
          message: 'Tool executed successfully',
        ),
        _LogEntry(
          timestamp: '10:23:47',
          level: LogLevel.warning,
          message: 'Connection slow: 500ms',
        ),
      ],
    );
  }
}

class _LogEntry extends StatelessWidget {
  final String timestamp;
  final LogLevel level;
  final String message;

  const _LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timestamp,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              level.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.success:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }
}

enum LogLevel { info, success, warning, error }

@riverpod
class ConsoleVisible extends _$ConsoleVisible {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

@riverpod
class ConsoleHeight extends _$ConsoleHeight {
  @override
  double build() => 200;

  void setHeight(double height) {
    state = (state + height).clamp(100, 500);
  }
}
```

## Action Bar

### lib/layout/panels/action_bar.dart

```dart
import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Method Selector
          _MethodSelector(),
          const SizedBox(width: 12),
          
          // URL Input
          const Expanded(
            child: _UrlInput(),
          ),
          
          const SizedBox(width: 12),
          
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {},
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
                tooltip: 'Send',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodSelector extends StatefulWidget {
  @override
  State<_MethodSelector> createState() => _MethodSelectorState();
}

class _MethodSelectorState extends State<_MethodSelector> {
  String _selectedMethod = 'GET';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          items: const [
            DropdownMenuItem(value: 'GET', child: Text('GET')),
            DropdownMenuItem(value: 'POST', child: Text('POST')),
            DropdownMenuItem(value: 'PUT', child: Text('PUT')),
            DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
            DropdownMenuItem(value: 'PATCH', child: Text('PATCH')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMethod = value!;
            });
          },
        ),
      ),
    );
  }
}

class _UrlInput extends StatelessWidget {
  const _UrlInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter request URL',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }
}
```

## Responsive Design

### lib/layout/responsive_layout.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsiveLayout extends ConsumerWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 768) {
      return mobile;
    } else if (screenWidth < 1200) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

// Mobile layout with drawer navigation
class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MobileDrawer(),
      body: const MobileContent(),
    );
  }
}

// Tablet layout with collapsible sidebar
class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CollapsibleSidebar(),
        Expanded(child: const ContentArea()),
      ],
    );
  }
}

// Desktop layout with full sidebar
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostmanLayout();
  }
}
```

## Migration Checklist

- [ ] Implement Header Bar with workspace selector
- [ ] Implement Sidebar navigation
- [ ] Implement Tab Bar panel
- [ ] Implement Content Area with split panels
- [ ] Implement Left Panel (Params, Headers, Auth, Body)
- [ ] Implement Right Panel (Response)
- [ ] Implement Action Bar
- [ ] Implement Console Panel
- [ ] Implement resizable dividers
- [ ] Add responsive layout support
- [ ] Test on different screen sizes
- [ ] Ensure smooth animations and transitions
- [ ] Add keyboard shortcuts support
- [ ] Implement drag and drop for tabs
- [ ] Add context menus

## Next Steps

1. Review `15-settings-configuration.md` for settings implementation
2. Implement workspace management
3. Add keyboard shortcuts
4. Implement drag and drop functionality
