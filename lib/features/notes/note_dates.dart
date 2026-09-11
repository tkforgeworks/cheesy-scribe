/// Date text for notes, English only (the app is English only; no `intl`).
/// "Aug 12, 2026" — mono contexts uppercase it themselves.
String formatTastingDate(DateTime d) =>
    '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "Aug 3" — row subtitles and the featured card's meta line.
String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
