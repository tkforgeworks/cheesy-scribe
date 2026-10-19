import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:heroicons/heroicons.dart';

import '../../data/sync/sync_providers.dart';
import '../../data/sync/sync_status.dart';
import '../notes/note_dates.dart';

/// The backup status line (CHEESE-63), shown in `ForgeAccountSettings`'
/// status slot and in Settings' BACKUP group: what the engine is doing,
/// when it last agreed with the account, and a Sync now action. Copy is
/// per phase and never the server's wording.
class BackupStatusRow extends ConsumerWidget {
  const BackupStatusRow({super.key, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const rowKey = Key('backup-status-row');
  static const syncNowKey = Key('backup-sync-now');

  static const upToDate = 'Up to date';
  static const changesWaiting = 'Changes waiting';
  static const syncing = 'Syncing…';
  static const offline = 'Offline';
  static const failed = "Couldn't sync";

  static const notYet = 'Not backed up yet';
  static const offlineHint =
      'Check your connection. Your changes are safe on this phone and go up '
      'on the next try.';
  static const failedHint =
      'Something went wrong on the server side. Try again in a moment.';
  static const syncingHint = 'Talking to your account.';
  static const syncNowLabel = 'Sync now';

  final DateTime Function() _now;

  static String lastSynced(DateTime at, DateTime now) =>
      'Last synced ${relativeTime(at, now)}';

  static String pendingLine(int n) =>
      '$n ${n == 1 ? 'change' : 'changes'} waiting';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(syncStatusProvider).asData?.value ?? SyncStatus.signedOut;
    final coordinator = ref.watch(syncCoordinatorProvider);
    final x = context.forge;
    final c = context.colors;
    final now = _now().toUtc();

    final (title, hint, icon, color) = switch (status.phase) {
      SyncPhase.syncing => (
        syncing,
        syncingHint,
        HeroIcons.arrowPath,
        c.primary,
      ),
      SyncPhase.offline => (
        offline,
        offlineHint,
        HeroIcons.signalSlash,
        x.textTertiary,
      ),
      SyncPhase.error => (
        failed,
        failedHint,
        HeroIcons.exclamationTriangle,
        c.error,
      ),
      SyncPhase.accountGone => (
        failed,
        'This account is no longer available.',
        HeroIcons.exclamationTriangle,
        c.error,
      ),
      SyncPhase.idle || SyncPhase.signedOut => (
        status.pending > 0 ? changesWaiting : upToDate,
        status.lastSyncAt == null
            ? notYet
            : lastSynced(status.lastSyncAt!, now),
        HeroIcons.cloudArrowUp,
        status.pending > 0 ? x.textTertiary : c.primary,
      ),
    };
    final lines = [
      hint,
      if (status.phase != SyncPhase.idle && status.pending > 0)
        pendingLine(status.pending),
    ];

    return ListTile(
      key: rowKey,
      leading: HeroIcon(icon, color: color),
      title: Text(title),
      subtitle: Text(lines.join(' ')),
      isThreeLine: lines.length > 1,
      trailing: status.phase == SyncPhase.syncing
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.onSurfaceVariant,
              ),
            )
          : TextButton(
              key: syncNowKey,
              onPressed: coordinator?.syncNow,
              child: const Text(syncNowLabel),
            ),
    );
  }
}

/// "just now", "4 minutes ago", "3 hours ago", "yesterday", else the short
/// date. English only, like the rest of the app's dates.
String relativeTime(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) {
    return '${d.inMinutes} ${d.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (d.inHours < 24) {
    return '${d.inHours} ${d.inHours == 1 ? 'hour' : 'hours'} ago';
  }
  if (d.inHours < 48) return 'yesterday';
  return 'on ${formatShortDate(at.toLocal())}';
}
