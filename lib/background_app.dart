import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({Key? key}) : super(key: key);

  @override
  _RelaxScreenState createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;
  late Animation<Color?> _color3Animation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late MyAudioHandler _audioHandler;
  bool _isPlaying = false;

  // Calming color palettes
  static const List<Color> _calmColors = [
    Color(0xFF667eea), // Soft indigo
    Color(0xFF764ba2), // Muted purple
    Color(0xFF6B8DD6), // Calm blue
    Color(0xFF8E7CC3), // Lavender
    Color(0xFF48C6A9), // Soft teal
    Color(0xFF6190E8), // Sky blue
    Color(0xFFA7BFE8), // Pale blue
    Color(0xFF7F7FD5), // Periwinkle
    Color(0xFF86A8E7), // Light steel blue
    Color(0xFF91EAE4), // Aqua mint
  ];

  @override
  void initState() {
    super.initState();

    // Slow gradient animation — 12 seconds for a calm feel
    _gradientController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _color1Animation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[0], end: _calmColors[4]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[4], end: _calmColors[7]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[7], end: _calmColors[0]),
        weight: 1,
      ),
    ]).animate(_gradientController);

    _color2Animation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[1], end: _calmColors[5]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[5], end: _calmColors[8]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[8], end: _calmColors[1]),
        weight: 1,
      ),
    ]).animate(_gradientController);

    _color3Animation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[2], end: _calmColors[6]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[6], end: _calmColors[9]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _calmColors[9], end: _calmColors[2]),
        weight: 1,
      ),
    ]).animate(_gradientController);

    // Breathing pulse animation — 4 seconds in, 4 seconds out
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioHandler = Provider.of<AudioHandler>(context, listen: false) as MyAudioHandler;
    _isPlaying = _audioHandler.isPlaying();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _audioHandler.pause();
        _isPlaying = false;
      } else {
        _audioHandler.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Stack(
            children: [
              // Full-screen animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _color1Animation.value ?? _calmColors[0],
                      _color2Animation.value ?? _calmColors[1],
                      _color3Animation.value ?? _calmColors[2],
                    ],
                  ),
                ),
              ),

              // Centered ambient orb
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(_isPlaying ? 0.35 : 0.15),
                              Colors.white.withOpacity(_isPlaying ? 0.10 : 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content overlay
              SafeArea(
                child: Column(
                  children: [
                    // Top bar with back button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              PhosphorIconsRegular.arrowLeft,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Track info
                    Text(
                      'Relax',
                      style: GoogleFonts.dmSerifText(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calming Ambient',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isPlaying ? 'Breathe in... Breathe out...' : 'Tap play to begin',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Play/Pause button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isPlaying
                              ? PhosphorIconsFill.pause
                              : PhosphorIconsFill.play,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom hint
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        'Audio will continue playing in the background',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
