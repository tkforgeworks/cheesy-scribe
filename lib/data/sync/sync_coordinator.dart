import 'dart:async';

import 'package:flutter/widgets.dart';

import '../repositories/notes_repository.dart';
import 'sync_service.dart';
import 'sync_status.dart';

/// Decides when a [SyncService] runs (CHEESE-62): once when created (app
/// start or sign-in), when the app returns to the foreground, a short
/// [debounce] after a local edit or deletion appears, and again after a
/// failure with exponential backoff ([backoffStart], doubling to
/// [backoffMax]). Never blocks the UI; the service is single-flight.
///
/// One coordinator per signed-in session: `syncCoordinatorProvider`
/// creates it with the session's service and disposes it on sign-out.
class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator({
    required this.service,
    required NotesRepository notes,
    this.debounce = const Duration(seconds: 3),
    this.backoffStart = const Duration(seconds: 30),
    this.backoffMax = const Duration(minutes: 15),
    WidgetsBinding? binding,
  }) : _binding = binding ?? WidgetsBinding.instance {
    _binding.addObserver(this);
    _dirtySub = notes.watchDirty().listen((dirty) {
      if (dirty.isNotEmpty) _scheduleSoon();
    });
    _tombstoneSub = notes.watchTombstoneCount().listen((count) {
      if (count > 0) _scheduleSoon();
    });
    _statusSub = service.changes.listen(_onStatus);
  }

  final SyncService service;
  final Duration debounce;
  final Duration backoffStart;
  final Duration backoffMax;
  final WidgetsBinding _binding;

  late final StreamSubscription<void> _dirtySub;
  late final StreamSubscription<void> _tombstoneSub;
  late final StreamSubscription<SyncStatus> _statusSub;
  Timer? _debounceTimer;
  Timer? _retryTimer;
  Duration _backoff = Duration.zero;
  bool _disposed = false;

  /// Loads the stored status, then runs the first sync.
  Future<void> start() async {
    await service.load();
    unawaited(syncNow());
  }

  /// A sync right now (Sync now button, sign-out flush). Cancels any
  /// pending debounce or retry; the result decides the next retry.
  Future<SyncStatus> syncNow() {
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    return service.sync();
  }

  void _scheduleSoon() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(service.sync()));
  }

  void _onStatus(SyncStatus status) {
    if (_disposed) return;
    switch (status.phase) {
      case SyncPhase.idle:
        _backoff = Duration.zero;
        _retryTimer?.cancel();
      case SyncPhase.offline || SyncPhase.error:
        _backoff = _backoff == Duration.zero
            ? backoffStart
            : Duration(
                microseconds: (_backoff.inMicroseconds * 2).clamp(
                  0,
                  backoffMax.inMicroseconds,
                ),
              );
        _retryTimer?.cancel();
        _retryTimer = Timer(_backoff, () => unawaited(service.sync()));
      case SyncPhase.syncing || SyncPhase.signedOut:
        break;
      case SyncPhase.accountGone:
        // Nothing to retry: the app signs this phone out, which disposes
        // this coordinator.
        _retryTimer?.cancel();
    }
  }

  /// The next retry delay, for tests and the status copy.
  Duration get backoff => _backoff;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(syncNow());
  }

  /// Cancels every subscription at once rather than one after another:
  /// drift finishes a stream cancel on a zero-length timer, and under
  /// flutter_test's fake clock each sequential await would need its own
  /// tick before the database could close.
  Future<void> dispose() async {
    _disposed = true;
    _binding.removeObserver(this);
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    await Future.wait([
      _dirtySub.cancel(),
      _tombstoneSub.cancel(),
      _statusSub.cancel(),
    ]);
    await service.dispose();
  }
}
