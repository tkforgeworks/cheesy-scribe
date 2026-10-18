import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/sync_check.dart';

void main() {
  // CHEESE-60: supabase/ holds copies of the pinned forge_core's
  // migrations, functions and templates (dart run forge_core:sync_supabase
  // writes them and supabase/forge_core.lock). This fails when the pin
  // moves without re-running the sync, or when a copy is edited by hand.
  test('supabase files match the pinned forge_core', () async {
    expect(await forgeSupabaseDrift(), isEmpty);
  });
}
