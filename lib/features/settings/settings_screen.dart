import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/shell/shell_providers.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

/// `/settings` (DESIGN_SPEC §6, CHEESE-31): mono-labelled groups of
/// bordered cards. Theme and units persist through [AppSettings]; the
/// deferred rows (reminder, CSV export) sit disabled at 45 %.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const disabledOpacity = 0.45;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).asData?.value ?? const AppSettings();
    final version = ref.watch(appVersionProvider).asData?.value;
    final c = context.colors;
    final x = context.scribe;
    final repo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open menu',
          onPressed: () => ScribeShell.openDrawer(context),
          icon: HeroIcon(HeroIcons.bars3, size: 24, color: c.onSurfaceVariant),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SettingsGroup(
            label: 'Appearance',
            children: [
              _ChoiceRow<ThemeMode>(
                title: 'Theme',
                value: settings.themeMode,
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ],
                onChanged: (m) => repo.update((s) => s.copyWith(themeMode: m)),
              ),
              _ChoiceRow<PriceUnit>(
                title: 'Units',
                subtitle: 'Default for new notes. Nothing gets converted.',
                value: settings.units,
                segments: const [
                  ButtonSegment(
                    value: PriceUnit.usdPerLb,
                    label: Text(r'$/lb'),
                  ),
                  ButtonSegment(value: PriceUnit.eurPerKg, label: Text('€/kg')),
                ],
                onChanged: (u) => repo.update((s) => s.copyWith(units: u)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            label: 'Notifications',
            children: [
              Opacity(
                opacity: disabledOpacity,
                child: ListTile(
                  key: const Key('reminder-row'),
                  enabled: false,
                  title: const Text("Weekly 'go eat cheese' reminder"),
                  subtitle: const Text('Coming soon. The cheese will wait.'),
                  trailing: const Switch(value: false, onChanged: null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            label: 'Data',
            children: [
              Opacity(
                opacity: disabledOpacity,
                child: ListTile(
                  key: const Key('export-row'),
                  enabled: false,
                  title: const Text('Export my notes (CSV)'),
                  subtitle: const Text('Coming soon.'),
                  trailing: HeroIcon(
                    HeroIcons.chevronRight,
                    size: 18,
                    color: x.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            label: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                trailing: MonoLabel(version ?? '—', color: c.onSurfaceVariant),
              ),
              ListTile(
                title: const Text('Open-source licenses'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Cheesy Scribe',
                  applicationVersion: version,
                ),
              ),
              ListTile(
                title: const Text('About Cheesy Scribe'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => context.push('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mono group label over a bordered card whose rows are divider-separated.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: MonoLabel(label),
      ),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) Divider(height: 1, color: context.scribe.rowDivider),
              child,
            ],
          ],
        ),
      ),
    ],
  );
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: context.text.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: segments,
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    ),
  );
}
