import 'package:flutter/material.dart';

import 'comic.dart';
import 'game.dart';
import 'game_screen.dart';
import 'onboarding.dart';
import 'save.dart';
import 'strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IdleStoriesApp(state: await loadGame()));
}

class IdleStoriesApp extends StatefulWidget {
  final GameState state;
  const IdleStoriesApp({super.key, required this.state});

  @override
  State<IdleStoriesApp> createState() => _IdleStoriesAppState();
}

class _IdleStoriesAppState extends State<IdleStoriesApp> {
  late GameState state = widget.state;

  void _update(VoidCallback change) {
    setState(change);
    saveGame(state);
  }

  /// First launch walks through setup, story choice and the opening comic;
  /// every later launch goes straight to the game.
  Widget _home() {
    if (state.region == null) {
      return OnboardingScreen(
        draftRegion: state.setupRegion,
        draftLanguage: state.language,
        languageStep: state.setupLanguageStep,
        onDraft: (region, language, languageStep) => _update(() {
          state.setupRegion = region;
          state.language = language;
          state.setupLanguageStep = languageStep;
        }),
        onDone: (region, language) => _update(() {
          state.region = region;
          state.language = language;
        }),
      );
    }
    if (state.story == null) {
      return StorySelectScreen(
        language: state.language,
        region: state.region,
        onDone: (story) => _update(() => state.story = story),
      );
    }
    if (!state.comicsSeen.contains('intro')) {
      return ComicScreen(
        comicId: 'intro',
        language: state.language,
        region: state.region,
        player: state.playerName,
        onDone: () => _update(() => state.comicsSeen.add('intro')),
      );
    }
    return GameScreen(
      state: state,
      onReset: () async {
        await deleteSave();
        setState(() => state = GameState());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tr(state.language, 'app_title'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Anek',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB300)),
      ),
      home: _home(),
    );
  }
}
