import 'package:flutter_test/flutter_test.dart';
import 'package:idle_stories/strings.dart';
import 'package:idle_stories/game.dart';
import 'package:idle_stories/game_screen.dart';
import 'dart:ui';

void main() {
  group('economy', () {
    test('upgrade deducts the cost and raises the level', () {
      final s = GameState()..cash = 100;
      final cost = s.upgradeCost(0);
      expect(s.upgrade(0), isTrue);
      expect(s.items[0].level, 2);
      expect(s.cash, closeTo(100 - cost, 1e-9));
    });

    test('upgrade fails without enough cash', () {
      final s = GameState();
      expect(s.upgrade(0), isFalse);
      expect(s.items[0].level, 1);
    });

    test('a manual run pays once and then stops', () {
      final s = GameState()..startCycle(0);
      s.tick(1);
      expect(s.cash, 1);
      s.tick(5);
      expect(s.cash, 1);
    });

    test('an automated product pays for every completed run', () {
      final s = GameState()..cash = 50;
      expect(s.managerCost(1), 1500);
      expect(s.hireManager(0), isTrue);
      expect(s.cash, 0);
      s.tick(3.5);
      expect(s.cash, 3);
      expect(s.items[0].progress, closeTo(0.5, 1e-9));
    });

    test('a manager cannot be hired for a product that is not launched', () {
      final s = GameState()..cash = 1e9;
      expect(s.hireManager(1), isFalse);
    });

    test('offline earnings need automation and are capped at 8 hours', () {
      final s = GameState()..lastSeenMs = 1;
      const dayMs = 24 * 60 * 60 * 1000;
      expect(s.offlineEarnings(dayMs), 0);
      s
        ..cash = 150
        ..hireManager(0);
      expect(s.offlineEarnings(dayMs), maxOfflineSeconds * 1.0);
      expect(s.offlineEarnings(1 + 10 * 1000), 10);
    });

    test('a fresh game has no offline earnings', () {
      expect(GameState().offlineEarnings(999999999), 0);
    });
  });

  test('save data round-trips', () {
    final s = GameState()
      ..region = 'IN'
      ..language = 'hi'
      ..setupRegion = 'IN'
      ..setupLanguageStep = true
      ..story = 'startup'
      ..cash = 500
      ..lastSeenMs = 42;
    s.comicsSeen.add('intro');
    s.upgrade(1);
    s.hireManager(0);
    final loaded = GameState.fromJson(s.toJson());
    expect(loaded.toJson(), s.toJson());
  });

  test('story text is tailored to the region', () {
    expect(trStory('en', 'IN', 'intro_1'), startsWith('Bengaluru.'));
    expect(trStory('en', 'US', 'intro_1'), startsWith('Austin.'));
    expect(trStory('en', 'US', 'intro_3'), contains('food truck'));
    expect(trStory('pt', 'BR', 'intro_2'), contains('Rafael'));
    expect(trStory('hi', 'IN', 'intro_2'), contains('कबीर'));
    expect(trStory('en', null, 'ch2_2'), startsWith('Kabir'));
    for (final lang in ['en', 'hi', 'pt', 'fr']) {
      for (final region in ['IN', 'US', 'BR', 'FR', 'OTHER']) {
        for (final key in ['intro_1', 'intro_2', 'ch2_2', 'story_startup_desc']) {
          expect(trStory(lang, region, key), isNot(contains('{')));
        }
      }
    }
  });

  test('a tap in the office finds the nearest zone', () {
    const size = Size(400, 300);
    for (final id in zoneOrder) {
      final spot = zoneSpot[id]!;
      expect(zoneAt(Offset(spot.dx * 400, spot.dy * 300), size), id);
    }
    expect(zoneAt(const Offset(2, 298), size), isNull);
  });

  group('money formatting', () {
    test('India counts in lakh and crore', () {
      expect(formatMoney(950, 'IN', 'en'), '₹950');
      expect(formatMoney(12.5, 'IN', 'en'), '₹12.5');
      expect(formatMoney(150000, 'IN', 'en'), '₹1.50 L');
      expect(formatMoney(25000000, 'IN', 'en'), '₹2.50 Cr');
      expect(formatMoney(150000, 'IN', 'hi'), '₹1.50 लाख');
    });

    test('other regions count in millions and billions', () {
      expect(formatMoney(1500, 'US', 'en'), '\$1.50K');
      expect(formatMoney(2500000, 'US', 'en'), '\$2.50M');
      expect(formatMoney(2500000, 'FR', 'en'), '€2.50M');
      expect(formatMoney(2500000, 'US', 'hi'), '\$2.50M');
    });
  });
}
