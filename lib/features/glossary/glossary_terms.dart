/// The glossary's copy (CHEESE-45). Tim owns the prose; edit in place.
/// Every switch is exhaustive, so a new term does not compile without its
/// definition.
library;

import '../../data/models/models.dart';

/// The glossary's sections in page order. `name` is the `?section=` value
/// the note form's help buttons open it at.
enum GlossarySection { flavor, texture, rind, milk }

extension GlossarySectionCopy on GlossarySection {
  String get title => switch (this) {
    GlossarySection.flavor => 'Flavor wheel',
    GlossarySection.texture => 'Texture',
    GlossarySection.rind => 'Rind',
    GlossarySection.milk => 'Milk',
  };

  String get intro => switch (this) {
    GlossarySection.flavor =>
      'Score each spoke 0 to 5 for how loudly it shows up: 0 is not there, '
          '1 a hint you would miss if you weren\'t looking, 3 a clear part '
          'of the cheese, 5 what the cheese is about. Scores of 3 and up '
          'count as a real note, in search and in your stats. The wheel '
          'covers smell and texture as well as taste, so STINKY is mostly '
          'your nose and CRUMBLY and CRYSTALLINE are about the paste.',
    GlossarySection.texture =>
      'Where the paste sits, from runny to hard. Most cheeses firm up as '
          'they age and dry out, so the same cheese can move along the '
          'meter.',
    GlossarySection.rind =>
      'The outside of the cheese, and how it got that way. It does a lot '
          'of the flavor work, whether or not you eat it.',
    GlossarySection.milk =>
      'The two milk attributes the form asks about. Both are worth '
          'knowing; neither is a guarantee.',
  };
}

/// The page's opening line.
const glossaryIntro =
    'What the words on the note form mean, so you can score a cheese '
    'without guessing. Nobody checks your answers.';

extension FlavorNoteDefinition on FlavorNote {
  String get definition => switch (this) {
    FlavorNote.salty =>
      'The plain seasoning hit on the tongue. Gentle in fresh cheeses, '
          'climbing as they age and dry out, and the headline act in feta '
          'and Pecorino Romano.',
    FlavorNote.sweet =>
      'A rounded, milky sweetness rather than sugar: fresh mozzarella, or '
          'the cooked-milk sweetness of an aged Gouda. It often hides behind '
          'the salt until you go looking.',
    FlavorNote.sharpTangy =>
      'The bite at the sides of the tongue that makes your mouth water. '
          'An aged cheddar\'s snap, a young goat cheese\'s tang: acidity '
          'doing its job.',
    FlavorNote.lemon =>
      'A bright, fruity sourness that reads as lemon or orange peel. '
          'Common in young goat cheeses and just under bloomy rinds; '
          'fresher and lighter than plain tang.',
    FlavorNote.grassy =>
      'The farm itself: fresh hay, pasture, a whiff of the barn. Loudest '
          'in raw-milk and grassfed cheeses, and in plenty of goat and sheep '
          'ones.',
    FlavorNote.herbal =>
      'Grassy\'s more delicate cousin: wildflowers, dried herbs, a meadow '
          'in bloom, with the barnyard still somewhere in the background. '
          'Summer-milk Alpine cheeses are full of it.',
    FlavorNote.caramel =>
      'Butterscotch, brown butter, toffee: the deep cooked sweetness of a '
          'long-aged Gouda or a Norwegian brown cheese. It tends to turn up '
          'with the crystals.',
    FlavorNote.nutty =>
      'Hazelnut, almond, toasted walnut. The signature of Alpine wheels '
          'like Comté and Gruyère, and it deepens the longer they age.',
    FlavorNote.earthy =>
      'Mushrooms, cellar floor, damp forest. It comes from rinds and caves, '
          'so look for it just under the rind of tommes and bloomy cheeses.',
    FlavorNote.moldyBlue =>
      'The spicy, peppery, faintly metallic tang of blue veining. Low is a '
          'gentle hum, like Gorgonzola Dolce; high is a takeover, like '
          'Roquefort.',
    FlavorNote.stinky =>
      'Pungent, if you are being polite: the smell of a washed rind, '
          'somewhere between old socks and smoked meat. Score how loud it '
          'is, not whether you liked it; plenty stink at the door and taste '
          'mild once inside.',
    FlavorNote.robust =>
      'Savory with richness and depth: a deep, brothy flavor that fills the '
          'mouth and hangs around, like a long-aged Parmigiano. Score it for '
          'depth, not volume.',
    FlavorNote.butteryCreamy =>
      'Rich, fatty and smooth, like good butter or cream. Triple creams '
          'live here, and so do young Goudas and Havarti.',
    FlavorNote.milkyLactic =>
      'Fresh milk, yogurt, crème fraîche: the clean, lightly sour taste of '
          'the milk itself. Loudest in fresh and young cheeses, fading as '
          'they age.',
    FlavorNote.crumbly =>
      'A texture, not a flavor: the paste breaks into crumbs instead of '
          'slicing clean. Feta, Cheshire, Cotija, a well-aged cheddar.',
    FlavorNote.crystalline =>
      'A texture, not a flavor: the crunchy little crystals in long-aged '
          'cheeses like Parmigiano, old Gouda and Comté. They are amino '
          'acids or calcium lactate, not salt, and a very good sign.',
  };
}

extension TextureLevelDefinition on TextureLevel {
  String get definition => switch (this) {
    TextureLevel.runny =>
      'Flows or oozes at room temperature, so you scoop rather than cut. '
          'Ripe Époisses, Vacherin Mont d\'Or, a Brie at its peak.',
    TextureLevel.soft =>
      'Spreadable and yielding; it holds its shape until you press it. '
          'Fresh chèvre, young Camembert, triple creams.',
    TextureLevel.semiSoft =>
      'Sliceable but supple: it bends before it breaks. Havarti, Port '
          'Salut, Taleggio.',
    TextureLevel.semiFirm =>
      'Holds a clean edge and springs back a little when pressed. Young '
          'cheddar, Gouda, Tomme de Savoie.',
    TextureLevel.firm =>
      'Dense and solid, slicing cleanly with a little effort. Comté, aged '
          'cheddar, Manchego curado.',
    TextureLevel.hard =>
      'Dry and dense enough to grate; it breaks into shards rather than '
          'slices. Parmigiano Reggiano, Pecorino Romano, very old Gouda.',
  };
}

extension RindTypeDefinition on RindType {
  String get definition => switch (this) {
    RindType.natural =>
      'Formed by the cheese itself as the outside dries during aging, often '
          'brushed, oiled or bound in cloth along the way (clothbound counts '
          'here). Tomme de Savoie, clothbound cheddar, Parmigiano.',
    RindType.bloomy =>
      'A soft, white, velvety coat of mold that ripens the cheese from the '
          'outside in. Brie, Camembert, and the ash-dusted goat cheeses, '
          'which count here too.',
    RindType.washed =>
      'Rubbed with brine, beer, wine or spirits as it ages, which grows a '
          'sticky orange rind and the famous smell. Époisses, Taleggio, '
          'Limburger. If it\'s STINKY, start here.',
    RindType.waxed =>
      'Sealed in wax to keep moisture in and mold out. Not for eating: peel '
          'it off. Gouda, Edam, plenty of cheddars.',
    RindType.leafWrapped =>
      'Wrapped in chestnut, grape or fig leaves, often soaked in spirits '
          'first, which flavor the outside of the paste. Banon, Rogue River '
          'Blue.',
    RindType.rindless =>
      'No rind at all, because it is eaten fresh or aged in plastic or '
          'brine. Ricotta, mozzarella, feta, block cheddar.',
    RindType.other =>
      'Anything the list doesn\'t cover: smoked, rubbed with spices or '
          'coffee, bound in bark. Pick Other and describe it in the field '
          'that appears.',
  };
}

/// The note form's Raw and Grassfed chips.
const rawDefinition =
    'Made from milk that hasn\'t been pasteurized, so more of the milk\'s '
    'own character, and the farm\'s, survives into the cheese. In the US, '
    'raw-milk cheese must be aged at least 60 days before it can be sold.';

const grassfedDefinition =
    'From animals that graze on pasture rather than eating mostly grain. '
    'Grassfed milk tends to give a yellower paste and more GRASSY and HERBAL '
    'notes, especially from summer milk.';
