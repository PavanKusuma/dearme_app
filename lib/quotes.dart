import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/util/constants.dart' as Constants;

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  List<String> _quotes = [];
  bool _loading = true;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey _repaintKey = GlobalKey();

  // Gradient pairs for each card — cycles through
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
    [Color(0xFF2d1b69), Color(0xFF11998e)],
    [Color(0xFF200122), Color(0xFF6f0000)],
    [Color(0xFF0c0c1d), Color(0xFF1a1a3e), Color(0xFF2e2e5e)],
    [Color(0xFF1b1b2f), Color(0xFF162447), Color(0xFF1f4068)],
    [Color(0xFF141E30), Color(0xFF243B55)],
    [Color(0xFF0D324D), Color(0xFF7F5A83)],
  ];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    // Try loading from local storage first
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cached = prefs.getString('cached_affirmations');

    if (cached != null) {
      setState(() {
        _quotes = List<String>.from(jsonDecode(cached));
        _loading = false;
      });
      return;
    }

    // Load from assets and cache
    try {
      final jsonString = await rootBundle.loadString('assets/affirmations.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      List<dynamic> mixedList = jsonData[Constants.affirmations];
      List<String> quotes = mixedList.whereType<String>().toList();

      // Cache locally
      await prefs.setString('cached_affirmations', jsonEncode(quotes));

      setState(() {
        _quotes = quotes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _quotes = ['Start your day with enthusiasm!'];
        _loading = false;
      });
    }
  }

  Future<void> _shareQuote(int index) async {
    try {
      // Capture the card as image
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/dearme_quote.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _quotes[index],
      );
    } catch (e) {
      // Fallback to text share
      await Share.share(_quotes[index]);
    }
  }

  List<Color> _getGradient(int index) {
    return _cardGradients[index % _cardGradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : Stack(
              children: [
                // Full-screen PageView of quote cards
                PageView.builder(
                  controller: _pageController,
                  itemCount: _quotes.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      key: index == _currentIndex ? _repaintKey : null,
                      child: _QuoteCard(
                        quote: _quotes[index],
                        gradientColors: _getGradient(index),
                        index: index,
                        total: _quotes.length,
                      ),
                    );
                  },
                ),

                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            PhosphorIconsRegular.arrowLeft,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _shareQuote(_currentIndex),
                          icon: const Icon(
                            PhosphorIconsRegular.shareFat,
                            color: Colors.white70,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom page indicator
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_currentIndex + 1} / ${_quotes.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),

                // Swipe hint at bottom
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.arrowLeft, size: 14, color: Colors.white24),
                      const SizedBox(width: 8),
                      Text(
                        'Swipe for more',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(PhosphorIconsRegular.arrowRight, size: 14, color: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  final List<Color> gradientColors;
  final int index;
  final int total;

  const _QuoteCard({
    required this.quote,
    required this.gradientColors,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Opening quote mark
            Text(
              '\u201C',
              style: GoogleFonts.dmSerifText(
                fontSize: 72,
                color: Colors.white.withOpacity(0.2),
                height: 0.8,
              ),
            ),
            const SizedBox(height: 16),

            // Quote text
            Text(
              quote,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifText(
                fontSize: 26,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            // Thin divider line
            Container(
              width: 40,
              height: 1.5,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),

            // App branding
            Text(
              'Dear Me',
              style: GoogleFonts.dmSerifText(
                fontSize: 16,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
