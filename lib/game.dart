import 'dart:math';

import 'strings.dart';

/// One income source in a story (for the tech startup: gigs, app, SaaS...).
class ProductDef {
  final String id;
  final double baseCost;
  final double baseIncome;
  final double cycleSeconds;
  const ProductDef(this.id, this.baseCost, this.baseIncome, this.cycleSeconds);
}

const startupProducts = [
  ProductDef('freelance', 10, 1, 1),
  ProductDef('app', 100, 12, 3),
  ProductDef('saas', 1200, 150, 6),
  ProductDef('cloud', 15000, 2000, 12),
  ProductDef('ai', 200000, 30000, 24),
];

const maxOfflineSeconds = 8 * 60 * 60;

class ProductState {
  int level;
  bool automated;
  bool running;
  double progress;
  ProductState({
    this.level = 0,
    this.automated = false,
    this.running = false,
    this.progress = 0,
  });
}

class GameState {
  String? region;
  String language = 'en';

  /// Unfinished first-launch setup, kept so quitting midway resumes it.
  String? setupRegion;
  bool setupLanguageStep = false;
  String? story;

  /// The player's name; the player is the lead of the story.
  String? playerName;
  double cash = 0;
  double lifetime = 0;
  int lastSeenMs = 0;
  final Set<String> comicsSeen = {};
  final List<ProductState> items = [
    for (var i = 0; i < startupProducts.length; i++)
      ProductState(level: i == 0 ? 1 : 0),
  ];

  /// Cost of the next level (or of launching, at level 0).
  double upgradeCost(int i) =>
      startupProducts[i].baseCost * pow(1.12, items[i].level);

  /// The first manager is cheap so automation is learnt early.
  double managerCost(int i) =>
      startupProducts[i].baseCost * (i == 0 ? 5 : 15);

  double incomePerCycle(int i) =>
      startupProducts[i].baseIncome * items[i].level;

  /// Income from automated products only; this is what earns while away.
  double get incomePerSecond {
    var total = 0.0;
    for (var i = 0; i < items.length; i++) {
      if (items[i].automated) {
        total += incomePerCycle(i) / startupProducts[i].cycleSeconds;
      }
    }
    return total;
  }

  bool upgrade(int i) {
    final cost = upgradeCost(i);
    if (cash < cost) return false;
    cash -= cost;
    items[i].level++;
    return true;
  }

  bool hireManager(int i) {
    final item = items[i];
    final cost = managerCost(i);
    if (item.automated || item.level == 0 || cash < cost) return false;
    cash -= cost;
    item.automated = true;
    return true;
  }

  /// Starts one manual run of a product.
  void startCycle(int i) {
    final item = items[i];
    if (item.level > 0 && !item.automated) item.running = true;
  }

  void earn(double amount) {
    cash += amount;
    lifetime += amount;
  }

  void tick(double dt) {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.level == 0 || !(item.automated || item.running)) continue;
      item.progress += dt / startupProducts[i].cycleSeconds;
      if (item.progress < 1) continue;
      if (item.automated) {
        final cycles = item.progress.floor();
        earn(incomePerCycle(i) * cycles);
        item.progress -= cycles;
      } else {
        earn(incomePerCycle(i));
        item.progress = 0;
        item.running = false;
      }
    }
  }

  /// Earnings for the time since [lastSeenMs], capped at [maxOfflineSeconds].
  double offlineEarnings(int nowMs) {
    if (lastSeenMs == 0) return 0;
    final seconds = ((nowMs - lastSeenMs) / 1000).clamp(0, maxOfflineSeconds);
    return incomePerSecond * seconds;
  }

  Map<String, dynamic> toJson() => {
    'region': region,
    'language': language,
    'setupRegion': setupRegion,
    'setupLanguageStep': setupLanguageStep,
    'story': story,
    'playerName': playerName,
    'cash': cash,
    'lifetime': lifetime,
    'lastSeenMs': lastSeenMs,
    'comicsSeen': comicsSeen.toList(),
    'items': [
      for (final item in items)
        {'level': item.level, 'automated': item.automated},
    ],
  };

  static GameState fromJson(Map<String, dynamic> json) {
    final state = GameState()
      ..region = json['region'] as String?
      ..language = json['language'] as String? ?? 'en'
      ..setupRegion = json['setupRegion'] as String?
      ..setupLanguageStep = json['setupLanguageStep'] as bool? ?? false
      ..story = json['story'] as String?
      ..playerName = json['playerName'] as String?
      ..cash = (json['cash'] as num?)?.toDouble() ?? 0
      ..lifetime = (json['lifetime'] as num?)?.toDouble() ?? 0
      ..lastSeenMs = json['lastSeenMs'] as int? ?? 0;
    state.comicsSeen.addAll((json['comicsSeen'] as List? ?? []).cast<String>());
    final saved = json['items'] as List? ?? [];
    for (var i = 0; i < saved.length && i < state.items.length; i++) {
      state.items[i]
        ..level = saved[i]['level'] as int
        ..automated = saved[i]['automated'] as bool;
    }
    return state;
  }
}

String currencySymbol(String region) => switch (region) {
  'IN' => '₹',
  'BR' => 'R\$',
  'FR' => '€',
  _ => '\$',
};

/// Formats money for the region: India counts in lakh and crore,
/// everywhere else in millions and billions.
String formatMoney(double value, String region, String lang) {
  final symbol = currencySymbol(region);
  if (value < 1000) {
    final whole = value == value.roundToDouble();
    return '$symbol${value.toStringAsFixed(whole ? 0 : 1)}';
  }
  final units = region == 'IN'
      ? const [(1e12, 'lakh_cr'), (1e7, 'cr'), (1e5, 'lakh'), (1e3, 'k')]
      : const [(1e12, 't'), (1e9, 'b'), (1e6, 'm'), (1e3, 'k')];
  // Hindi unit words are only used with Indian counting.
  final unitLang = region == 'IN' ? lang : 'en';
  for (final (size, key) in units) {
    if (value >= size) {
      return '$symbol${(value / size).toStringAsFixed(2)}'
          '${tr(unitLang, 'unit_$key')}';
    }
  }
  return '$symbol${value.toStringAsFixed(0)}';
}
