import 'package:flutter_test/flutter_test.dart';
import 'package:idle_stories/strings.dart';
import 'package:idle_stories/game.dart';
import 'package:idle_stories/game_screen.dart';
import 'package:idle_stories/names.dart';
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
      final s = GameState()..cash = 90;
      expect(s.managerCost(1), 1500);
      expect(s.hireManager(0), isFalse, reason: 'no HR desk yet');
      expect(s.setUpHr(), isTrue);
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
        ..setUpHr()
        ..hireManager(0);
      expect(s.offlineEarnings(dayMs), maxOfflineSeconds * 1.0);
      expect(s.offlineEarnings(1 + 10 * 1000), 10);
    });

    test('staff speed up a product until the desks run out', () {
      final s = GameState()..cash = 1e9;
      expect(s.staffCost(0), 40);
      expect(s.hireStaff(0), isTrue);
      expect(s.staffCost(0), 80);
      expect(s.cycleSeconds(0), closeTo(0.8, 1e-9));
      expect(s.hireStaff(0), isTrue);
      expect(s.hireStaff(0), isFalse, reason: 'three people without HR');
      s.setUpHr();
      expect(s.hireStaff(0), isTrue);
      expect(s.headcount, s.desks);
      expect(s.hireStaff(0), isFalse, reason: 'the office is full');
      expect(s.expandOffice(), isTrue);
      expect(s.desks, 8);
      expect(s.hireStaff(0), isTrue);
    });

    test('a funding round restarts the products and triples income', () {
      final s = GameState()..cash = 1e9;
      s
        ..setUpHr()
        ..expandOffice()
        ..upgrade(1)
        ..hireStaff(0)
        ..hireManager(0);
      expect(s.raiseRound(), isFalse, reason: 'goal not reached');
      s.earn(s.roundGoal);
      expect(s.raiseRound(), isTrue);
      expect(s.round, 1);
      expect(s.cash, 0);
      expect(s.items[1].level, 0);
      expect(s.items[0].automated, isFalse);
      expect(s.headcount, 1);
      expect(s.hr, isTrue);
      expect(s.office, 1);
      expect(s.incomePerCycle(0), 3);
      expect(s.roundGoal, 25000000);
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
      ..playerName = 'Asha'
      ..cash = 500
      ..lastSeenMs = 42;
    s.comicsSeen.add('intro');
    s.upgrade(1);
    s.setUpHr();
    s.hireStaff(1);
    s.hireManager(0);
    s.expandOffice();
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
    expect(trStory('en', 'IN', 'round1_1', player: 'Asha'), contains('Asha'));
    for (final lang in ['en', 'hi', 'pt', 'fr']) {
      for (final region in ['IN', 'US', 'BR', 'FR', 'OTHER']) {
        for (final key in ['intro_1', 'intro_2', 'ch2_2', 'round2_2', 'contract_body',
            'story_startup_desc']) {
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

  test('player names are checked', () {
    for (final ok in ['Asha', 'Harshit', 'Shital', 'Hassan', 'Dikshit', 'Nigam',
        'आशा', 'José', "D'Souza", 'Anne-Marie']) {
      expect(nameProblem(ok), isNull, reason: ok);
    }
    expect(nameProblem(' a '), 'name_short');
    expect(nameProblem('a' * 17), 'name_long');
    expect(nameProblem('Asha99'), 'name_chars');
    expect(nameProblem('Asha!'), 'name_chars');
    for (final rude in ['Fuck', 'f u c k', 'Fuuuck', 'shit', 'Asss',
        'Chutiya', 'चूतिया', 'Big Dick', 'Putain']) {
      expect(nameProblem(rude), 'name_rude', reason: rude);
    }
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
