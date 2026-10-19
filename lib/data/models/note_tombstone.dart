import 'package:flutter/foundation.dart';

/// A note deleted on this device that sync has not yet deleted from the
/// account (CHEESE-58). Kept in `note_tombstones` until the push succeeds.
@immutable
class NoteTombstone {
  const NoteTombstone({required this.id, required this.deletedAt});

  final String id;

  /// When the user deleted it, UTC.
  final DateTime deletedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteTombstone && other.id == id && other.deletedAt == deletedAt;

  @override
  int get hashCode => Object.hash(id, deletedAt);

  @override
  String toString() => 'NoteTombstone($id, $deletedAt)';
}
