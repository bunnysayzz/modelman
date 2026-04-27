import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_data.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../data/services/settings_service.dart';

/// Full Settings page with tabbed categories — fully responsive.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _categories = const [
    ('Appearance', Icons.palette_outlined),
    ('General', Icons.tune_outlined),
    ('Editor', Icons.code_outlined),
    ('Network', Icons.wifi_outlined),
    ('Data', Icons.storage_outlined),
    ('Advanced', Icons.developer_mode_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 700;
    final edgePadding = isNarrow ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(edgePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Category tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: _categories
                  .map((c) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.$2, size: 16),
                            const SizedBox(width: 6),
                            Text(c.$1),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Tab content — constrained for readability
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AppearanceTab(),
                _GeneralTab(),
                _EditorTab(),
                _NetworkTab(),
                _DataTab(),
                _AdvancedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appearance Tab ── responsive theme grid

class _AppearanceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedTheme = ref.watch(selectedThemeProvider);
    final settings = ref.watch(settingsProvider);
    final width = MediaQuery.of(context).size.width;

    // Adaptive column count: 2 on mobile, 3 on tablet, 4 on desktop
    final crossAxisCount = width < 500 ? 2 : width < 800 ? 3 : 4;

    return ListView(
      children: [
        _SectionHeader('Theme'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppThemeType.values.map((themeType) {
                final isSelected = themeType == selectedTheme;
                final themeData = AppThemeData.getThemeData(themeType);
                final cardWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 10) /
                        crossAxisCount;

                return SizedBox(
                  width: cardWidth.clamp(100.0, 200.0),
                  height: 70,
                  child: InkWell(
                    onTap: () {
                      ref.read(selectedThemeProvider.notifier).setTheme(themeType);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _dot(themeData.colorScheme.primary),
                              const SizedBox(width: 3),
                              _dot(themeData.colorScheme.secondary),
                              const SizedBox(width: 3),
                              _dot(themeData.scaffoldBackgroundColor),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            themeType.displayName,
                            style: TextStyle(
                              color: themeData.colorScheme.onSurface,
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),
        _SectionHeader('Display'),
        _SettingsSwitch(
          title: 'Enable Animations',
          subtitle: 'Smooth transitions and micro-animations',
          value: settings.enableAnimations,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(enableAnimations: v)),
        ),
        _SettingsSwitch(
          title: 'Compact Mode',
          subtitle: 'Reduce padding and spacing',
          value: settings.compactMode,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(compactMode: v)),
        ),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

// ── General Tab ──

class _GeneralTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      children: [
        _SectionHeader('Connection'),
        _SettingsSwitch(
          title: 'Auto-Reconnect Servers',
          subtitle: 'Automatically reconnect when connection is lost',
          value: settings.autoReconnectServers,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(autoReconnectServers: v)),
        ),
        _SettingsSlider(
          title: 'Connection Timeout',
          value: settings.connectionTimeout.toDouble(),
          min: 5,
          max: 120,
          suffix: 's',
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(connectionTimeout: v.toInt())),
        ),
        _SettingsSlider(
          title: 'Request Timeout',
          value: settings.requestTimeout.toDouble(),
          min: 10,
          max: 300,
          suffix: 's',
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(requestTimeout: v.toInt())),
        ),
      ],
    );
  }
}

// ── Editor Tab ──

class _EditorTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      children: [
        _SectionHeader('Code Editor'),
        _SettingsSwitch(
          title: 'Syntax Highlighting',
          value: settings.enableSyntaxHighlighting,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(enableSyntaxHighlighting: v)),
        ),
        _SettingsSwitch(
          title: 'Auto-Complete',
          value: settings.enableAutoComplete,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(enableAutoComplete: v)),
        ),
        _SettingsSwitch(
          title: 'Show Line Numbers',
          value: settings.showLineNumbers,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(showLineNumbers: v)),
        ),
        _SettingsSwitch(
          title: 'Word Wrap',
          value: settings.wordWrap,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(wordWrap: v)),
        ),
        _SettingsSlider(
          title: 'Tab Size',
          value: settings.tabSize.toDouble(),
          min: 2,
          max: 8,
          divisions: 3,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(tabSize: v.toInt())),
        ),
      ],
    );
  }
}

// ── Network Tab ──

class _NetworkTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      children: [
        _SectionHeader('Request Settings'),
        _SettingsSlider(
          title: 'Max Concurrent Requests',
          value: settings.maxConcurrentRequests.toDouble(),
          min: 1,
          max: 20,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(maxConcurrentRequests: v.toInt())),
        ),
      ],
    );
  }
}

// ── Data Tab ──

class _DataTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      children: [
        _SectionHeader('History'),
        _SettingsSwitch(
          title: 'Enable History',
          subtitle: 'Store tool execution history',
          value: settings.enableHistory,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(enableHistory: v)),
        ),
        _SettingsSlider(
          title: 'Max History Entries',
          value: settings.maxHistoryEntries.toDouble(),
          min: 10,
          max: 500,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(maxHistoryEntries: v.toInt())),
        ),
        const SizedBox(height: 16),
        _SectionHeader('Cache'),
        _SettingsSwitch(
          title: 'Enable Cache',
          value: settings.enableCache,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(enableCache: v)),
        ),
        _SettingsSlider(
          title: 'Max Cache Size',
          value: settings.maxCacheSize.toDouble(),
          min: 10,
          max: 200,
          suffix: ' MB',
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(maxCacheSize: v.toInt())),
        ),
      ],
    );
  }
}

// ── Advanced Tab ──

class _AdvancedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return ListView(
      children: [
        _SectionHeader('Debugging'),
        _SettingsSwitch(
          title: 'Debug Mode',
          subtitle: 'Show debug information in the UI',
          value: settings.debugMode,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(debugMode: v)),
        ),
        _SettingsSwitch(
          title: 'Verbose Logging',
          subtitle: 'Log all API requests and responses',
          value: settings.verboseLogging,
          onChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update((s) => s.copyWith(verboseLogging: v)),
        ),
        const SizedBox(height: 24),
        _SectionHeader('Danger Zone'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _confirmReset(context, ref),
            icon: Icon(Icons.restore, color: theme.colorScheme.error),
            label: Text(
              'Reset All Settings',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings?'),
        content:
            const Text('This will reset all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).reset();
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Shared settings widgets — responsive ──

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

/// Slider with responsive label — stacks vertically on narrow screens.
class _SettingsSlider extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? suffix;
  final ValueChanged<double> onChanged;

  const _SettingsSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 600;

    if (isNarrow) {
      // Stack vertically on mobile
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                Text(
                  '${value.toInt()}${suffix ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions ?? (max - min).toInt(),
              onChanged: onChanged,
            ),
          ],
        ),
      );
    }

    // Side-by-side on desktop
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 4,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions ?? (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${value.toInt()}${suffix ?? ''}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
