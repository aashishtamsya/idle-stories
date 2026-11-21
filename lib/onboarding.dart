import 'dart:ui';

import 'package:flutter/material.dart';

import 'names.dart';
import 'strings.dart';
import 'ui.dart';

const regions = ['IN', 'US', 'BR', 'FR', 'OTHER'];

/// Every language as (code, own name, translated yet).
const allLanguages = [
  ('en', 'English', true),
  ('pt', 'Português', true),
  ('fr', 'Français', true),
  ('hi', 'हिन्दी', true),
  ('ta', 'தமிழ்', false),
  ('te', 'తెలుగు', false),
  ('bn', 'বাংলা', false),
  ('mr', 'मराठी', false),
];

/// Languages offered on first launch per region; other regions get English.
const regionLanguages = {
  'IN': ['en', 'hi', 'ta', 'te', 'bn', 'mr'],
  'BR': ['pt', 'en'],
  'FR': ['fr', 'en'],
};

List<(String, String, bool)> languagesFor(String region) => [
  for (final code in regionLanguages[region] ?? const ['en'])
    allLanguages.firstWhere((l) => l.$1 == code),
];

/// First-launch setup: region, then language where the region offers a choice.
/// Both are preset from the phone's locale.
class OnboardingScreen extends StatefulWidget {
  final void Function(String region, String language) onDone;

  /// Choices from an unfinished setup, and where to report new ones.
  final String? draftRegion;
  final String draftLanguage;
  final bool languageStep;
  final void Function(String region, String language, bool languageStep)
  onDraft;
  const OnboardingScreen({
    super.key,
    required this.onDone,
    required this.onDraft,
    this.draftRegion,
    this.draftLanguage = 'en',
    this.languageStep = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late String region;
  late String language;
  late bool pickingLanguage = widget.languageStep;

  @override
  void initState() {
    super.initState();
    final locale = PlatformDispatcher.instance.locale;
    region = regions.contains(locale.countryCode) ? locale.countryCode! : 'OTHER';
    language = _defaultLanguage(locale.languageCode);
    if (widget.draftRegion != null) {
      region = widget.draftRegion!;
      language = widget.draftLanguage;
    }
  }

  /// The phone's language if this region offers it, else the region's first.
  String _defaultLanguage(String wanted) {
    final ready = [for (final l in languagesFor(region)) if (l.$3) l.$1];
    return ready.contains(wanted) ? wanted : ready.first;
  }

  void _pick(VoidCallback change) {
    setState(change);
    widget.onDraft(region, language, pickingLanguage);
  }

  void _continue() {
    if (languagesFor(region).length > 1 && !pickingLanguage) {
      _pick(() => pickingLanguage = true);
    } else {
      widget.onDone(region, language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Image.asset(art('icon_saas'), height: 150),
                Text(
                  tr(language, pickingLanguage ? 'choose_language' : 'choose_region'),
                  textAlign: TextAlign.center,
                  style: gameText(28, weight: 800, color: Colors.white, outline: true),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GamePanel(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if (pickingLanguage)
                          for (final (code, name, ready) in languagesFor(region))
                            ChoiceTile(
                              label: name,
                              note: ready ? null : tr(language, 'coming_soon'),
                              selected: language == code,
                              onTap: ready
                                  ? () => _pick(() => language = code)
                                  : null,
                            )
                        else
                          for (final code in regions)
                            ChoiceTile(
                              label: tr(language, 'region_$code'),
                              selected: region == code,
                              onTap: () => _pick(() {
                                region = code;
                                language = _defaultLanguage(language);
                              }),
                            ),
                        const SizedBox(height: 8),
                        Text(
                          tr(language, 'change_later'),
                          textAlign: TextAlign.center,
                          style: gameText(14, weight: 500, color: inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GameButton(
                  color: 'green',
                  height: 60,
                  onPressed: _continue,
                  child: Text(tr(language, 'continue')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Story id, art (a rendered sprite, or null for an icon), icon, playable.
const stories = [
  ('startup', 'icon_freelance', Icons.laptop_mac, true),
  ('film', null, Icons.movie_creation_outlined, false),
  ('cricket', null, Icons.sports_cricket, false),
];

class StorySelectScreen extends StatelessWidget {
  final String language;
  final String? region;
  final void Function(String story) onDone;
  const StorySelectScreen({
    super.key,
    required this.language,
    required this.region,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Text(
                tr(language, 'choose_story'),
                textAlign: TextAlign.center,
                style: gameText(30, weight: 800, color: Colors.white, outline: true),
              ),
              const SizedBox(height: 4),
              Text(
                tr(language, 'story_locked_note'),
                textAlign: TextAlign.center,
                style: gameText(15, weight: 600, color: navy),
              ),
              const SizedBox(height: 12),
              for (final (id, sprite, icon, playable) in stories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: playable ? 1 : 0.75,
                    child: GamePanel(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: sprite != null
                                ? Image.asset(art(sprite))
                                : Icon(icon, size: 56, color: inkSoft),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr(language, 'story_$id'), style: gameText(22)),
                                Text(
                                  trStory(language, region, 'story_${id}_desc'),
                                  style: gameText(14, weight: 500, color: inkSoft),
                                ),
                                const SizedBox(height: 8),
                                GameButton(
                                  color: 'green',
                                  height: 46,
                                  onPressed: playable ? () => onDone(id) : null,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!playable) ...[
                                        const Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        tr(
                                          language,
                                          playable ? 'start' : 'coming_soon',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for the player's name. The player is the lead of the story they
/// picked (the founder and CEO in the startup story).
class NameScreen extends StatefulWidget {
  final String language;
  final String story;
  final void Function(String name) onDone;
  const NameScreen({
    super.key,
    required this.language,
    required this.story,
    required this.onDone,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final problem = nameProblem(_name.text);
    void done() {
      if (problem == null) widget.onDone(_name.text.trim());
    }

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Text(
                tr(lang, 'name_title'),
                textAlign: TextAlign.center,
                style: gameText(30, weight: 800, color: Colors.white, outline: true),
              ),
              const SizedBox(height: 4),
              Text(
                tr(lang, 'name_role_${widget.story}'),
                textAlign: TextAlign.center,
                style: gameText(15, weight: 600, color: navy),
              ),
              const SizedBox(height: 12),
              GamePanel(
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      autofocus: true,
                      maxLength: 16,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
                      style: gameText(24, weight: 800),
                      decoration: InputDecoration(
                        hintText: tr(lang, 'name_hint'),
                        hintStyle: gameText(24, weight: 600, color: lip),
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => done(),
                    ),
                    if (problem != null && _name.text.trim().isNotEmpty)
                      Text(
                        tr(lang, problem),
                        textAlign: TextAlign.center,
                        style: gameText(
                          14,
                          weight: 600,
                          color: const Color(0xFFD64545),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GameButton(
                color: 'green',
                height: 60,
                onPressed: problem == null ? done : null,
                child: Text(tr(lang, 'continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
