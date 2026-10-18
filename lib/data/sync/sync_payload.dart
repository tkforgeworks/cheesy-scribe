import '../models/models.dart';

/// The shape of a note on the server (CHEESE-60 decisions 1 and 2):
/// `TastingNote.toJson()` as is, plus an integer `schemaVersion` so a
/// later app can migrate older payloads on read. The derived search text
/// is a database column, not part of the JSON, so nothing needs stripping.
/// The server refuses a live row without an integer `schemaVersion`.
const noteSchemaVersion = 1;

Map<String, dynamic> noteToPayload(TastingNote note) => {
  ...note.toJson(),
  'schemaVersion': noteSchemaVersion,
};

/// Reads a payload of any version this app understands. Version 1 is the
/// model's own JSON; add a step here when a field changes meaning, keyed
/// on the stored version, so old rows upgrade lazily as they are pulled.
TastingNote noteFromPayload(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.of(json)..remove('schemaVersion');
  return TastingNote.fromJson(copy);
}
