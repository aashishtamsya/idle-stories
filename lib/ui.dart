import 'package:flutter/material.dart';

/// Shared game look, following docs/art-guideline.md: flat colours, hard
/// edges, a solid darker lip under raised pieces. Scene art comes from
/// Blender (assets/art, regenerate with tool/render_assets.py).

const ink = Color(0xFF22304A);
const inkSoft = Color(0xFF7A8699);
const navy = Color(0xFF1B2540);
const mint = Color(0xFF8FD9C8);
const surface = Color(0xFFF1F5F9);
const lip = Color(0xFFC9D3DF);
const moneyGreen = Color(0xFF1F9D57);

String art(String name) => 'assets/art/$name.png';

TextStyle gameText(
  double size, {
  double weight = 700,
  Color color = ink,
  bool outline = false,
}) => TextStyle(
  fontFamily: 'Anek',
  fontSize: size,
  height: 1.15,
  color: color,
  fontVariations: [FontVariation('wght', weight), FontVariation('wdth', 105)],
  shadows: outline
      ? const [Shadow(color: Color(0x66000000), offset: Offset(0, 2))]
      : null,
);

/// Flat mint backdrop behind every screen.
class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7FD3C1), mint],
      ),
    ),
    child: child,
  );
}

/// Flat gold coin.
class Coin extends StatelessWidget {
  final double size;
  const Coin(this.size, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFFFC02E),
      border: Border.all(color: const Color(0xFFE39A00), width: size * 0.12),
    ),
    child: Center(
      child: Container(
        width: size * 0.34,
        height: size * 0.34,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFE08A),
        ),
      ),
    ),
  );
}

/// White card with a solid lip.
class GamePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GamePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: lip, offset: Offset(0, 5))],
    ),
    child: child,
  );
}

const _buttonColors = {
  'green': (Color(0xFF34C768), Color(0xFF1F8F4E)),
  'amber': (Color(0xFFFFB020), Color(0xFFD98700)),
  'blue': (Color(0xFF3D7BFF), Color(0xFF2757C9)),
  'grey': (Color(0xFFB8C2D0), Color(0xFF8E9BB0)),
};

/// Flat pressable button that sinks onto its lip.
class GameButton extends StatefulWidget {
  final String color; // green, amber, blue
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  const GameButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.child,
    this.height = 52,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final (face, edge) = _buttonColors[enabled ? widget.color : 'grey']!;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => down = true) : null,
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        margin: EdgeInsets.only(top: down ? 3 : 0, bottom: down ? 1 : 4),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: face,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: edge, offset: Offset(0, down ? 1 : 4))],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: DefaultTextStyle(
            style: gameText(17, weight: 800, color: Colors.white),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A selectable row used on the setup screens.
class ChoiceTile extends StatelessWidget {
  final String label;
  final String? note;
  final bool selected;
  final VoidCallback? onTap;
  const ChoiceTile({
    super.key,
    required this.label,
    this.note,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE9B8) : surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFFB020) : surface,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: gameText(20, color: enabled ? ink : inkSoft),
              ),
            ),
            if (note != null)
              Text(note!, style: gameText(13, weight: 500, color: inkSoft)),
            if (selected) const Icon(Icons.check_circle, color: ink),
          ],
        ),
      ),
    );
  }
}
