# Idle Stories — agent guide

This file is the standing brief for any agent working in this repository. `CLAUDE.md` imports it, so there is one source of truth. The full record of research and decisions is in `docs/project-history.md`; read it before proposing a change of direction.

## What we are building

- A free-to-play mobile **idle simulator** aimed at Indian players, with a worldwide English release.
- The player picks one Indian-themed business **story** permanently on first launch. Other stories come through a bundle. The MVP story is **Tech Startup**; Film and Cricket are placeholders.
- The storyline is told through **anime-influenced comic strips** between chapters.
- First launch asks for the region, then the language where the region offers a choice (India: English and Hindi; Brazil: Portuguese and English; France: French and English).
- The story is tailored to the region. Story lines use `trStory(lang, region, key)`: a `key@REGION` line wins over the plain line, and `{city}` and `{friend}` are filled from the region's world. "Other" plays the India story. Scene props are still India-only.
- The goal is to support every language the App Store and Google Play offer. Each new language needs a native-speaker review before release.
- Monetisation must stay fair: opt-in rewarded ads, cosmetics, a pass and story bundles. There is no pay-to-win and there are no forced ads.
- The visual bar is the top games of the genre. Assets are made in Blender.
- The game must be original. Study other games for principles only; never copy a specific game's name, characters, art or look.

## How we work on art and design (owner's standing process)

The owner wants to steer the look before anything is built. Follow this order every time the look of a screen or an asset set is created or changed:

1. **Research first.** Pull current App Store screenshots of the top games in the genre (the iTunes Search API returns `screenshotUrls`) and compare them with our current screens.
2. **Write the gap analysis.** State plainly where our look falls short and why.
3. **Discuss the art style** with the owner before making any asset.
4. **Show variations in an HTML page** the owner can open, with a recommendation.
5. **Wait for the owner's input.** Do not create assets or change app screens until the owner has chosen a direction.
6. **Write or update the art guideline** (`docs/art-guideline.md`) from the agreed direction, structured the way a modern mobile studio would write one.
7. **Build assets to the guideline**, then show the result on the simulator for review.

Quality notes from the owner so far: plain Material screens "do not look like a game", and the first Blender pass looked "AI sloppy" and "not crisp". Crispness, consistency and a deliberate style matter more than the number of assets.

**Agreed direction (2026-11-21):** low-poly flat 3D, one office seen from above that fills with zones as products launch, with rich detail in every zone. The rules are in `docs/art-guideline.md`.

## Monetisation golden rule

- No ad is ever forced. An ad plays only after the player taps a button that offers a reward for it.
- No purchase offer interrupts play. Offers live in the shop and at moments the player opens themselves (for example a locked story, or the welcome-back screen).
- The first product's manager is cheap in-game cash so every player learns automation early.

## Technical setup

- Flutter 3.29.3 with plain widgets (no Flame yet). Use the `flutter` command; the `dart` on the PATH is a different SDK.
- Run tests with `flutter test --reporter expanded`. The default reporter loses its connection on this machine.
- There are no native plugins, because CocoaPods is not installed. Saving is a JSON file (`lib/save.dart`); on iOS it lives in the app container's `Documents` folder.
- Code layout: `lib/game.dart` (economy and state), `lib/strings.dart` (English and Hindi text through `tr(lang, key)`), `lib/ui.dart` (shared game look), `lib/onboarding.dart`, `lib/comic.dart`, `lib/game_screen.dart`, `lib/main.dart` (screen routing).
- Economy rules: upgrade cost is `baseCost * 1.12^level`, a manager costs `baseCost * 15`, and offline earnings are capped at 8 hours from automated products. Money in India is shown as ₹ with K, L and Cr.
- The font is Anek Devanagari (open licence, Latin and Devanagari), a variable font; always set both weight and width, because its default is thin and condensed. Its sister Anek families cover the other Indian scripts.
- Art is rendered headless with Blender: `blender -b -P tool/render_assets.py -- "$PWD/assets/art"`. Rendered files in `assets/art/` are outputs; change the script, not the images.

## Running and checking the app

- Simulator: `BotsApp-iPhone17`, UDID `8C4FD0AC-4FE9-46C7-BEC5-42967D5140C7`, bundle id `com.example.idleStories`.
- Build with `flutter build ios --simulator --debug`, then use `xcrun simctl install`, `launch` and `io screenshot`.
- An agent cannot tap the simulator. To reach a given state, write a save file into the app container and relaunch.
- The simulator's save file is the owner's own game. Copy it aside before overwriting or deleting it for a test, and put it back when the test is done.
- Say only what was observed. A screen counts as checked when its screenshot has been looked at; animations and taps that were not seen must be reported as not seen.

## Pipeline (owner's directive, 2026-11-21)

- The repository is `github.com/aashishtamsya/idle-stories` (public). GitHub Issues are the work queue and the single source of truth for future work.
- Follow `PLAYBOOK.md`: issue, plan, branch, implement, verify, gate, commit, push, draft PR, review, merge, report. It is the auto-trade project's pipeline cut down for this game.
- Commit, push and opening a draft PR are approved as part of that pipeline once the gate passes (`flutter analyze` and `flutter test --reporter expanded`).
- Merging and marking a PR ready still need the owner's approval each time.
- The repository is public. Never commit secrets, the owner's personal details or machine paths.

## Rules

- Keep diffs small and scoped. Match existing patterns before adding new ones.
- All player-facing text goes through `lib/strings.dart` in both English and Hindi. Hindi still needs a native-speaker review.
- Record decisions that change direction in `docs/project-history.md` when the owner asks for the record to be updated.
