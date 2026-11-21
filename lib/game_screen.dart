import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'comic.dart';
import 'game.dart';
import 'onboarding.dart';
import 'save.dart';
import 'strings.dart';
import 'ui.dart';

const _greyscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 0.55, 0,
]);

/// Minimum time away before the "welcome back" earnings dialog is shown.
const _minAwayMs = 60 * 1000;

/// Office layers from back to front, and where each zone sits in the
/// picture (fractions printed by tool/render_assets.py).
const zoneOrder = ['cloud', 'saas', 'ai', 'app', 'freelance'];
const zoneSpot = {
  'cloud': Offset(0.564, 0.229),
  'saas': Offset(0.354, 0.261),
  'ai': Offset(0.754, 0.398),
  'app': Offset(0.476, 0.488),
  'freelance': Offset(0.208, 0.476),
};

/// The zone nearest to a tap at [p] in an office drawn at [size], or null
/// when the tap is not close to any zone.
String? zoneAt(Offset p, Size size) {
  String? best;
  var bestDistance = size.width * 0.16;
  for (final id in zoneOrder) {
    final spot = zoneSpot[id]!;
    final d = (p - Offset(spot.dx * size.width, spot.dy * size.height)).distance;
    if (d < bestDistance) {
      bestDistance = d;
      best = id;
    }
  }
  return best;
}

class GameScreen extends StatefulWidget {
  final GameState state;
  final VoidCallback onReset;
  const GameScreen({super.key, required this.state, required this.onReset});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final Timer _ticker;
  int _ticksSinceSave = 0;
  bool _showingComic = false;

  /// Number of payouts seen per product; a change replays the pop animation.
  final _pops = List.filled(startupProducts.length, 0);
  final _lastPay = List.filled(startupProducts.length, 0.0);

  /// The product whose card is open.
  int _selected = 0;

  GameState get s => widget.state;
  String get lang => s.language;
  String money(double v) => formatMoney(v, s.region!, lang);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(milliseconds: 100), _onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _welcomeBack());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) _save();
    if (lifecycle == AppLifecycleState.resumed) _welcomeBack();
  }

  void _save() {
    s.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
    saveGame(s);
  }

  void _onTick(Timer _) {
    final before = [for (final it in s.items) (it.running, it.progress)];
    setState(() {
      s.tick(0.1);
      for (var i = 0; i < s.items.length; i++) {
        final it = s.items[i];
        final (wasRunning, progress) = before[i];
        final paid = it.automated
            ? it.progress < progress
            : wasRunning && !it.running;
        if (paid) {
          _pops[i]++;
          _lastPay[i] = s.incomePerCycle(i);
        }
      }
    });
    if (++_ticksSinceSave >= 50) {
      _ticksSinceSave = 0;
      _save();
    }
    // The second comic unlocks when the Mobile App is launched.
    if (s.items[1].level > 0 &&
        !s.comicsSeen.contains('chapter2') &&
        !_showingComic) {
      _showingComic = true;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ComicScreen(
            comicId: 'chapter2',
            language: lang,
            region: s.region,
            onDone: () {
              s.comicsSeen.add('chapter2');
              _showingComic = false;
              _save();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  Future<void> _welcomeBack() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final away = s.lastSeenMs == 0 ? 0 : now - s.lastSeenMs;
    final earned = s.offlineEarnings(now);
    s.lastSeenMs = now;
    if (away < _minAwayMs || earned < 1 || !mounted) return;
    final doubled = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GamePanel(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr(lang, 'welcome_back'), style: gameText(26, weight: 800)),
              const SizedBox(height: 4),
              Text(
                tr(lang, 'offline_earned'),
                textAlign: TextAlign.center,
                style: gameText(15, weight: 500, color: inkSoft),
              ),
              const SizedBox(height: 8),
              const Coin(64),
              Text(money(earned), style: gameText(34, weight: 800)),
              const SizedBox(height: 4),
              Text(
                tr(lang, 'ads_not_connected'),
                textAlign: TextAlign.center,
                style: gameText(12, weight: 500, color: inkSoft),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      color: 'blue',
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(tr(lang, 'collect')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GameButton(
                      color: 'green',
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('${tr(lang, 'double_it')} x2'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    setState(() => s.earn(doubled == true ? earned * 2 : earned));
    _save();
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          void update(VoidCallback change) {
            setState(change);
            setSheet(() {});
            _save();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr(lang, 'settings'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: lang,
                    decoration: InputDecoration(labelText: tr(lang, 'language')),
                    items: [
                      for (final (code, name, ready) in allLanguages)
                        if (ready) DropdownMenuItem(value: code, child: Text(name)),
                    ],
                    onChanged: (v) => update(() => s.language = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: s.region,
                    decoration: InputDecoration(labelText: tr(lang, 'region')),
                    items: [
                      for (final code in regions)
                        DropdownMenuItem(
                          value: code,
                          child: Text(tr(lang, 'region_$code')),
                        ),
                    ],
                    onChanged: (v) => update(() => s.region = v),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => _confirmReset(context),
                    child: Text(tr(lang, 'reset_progress')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(BuildContext sheetContext) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(tr(lang, 'reset_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr(lang, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr(lang, 'reset_progress')),
          ),
        ],
      ),
    );
    if (ok != true || !sheetContext.mounted) return;
    Navigator.pop(sheetContext);
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _hud(),
              Expanded(child: Center(child: _office())),
              _card(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.fromLTRB(5, 3, 14, 3),
    decoration: BoxDecoration(
      color: navy.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );

  Widget _hud() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _pill(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Coin(30),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        money(s.cash),
                        style: gameText(24, weight: 800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: lip, offset: Offset(0, 4))],
            ),
            child: Text(
              '+${money(s.incomePerSecond)}${tr(lang, 'per_second')}',
              style: gameText(15, weight: 800, color: moneyGreen),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openSettings,
            child: Container(
              padding: const EdgeInsets.all(7),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: lip, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.settings, color: ink),
            ),
          ),
        ],
      ),
    );
  }

  /// The office: one picture built from stacked layers. A zone appears when
  /// its product is launched and bounces each time it pays out. Tapping a
  /// zone opens its card and puts its team to work.
  Widget _office() {
    Widget layer(String name) =>
        Positioned.fill(child: Image.asset(art('office_$name')));
    return AspectRatio(
      aspectRatio: 1560 / 1170,
      child: LayoutBuilder(
        builder: (context, box) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (tap) {
            final id = zoneAt(tap.localPosition, box.biggest);
            if (id == null) return;
            setState(() {
              _selected = _index(id);
              s.startCycle(_selected);
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              layer('base'),
              for (final id in zoneOrder)
                if (s.items[_index(id)].level > 0)
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('$id${_pops[_index(id)]}'),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, t, child) => Transform.scale(
                        scale: _pops[_index(id)] == 0 ? 1 : 1 + 0.04 * sin(pi * t),
                        alignment: Alignment(
                          zoneSpot[id]!.dx * 2 - 1,
                          zoneSpot[id]!.dy * 2 - 1 + 0.3,
                        ),
                        child: child,
                      ),
                      child: Image.asset(art('office_$id')),
                    ),
                  ),
              layer('front'),
              for (final id in zoneOrder) _marker(id, box.biggest),
              for (final id in zoneOrder)
                if (_pops[_index(id)] > 0)
                  Positioned(
                    left: zoneSpot[id]!.dx * box.maxWidth - 60,
                    top: zoneSpot[id]!.dy * box.maxHeight - 26,
                    width: 120,
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('pop$id${_pops[_index(id)]}'),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        builder: (context, t, child) => Opacity(
                          opacity: 1 - t * t,
                          child: Transform.translate(
                            offset: Offset(0, -30 * t),
                            child: child,
                          ),
                        ),
                        child: Text(
                          '+${money(_lastPay[_index(id)])}',
                          textAlign: TextAlign.center,
                          style: gameText(17, weight: 800, color: Colors.white).copyWith(
                            shadows: const [
                              Shadow(color: Color(0xFF1F8F4E), offset: Offset(0, 2)),
                              Shadow(color: Color(0xFF1F8F4E), blurRadius: 3),
                            ],
                          ),
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

  int _index(String id) => startupProducts.indexWhere((p) => p.id == id);

  /// What floats over a zone: a lock and price while it is not launched, and
  /// a pointer while its card is open.
  Widget _marker(String id, Size size) {
    final i = _index(id);
    final owned = s.items[i].level > 0;
    final selected = i == _selected;
    if (owned && !selected) return const SizedBox.shrink();
    final spot = zoneSpot[id]!;
    const amber = Color(0xFFFFB020);
    return Positioned(
      left: spot.dx * size.width - 70,
      top: spot.dy * size.height - (owned ? 62 : 16),
      width: 140,
      child: IgnorePointer(
        child: Center(
          child: owned
              ? Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: amber,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: selected ? Border.all(color: amber, width: 3) : null,
                    boxShadow: const [BoxShadow(color: lip, offset: Offset(0, 3))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 14, color: ink),
                      Text(
                        ' ${money(s.upgradeCost(i))}',
                        style: gameText(13, weight: 800),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// The card of the selected zone, at the bottom of the screen.
  Widget _card() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: lip, offset: Offset(0, 4))],
        ),
        child: _productRow(_selected),
      ),
    );
  }

  Widget _productRow(int i) {
    final item = s.items[i];
    final def = startupProducts[i];
    final owned = item.level > 0;
    final canWork = owned && !item.automated && !item.running;
    final status = item.automated
        ? tr(lang, 'automated')
        : item.running
        ? tr(lang, 'working')
        : tr(lang, 'tap_to_work');
    final icon = Image.asset(art('icon_${def.id}'), width: 64, height: 64);

    return GestureDetector(
      onTap: canWork ? () => setState(() => s.startCycle(i)) : null,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  owned ? icon : ColorFiltered(colorFilter: _greyscale, child: icon),
                  if (!owned) const Icon(Icons.lock, size: 26, color: ink),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang, 'product_${def.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: gameText(17, weight: 800),
                  ),
                  if (owned) ...[
                    Text(
                      '${tr(lang, 'level')} ${item.level}  •  '
                      '${money(s.incomePerCycle(i))} ${tr(lang, 'per_cycle')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: gameText(12.5, color: inkSoft),
                    ),
                    const SizedBox(height: 4),
                    _progressBar(item.progress.clamp(0, 1).toDouble(), status),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 112,
              child: Column(
                children: [
                  GameButton(
                    color: owned ? 'green' : 'amber',
                    height: 40,
                    onPressed: s.cash >= s.upgradeCost(i)
                        ? () => setState(() => s.upgrade(i))
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr(lang, owned ? 'upgrade' : 'launch').toUpperCase(),
                          style: const TextStyle(fontSize: 13, height: 1.05),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Coin(13),
                            Text(
                              ' ${money(s.upgradeCost(i))}',
                              style: const TextStyle(fontSize: 14, height: 1.05),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (owned && !item.automated) ...[
                    const SizedBox(height: 4),
                    GameButton(
                      color: 'blue',
                      height: 32,
                      onPressed: s.cash >= s.managerCost(i)
                          ? () => setState(() => s.hireManager(i))
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(art('manager'), height: 24),
                          Text(
                            ' ${money(s.managerCost(i))}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(double value, String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E0EA),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(color: const Color(0xFFFFB020)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: gameText(11, color: inkSoft)),
      ],
    );
  }
}
