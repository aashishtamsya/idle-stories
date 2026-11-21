import 'package:flutter/material.dart';

import 'strings.dart';
import 'ui.dart';

/// A comic panel: a caption plus stand-in art (a game sprite on a colour
/// wash) until real illustrated panels exist.
typedef ComicPanel = (String captionKey, String sprite, Color color);

const comics = <String, List<ComicPanel>>{
  'intro': [
    ('intro_1', 'icon_saas', Color(0xFF5C6BC0)),
    ('intro_2', 'manager', Color(0xFF26A69A)),
    ('intro_3', 'icon_freelance', Color(0xFFFF8A50)),
    ('intro_4', 'icon_ai', Color(0xFFAB47BC)),
  ],
  'chapter2': [
    ('ch2_1', 'icon_app', Color(0xFF26A69A)),
    ('ch2_2', 'manager', Color(0xFF5C6BC0)),
    ('ch2_3', 'icon_cloud', Color(0xFFEF5350)),
  ],
};

class ComicScreen extends StatefulWidget {
  final String comicId;
  final String language;
  final String? region;
  final VoidCallback onDone;
  const ComicScreen({
    super.key,
    required this.comicId,
    required this.language,
    required this.region,
    required this.onDone,
  });

  @override
  State<ComicScreen> createState() => _ComicScreenState();
}

class _ComicScreenState extends State<ComicScreen> {
  final controller = PageController();
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panels = comics[widget.comicId]!;
    final last = page == panels.length - 1;
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller,
                  onPageChanged: (p) => setState(() => page = p),
                  children: [
                    for (final (captionKey, sprite, color) in panels)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 3),
                                  gradient: RadialGradient(
                                    radius: 0.9,
                                    colors: [Colors.white, color],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(child: Image.asset(art(sprite))),
                                    Positioned(
                                      right: 8,
                                      bottom: 6,
                                      child: Text(
                                        tr(widget.language, 'placeholder_art'),
                                        style: gameText(
                                          11,
                                          weight: 500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3C4),
                                border: Border.all(color: Colors.black, width: 3),
                              ),
                              child: Text(
                                trStory(widget.language, widget.region, captionKey),
                                style: gameText(18, weight: 600, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < panels.length; i++)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == page ? const Color(0xFFFFC94A) : Colors.white24,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              GameButton(
                color: last ? 'green' : 'amber',
                height: 60,
                onPressed: last
                    ? widget.onDone
                    : () => controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                child: Text(tr(widget.language, last ? 'start' : 'next')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
