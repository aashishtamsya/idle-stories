/// Checks the name a player types. A word list cannot catch every rude
/// name, so it covers the common ones in the languages the game ships in.
library;

/// Rude when they appear anywhere in the name.
const _rudeParts = [
  'fuck', 'bitch', 'cunt', 'whore', 'slut', 'porn', 'penis', 'vagina',
  'nigger', 'nigga', 'faggot', 'asshole', 'bastard', 'hitler', //
  'chutiya', 'chutiye', 'madarchod', 'bhenchod', 'behenchod', 'bhosdi',
  'bhosad', 'gandu', 'lavde', 'chodu', //
  'चूतिया', 'चुतिया', 'मादरचोद', 'भेनचोद', 'बहनचोद', 'भोसड़ी', 'गांडू', 'गाँडू', //
  'caralho', 'buceta', 'merda', 'putaria', 'foder', 'fodase', 'arrombado', //
  'putain', 'merde', 'salope', 'connard', 'connasse', 'encule', 'enculé',
];

/// Rude only as a whole word, because real names contain them
/// (Harshit, Shital, Hassan, Dikshit).
const _rudeWords = {
  'ass', 'shit', 'cum', 'sex', 'sexy', 'dick', 'cock', 'tit', 'tits', 'fag',
  'rape', 'nazi', 'anal', 'boob', 'boobs', 'pussy', 'piss', //
  'chut', 'lund', 'gand', 'gaand', 'randi', 'harami', 'kamina', 'kutta', //
  'रंडी', 'लंड', 'चूत', 'गांड', 'गाँड', 'हरामी', 'कमीना', //
  'puta', 'puto', 'porra', 'viado', 'cu', //
  'pute', 'bite', 'nique', 'salaud', 'con',
};

final _allowed = RegExp(r"^[\p{L}\p{M} .'-]+$", unicode: true);
final _breaks = RegExp(r"[ .'-]+");

/// The text as typed, with doubled letters made single ("fuuck"), and with
/// long runs cut to two ("asss").
List<String> _forms(String text) => [
  text,
  text.replaceAllMapped(RegExp(r'(.)\1+'), (m) => m[1]!),
  text.replaceAllMapped(RegExp(r'(.)\1{2,}'), (m) => m[1]! * 2),
];

/// The string key of what is wrong with [raw] as a player name, or null
/// when the name is fine.
String? nameProblem(String raw) {
  final name = raw.trim();
  if (name.runes.length < 2) return 'name_short';
  if (name.runes.length > 16) return 'name_long';
  if (!_allowed.hasMatch(name)) return 'name_chars';
  final words = name.toLowerCase().split(_breaks);
  for (final word in words) {
    if (_forms(word).any(_rudeWords.contains)) return 'name_rude';
  }
  for (final form in _forms(words.join())) {
    if (_rudeParts.any(form.contains)) return 'name_rude';
  }
  return null;
}
