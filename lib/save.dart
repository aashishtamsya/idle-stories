import 'dart:convert';
import 'dart:io';

import 'game.dart';

// The MVP saves to a plain file so it needs no native plugins (CocoaPods is
// not installed on the build machine). On Android this falls back to the
// app's cache directory, which the system may clear; switch to
// shared_preferences or path_provider before any Android release.
File _saveFile() {
  // On iOS the temp directory is <app container>/tmp, so its sibling
  // Documents folder is the app's permanent storage. (HOME is not set.)
  final dir = Platform.isIOS
      ? Directory('${Directory.systemTemp.parent.path}/Documents')
      : Directory.systemTemp;
  return File('${dir.path}/idle_stories_save.json');
}

Future<GameState> loadGame() async {
  try {
    final file = _saveFile();
    if (!await file.exists()) return GameState();
    return GameState.fromJson(jsonDecode(await file.readAsString()));
  } catch (_) {
    // A corrupt or unreadable save starts a fresh game.
    return GameState();
  }
}

Future<void> saveGame(GameState state) async {
  final file = _saveFile();
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(state.toJson()));
}

Future<void> deleteSave() async {
  final file = _saveFile();
  if (await file.exists()) await file.delete();
}
