import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show ThemeMode;

import 'enums.dart';

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
  });

  /// Shown in the drawer account row and search-bar avatar; null = unset.
  final String? displayName;
  final ThemeMode themeMode;

  /// Default [PriceUnit] for new notes and the PRICE field label (B5).
  final PriceUnit units;

  AppSettings copyWith({
    Object? displayName = _unset,
    ThemeMode? themeMode,
    PriceUnit? units,
  }) => AppSettings(
    displayName: identical(displayName, _unset)
        ? this.displayName
        : displayName as String?,
    themeMode: themeMode ?? this.themeMode,
    units: units ?? this.units,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    displayName: json['displayName'] as String?,
    themeMode: ThemeMode.values.byName(
      json['themeMode'] as String? ?? 'system',
    ),
    units: PriceUnit.values.byName(json['units'] as String? ?? 'usdPerLb'),
  );

  Map<String, dynamic> toJson() => {
    if (displayName != null) 'displayName': displayName,
    'themeMode': themeMode.name,
    'units': units.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.displayName == displayName &&
          other.themeMode == themeMode &&
          other.units == units;

  @override
  int get hashCode => Object.hash(displayName, themeMode, units);
}

const _unset = Object();
