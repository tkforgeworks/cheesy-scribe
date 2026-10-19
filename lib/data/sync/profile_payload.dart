import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// The one `profiles` row per user (CHEESE-60 decision 3b): what follows
/// the account besides the notes. Display name is `accounts.username`;
/// theme and units stay per device.
@immutable
class ProfilePayload {
  const ProfilePayload({this.memberSince, this.recentSearches = const []});

  static const schemaVersion = 1;

  factory ProfilePayload.fromJson(Map<String, dynamic> json) => ProfilePayload(
    memberSince: json['memberSince'] == null
        ? null
        : TastingNote.parseDate(json['memberSince'] as String),
    recentSearches: [
      for (final t in json['recentSearches'] as List<dynamic>? ?? const [])
        t as String,
    ],
  );

  /// The earliest tasting date the user has been a member since; null
  /// until Account was first opened or a note exists.
  final DateTime? memberSince;

  /// Most recent first, at most the repository's cap.
  final List<String> recentSearches;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    if (memberSince != null)
      'memberSince': TastingNote.formatDate(memberSince!),
    'recentSearches': recentSearches,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilePayload &&
          other.memberSince == memberSince &&
          listEquals(other.recentSearches, recentSearches);

  @override
  int get hashCode => Object.hash(memberSince, Object.hashAll(recentSearches));

  @override
  String toString() => 'ProfilePayload($memberSince, $recentSearches)';
}
