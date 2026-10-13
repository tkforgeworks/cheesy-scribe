import 'package:flutter/widgets.dart';

/// Bottom padding for scroll views that sit above the system navigation bar.
extension NavBarInset on EdgeInsets {
  /// This padding plus the system navigation bar's height at the bottom.
  ///
  /// Android draws the app edge-to-edge (targetSdk 35+), and a scroll view
  /// given an explicit `padding` no longer adds the MediaQuery inset itself,
  /// so without this the last item scrolls to rest under the 3-button bar
  /// (CHEESE-44). `paddingOf` is already 0 while the keyboard is up.
  EdgeInsets withNavBarInset(BuildContext context) =>
      copyWith(bottom: bottom + MediaQuery.paddingOf(context).bottom);
}
