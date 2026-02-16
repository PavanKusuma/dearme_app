import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/quotes.dart';
import 'package:psych_app/util/sizedbox.dart';

class Tools extends StatefulWidget {
  const Tools({Key? key}) : super(key: key);

  @override
  _ToolsState createState() => _ToolsState();
}

class _ToolsState extends State<Tools> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tools',
                style: GoogleFonts.dmSerifText(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              sizedBox(4),
              Text(
                'Explore tools to help you feel better',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              sizedBox(24),

              // Relax card
              _ToolCard(
                title: 'Relax',
                subtitle: 'Calming Ambient',
                description: 'Play soothing music and unwind with ambient visuals',
                icon: PhosphorIconsFill.play,
                gradientColors: const [Color(0xFF667eea), Color(0xFF764ba2)],
                lineColor: Colors.white.withOpacity(0.08),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RelaxScreen()),
                ),
              ),

              sizedBox(16),

              // Quotes card
              _ToolCard(
                title: 'Quotes',
                subtitle: 'Daily Affirmations',
                description: 'Swipe through uplifting quotes and share them',
                icon: PhosphorIconsFill.quotes,
                gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                lineColor: Colors.white.withOpacity(0.07),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuotesScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color lineColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.lineColor,
    required this.onTap,
  });

  @override
  _ToolCardState createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Animated subtle lines
              AnimatedBuilder(
                animation: _lineController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(MediaQuery.of(context).size.width - 32, 170),
                    painter: _LinePatternPainter(
                      progress: _lineController.value,
                      lineColor: widget.lineColor,
                    ),
                  );
                },
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints subtle animated flowing lines across the card
class _LinePatternPainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  _LinePatternPainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw several flowing sine wave lines that shift with progress
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * (0.15 + i * 0.18);
      final amplitude = 12.0 + i * 4.0;
      final phaseShift = progress * 2 * pi + i * 0.8;

      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 2) {
        final y = yOffset + sin((x / size.width) * 2 * pi + phaseShift) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
