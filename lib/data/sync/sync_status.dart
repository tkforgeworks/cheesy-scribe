import 'package:flutter/foundation.dart';

/// Where the sync engine stands, for the status rows (CHEESE-63).
enum SyncPhase {
  /// Nobody is signed in, or this build has no backend.
  signedOut,
  idle,
  syncing,

  /// The last attempt could not reach the server; retried on resume and
  /// with backoff.
  offline,

  /// The last attempt failed for another reason; [SyncStatus.message] says.
  error,

  /// The server says this account is pending deletion or no longer exists
  /// (deleted from another phone or the website). The app signs this
  /// phone out when it sees this (CHEESE-65).
  accountGone,
}

@immutable
class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.lastSyncAt,
    this.message,
    this.pending = 0,
  });

  static const signedOut = SyncStatus(phase: SyncPhase.signedOut);

  final SyncPhase phase;

  /// When the account and this phone last agreed, UTC; null until the first
  /// successful sync on this phone.
  final DateTime? lastSyncAt;

  /// The failure, in the server's or the package's words (logs; the UI
  /// shows its own copy per phase).
  final String? message;

  /// Local changes waiting to be pushed at the time of the last update.
  final int pending;

  SyncStatus copyWith({
    SyncPhase? phase,
    Object? lastSyncAt = _unset,
    Object? message = _unset,
    int? pending,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    lastSyncAt: identical(lastSyncAt, _unset)
        ? this.lastSyncAt
        : lastSyncAt as DateTime?,
    message: identical(message, _unset) ? this.message : message as String?,
    pending: pending ?? this.pending,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatus &&
          other.phase == phase &&
          other.lastSyncAt == lastSyncAt &&
          other.message == message &&
          other.pending == pending;

  @override
  int get hashCode => Object.hash(phase, lastSyncAt, message, pending);

  @override
  String toString() =>
      'SyncStatus(${phase.name}, last $lastSyncAt, pending $pending'
      '${message == null ? '' : ', $message'})';
}

const _unset = Object();
