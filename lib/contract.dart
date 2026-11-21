import 'package:flutter/material.dart';

import 'names.dart';
import 'strings.dart';
import 'ui.dart';

const _paper = Color(0xFFFFF8E7);
const _penBlue = Color(0xFF1F3FA8);
const _stampRed = Color(0xFFD64545);

/// The company registration paper. The player writes their name, it is
/// signed across the line in handwriting, and the paper is stamped. Pops
/// with the name, or with nothing when the player backs out.
class ContractScreen extends StatefulWidget {
  final String language;
  final String? region;
  const ContractScreen({super.key, required this.language, required this.region});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final _name = TextEditingController();
  bool _signing = false;
  bool _stamped = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final name = _name.text.trim();
    final problem = nameProblem(name);
    void sign() {
      if (problem != null) return;
      FocusScope.of(context).unfocus();
      setState(() => _signing = true);
    }

    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: _paper,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tr(lang, 'contract_title').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: gameText(22, weight: 800, color: Colors.black),
                      ),
                      Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.black,
                      ),
                      Text(
                        trStory(lang, widget.region, 'contract_body'),
                        style: gameText(16, weight: 500, color: Colors.black),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 64,
                        child: _signing
                            ? _signature(name)
                            : TextField(
                                controller: _name,
                                autofocus: true,
                                maxLength: 16,
                                textCapitalization: TextCapitalization.words,
                                style: gameText(24, weight: 800),
                                decoration: InputDecoration(
                                  hintText: tr(lang, 'contract_sign_here'),
                                  hintStyle: gameText(17, weight: 600, color: inkSoft),
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => sign(),
                              ),
                      ),
                      Container(height: 2, color: Colors.black),
                      const SizedBox(height: 4),
                      Text(
                        tr(lang, 'contract_role'),
                        style: gameText(13, weight: 600, color: inkSoft),
                      ),
                      if (!_signing && problem != null && name.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            tr(lang, problem),
                            style: gameText(14, weight: 600, color: _stampRed),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_stamped)
                  Positioned(right: 14, bottom: 34, child: _stamp(lang)),
              ],
            ),
            const SizedBox(height: 16),
            if (_signing)
              GameButton(
                color: 'green',
                height: 60,
                onPressed: _stamped ? () => Navigator.pop(context, name) : null,
                child: Text(tr(lang, 'continue')),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      color: 'blue',
                      height: 60,
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr(lang, 'cancel')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GameButton(
                      color: 'green',
                      height: 60,
                      onPressed: problem == null ? sign : null,
                      child: Text(tr(lang, 'sign')),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// The name written across the line from left to right, as if by a pen.
  Widget _signature(String name) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      onEnd: () => setState(() => _stamped = true),
      builder: (context, t, child) => Align(
        alignment: Alignment.bottomLeft,
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            child: child,
          ),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform(
          transform: Matrix4.skewX(-0.18),
          child: Text(
            name,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: 'Sign',
              fontFamilyFallback: ['Anek'],
              fontSize: 48,
              height: 1.1,
              color: _penBlue,
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stamp(String lang) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 2.2, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeIn,
      builder: (context, scale, child) => Transform.rotate(
        angle: -0.22,
        child: Transform.scale(scale: scale, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: _stampRed, width: 4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tr(lang, 'signed'),
          style: gameText(22, weight: 800, color: _stampRed),
        ),
      ),
    );
  }
}
