// The first-use tour's slides (CHEESE-49). The copy is Tim's, agreed on
// the design page linked from the ticket; edit it in place. Each frame is
// a picture of the real app rendered by tool/visual/render_tour_test.dart
// (`assets/tour/<light|dark>-<frame>.webp`), and its highlights come from
// tour_highlights.dart, which the same harness writes.

/// The tour's four parts, in order.
enum TourChapter {
  firstNote('Your first note'),
  around('Find your way around'),
  backup('Backup, if you want it'),
  tellUs('Tell us');

  const TourChapter(this.label);

  final String label;
}

class TourSlide {
  const TourSlide({
    required this.chapter,
    required this.frames,
    required this.title,
    required this.body,
  });

  final TourChapter chapter;

  /// One frame, or two shown side by side.
  final List<String> frames;
  final String title;
  final String body;
}

const tourSlides = <TourSlide>[
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['empty'],
    title: 'Every tasting starts here',
    body:
        'Your journal is empty until you say otherwise. Tap New tasting note '
        'at the bottom of the screen to write your first one.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['details'],
    title: 'Start with the label',
    body:
        'Name, creamery, where it comes from and the day you tasted it, then '
        'the rind, the price, a style from the library and the one sentence '
        "you'd say out loud. Only the name is required.",
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['milk-rating'],
    title: "The milk, and stars you'd argue with a stranger about",
    body:
        'Cow, goat, sheep, buffalo or something else. Tick how the cow was '
        "fed, based on the label. If it's not on the label, I won't judge you "
        "for selecting Other. Then give it the stars you'd argue with a "
        'stranger about, or leave them blank while you make up your mind.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['tasting'],
    title: 'Now taste it properly',
    body:
        'Slide the texture meter from runny to hard. Tap a spoke on the wheel '
        'to score that flavor from 0 to 5.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['flavors-wheel', 'flavors-list'],
    title: 'Wheel or list, your call',
    body:
        'Both score the same sixteen flavors. Switch to List to go one by '
        'one; whatever you score shows up on the wheel, and back again.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['terms'],
    title: 'Lost in the tasting sauce?',
    body:
        'Too many terms getting you lost in the tasting sauce? Check any '
        'questionable word against our questionable definitions in Tasting '
        'terms. The ? next to a field opens the right page.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['saved'],
    title: 'Save it and it becomes a page',
    body:
        'Your note opens as a page: stars, verdict, milk and texture, your '
        'notes and the wheel you drew. The pencil at the top edits it.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['journal'],
    title: 'Your journal fills up',
    body:
        'The newest tasting sits on top. The chips filter by rating or by the '
        'styles you taste most.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['hold'],
    title: 'Press and hold to change your mind',
    body: 'Long-press any tasting to edit or delete it. Deleting asks first.',
  ),
  TourSlide(
    chapter: TourChapter.firstNote,
    frames: ['search'],
    title: 'Find that one cheese',
    body: 'Search by name, creamery, origin, notes or flavor.',
  ),
  TourSlide(
    chapter: TourChapter.around,
    frames: ['drawer'],
    title: 'Everything else is in the drawer',
    body:
        'Tap the menu at the top left to reach the library, tasting terms, '
        'stats, your account, settings and About. On those screens, Back '
        'opens the drawer too.',
  ),
  TourSlide(
    chapter: TourChapter.around,
    frames: ['library'],
    title: 'The cheese library',
    body:
        '27 styles to taste against. Each card counts the ones you have '
        'tasted; tap a style to see those tastings together.',
  ),
  TourSlide(
    chapter: TourChapter.around,
    frames: ['style'],
    title: 'Past tastings, by style',
    body:
        "A style's page describes it, shows its usual milk and texture, and "
        'lists every note you have filed under it.',
  ),
  TourSlide(
    chapter: TourChapter.around,
    frames: ['untasted'],
    title: 'Not met yet',
    body:
        'Styles you have not tried say so, with a button that starts a note '
        'already set to that style.',
  ),
  TourSlide(
    chapter: TourChapter.around,
    frames: ['settings'],
    title: 'Settings',
    body:
        'Light or dark, dollars or euros, and Take the tour again whenever '
        'you want this back.',
  ),
  TourSlide(
    chapter: TourChapter.backup,
    frames: ['optional'],
    title: 'An account is optional',
    body:
        'Your notes live on this phone and never have to leave it. Sign in '
        'with Google or an email address only if you want a copy in the '
        'cloud, ready for your next phone.',
  ),
  TourSlide(
    chapter: TourChapter.backup,
    frames: ['delete'],
    title: 'Delete it any time',
    body:
        'Account, then Delete account, removes the account and its notes from '
        'our servers within minutes. You can do the same from our website '
        'without the app.',
  ),
  TourSlide(
    chapter: TourChapter.tellUs,
    frames: ['button'],
    title: 'The button on every screen',
    body:
        'See the speech bubble? It sits on almost every screen. Tap it '
        'whenever something is on your mind.',
  ),
  TourSlide(
    chapter: TourChapter.tellUs,
    frames: ['feedback'],
    title: 'Bugs, ideas, anything',
    body:
        'Pick a topic: a bug, an idea, something confusing, or just hi. It '
        'goes straight to the people who make Cheesy Scribe, along with the '
        'screen you were on.',
  ),
];
