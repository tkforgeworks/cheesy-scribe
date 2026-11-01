import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show ThemeMode;

import 'enums.dart';
import 'tasting_note.dart';

/// Local preferences (`schema/app-settings.schema.json`). Replaces the
/// handoff's `UserProfile` + `AppSettings`: with no account in v0.1.0 the
/// profile collapses to [displayName]; `weeklyReminder` (CHEESE-12) and
/// `cloudBackup` (CHEESE-11) are deferred and not stored.
@immutable
class AppSettings {
  const AppSettings({
    this.displayName,
    this.themeMode = ThemeMode.system,
    this.units = PriceUnit.usdPerLb,
    this.memberSince,
    this.tourVersion = 0,
  });

  /// Shown in the drawer account row and search-bar avatar; null = unset.
  final String? displayName;
  final ThemeMode themeMode;

  /// Default [PriceUnit] for new notes and the PRICE field label (B5).
  final PriceUnit units;

  /// First day the app was opened (local date); the Account screen's
  /// "MEMBER SINCE" falls back to it when there are no notes yet.
  final DateTime? memberSince;

  /// The first-use tour this phone has finished or skipped (CHEESE-49);
  /// 0 = never. Local to the phone, never synced. The tour shows on launch
  /// while this is below `TourScreen.version`.
  final int tourVersion;

  AppSettings copyWith({
    Object? displayName = _unset,
    ThemeMode? themeMode,
    PriceUnit? units,
    Object? memberSince = _unset,
    int? tourVersion,
  }) => AppSettings(
    displayName: identical(displayName, _unset)
        ? this.displayName
        : displayName as String?,
    themeMode: themeMode ?? this.themeMode,
    units: units ?? this.units,
    memberSince: identical(memberSince, _unset)
        ? this.memberSince
        : memberSince as DateTime?,
    tourVersion: tourVersion ?? this.tourVersion,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    displayName: json['displayName'] as String?,
    themeMode: ThemeMode.values.byName(
      json['themeMode'] as String? ?? 'system',
    ),
    units: PriceUnit.values.byName(json['units'] as String? ?? 'usdPerLb'),
    memberSince: json['memberSince'] == null
        ? null
        : TastingNote.parseDate(json['memberSince'] as String),
    // Settings rows store text, so accept "2" as well as 2.
    tourVersion: switch (json['tourVersion']) {
      final int v => v,
      final String v => int.tryParse(v) ?? 0,
      _ => 0,
    },
  );

  Map<String, dynamic> toJson() => {
    if (displayName != null) 'displayName': displayName,
    'themeMode': themeMode.name,
    'units': units.name,
    if (memberSince != null)
      'memberSince': TastingNote.formatDate(memberSince!),
    if (tourVersion > 0) 'tourVersion': tourVersion,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.displayName == displayName &&
          other.themeMode == themeMode &&
          other.units == units &&
          other.memberSince == memberSince &&
          other.tourVersion == tourVersion;

  @override
  int get hashCode =>
      Object.hash(displayName, themeMode, units, memberSince, tourVersion);
}

const _unset = Object();
