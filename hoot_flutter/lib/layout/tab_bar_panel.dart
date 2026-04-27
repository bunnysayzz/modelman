import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single open tab in the Postman-like tab bar.
class TabItem {
  final String id;
  final String title;
  final IconData icon;
  final TabType type;

  const TabItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
  });
}

enum TabType { server, tool, chat, settings }

/// Notifier for the list of open tabs.
class TabListNotifier extends StateNotifier<List<TabItem>> {
  TabListNotifier() : super([]);

  void openTab(TabItem tab) {
    // Don't duplicate
    if (state.any((t) => t.id == tab.id)) {
      // Just select it
      return;
    }
    state = [...state, tab];
  }

  void closeTab(String tabId) {
    state = state.where((t) => t.id != tabId).toList();
  }

  void closeAll() {
    state = [];
  }
}

final openTabsProvider =
    StateNotifierProvider<TabListNotifier, List<TabItem>>(
  (ref) => TabListNotifier(),
);

final selectedTabIdProvider = StateProvider<String?>((ref) => null);

/// Tab bar panel showing open tabs with close buttons.
class TabBarPanel extends ConsumerWidget {
  const TabBarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(openTabsProvider);
    final selectedTabId = ref.watch(selectedTabIdProvider);
    final theme = Theme.of(context);

    if (tabs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = tab.id == selectedTabId;

                return _TabChip(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedTabIdProvider.notifier).state = tab.id;
                  },
                  onClose: () {
                    ref.read(openTabsProvider.notifier).closeTab(tab.id);
                    if (selectedTabId == tab.id) {
                      final remaining =
                          tabs.where((t) => t.id != tab.id).toList();
                      ref.read(selectedTabIdProvider.notifier).state =
                          remaining.isNotEmpty ? remaining.last.id : null;
                    }
                  },
                );
              },
            ),
          ),
          // New tab button
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () {},
            tooltip: 'New Tab',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatefulWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.scaffoldBackgroundColor
                : _hovering
                    ? theme.colorScheme.onSurface.withOpacity(0.05)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.tab.icon, size: 14,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                widget.tab.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 6),
              if (_hovering || widget.isSelected)
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(Icons.close, size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
