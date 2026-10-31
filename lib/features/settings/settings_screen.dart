import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/shell/shell_providers.dart';
import '../../data/forge_providers.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../account/account_screen.dart';
import '../account/backup_status_row.dart';
import 'share_app.dart';

/// `/settings` (DESIGN_SPEC §6, CHEESE-31): mono-labelled groups of
/// bordered cards. Theme and units persist through [AppSettings]; the
/// deferred reminder row (CHEESE-12) sits disabled at 45 %.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const disabledOpacity = 0.45;

  /// BACKUP group copy (CHEESE-63).
  static const signInRowKey = Key('settings-backup-sign-in');
  static const accountRowKey = Key('settings-backup-account');
  static const signInTitle = 'Sign in to back up your notes';
  static const signInSubtitle =
      'Optional. Your notes stay on this phone either way.';

  /// Share row (CHEESE-71).
  static const shareRowKey = Key('settings-share-app');
  static const shareTitle = 'Share Cheesy Scribe';
  static const shareSubtitle = 'Send a friend the link.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).asData?.value ?? const AppSettings();
    final version = ref.watch(appVersionProvider).asData?.value;
    final c = context.colors;
    final x = context.forge;
    final repo = ref.read(settingsRepositoryProvider);
    final backup = ref.watch(backupAvailableProvider);
    final session = ref.watch(sessionProvider);
    final chevron = HeroIcon(
      HeroIcons.chevronRight,
      size: 18,
      color: x.textTertiary,
    );

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
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ).withNavBarInset(context),
        children: [
          ForgeSettingsGroup(
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
          // CHEESE-63: where backup stands, or how to turn it on.
          ForgeSettingsGroup(
            label: 'Backup',
            children: [
              if (!backup)
                Opacity(
                  opacity: disabledOpacity,
                  child: const ListTile(
                    enabled: false,
                    title: Text(AccountScreen.backupUnavailable),
                  ),
                )
              else if (session == null)
                ListTile(
                  key: signInRowKey,
                  leading: HeroIcon(
                    HeroIcons.cloudArrowUp,
                    color: x.textTertiary,
                  ),
                  title: const Text(signInTitle),
                  subtitle: const Text(signInSubtitle),
                  trailing: chevron,
                  onTap: () => context.go('/account'),
                )
              else ...[
                const BackupStatusRow(),
                ListTile(
                  key: accountRowKey,
                  leading: HeroIcon(
                    HeroIcons.userCircle,
                    color: x.textTertiary,
                  ),
                  title: Text(session.email ?? 'Account'),
                  subtitle: const Text('Signed in'),
                  trailing: chevron,
                  onTap: () => context.go('/account'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          ForgeSettingsGroup(
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
          ForgeSettingsGroup(
            label: 'About',
            children: [
              ListTile(
                key: shareRowKey,
                leading: HeroIcon(HeroIcons.share, color: x.textTertiary),
                title: const Text(shareTitle),
                subtitle: const Text(shareSubtitle),
                trailing: chevron,
                onTap: () => ref.read(shareAppProvider)(
                  shareAppMessage,
                  subject: 'Cheesy Scribe',
                ),
              ),
              ListTile(
                title: const Text('Version'),
                trailing: ForgeMonoLabel(
                  version ?? '—',
                  color: c.onSurfaceVariant,
                ),
              ),
              ListTile(
                title: const Text('Open-source licenses'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => context.push('/licenses'),
              ),
              ListTile(
                title: const Text('About Cheesy Scribe'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => context.go('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
