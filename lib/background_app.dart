import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BackgroundGradient extends StatefulWidget {
  @override
  _BackgroundGradientState createState() => _BackgroundGradientState();
}

class _BackgroundGradientState extends State<BackgroundGradient> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 0, 140, 255), end: const Color.fromARGB(255, 0, 255, 8)),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 0, 255, 8), end: const Color.fromARGB(255, 255, 230, 0)),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 242, 255, 0), end: const Color.fromARGB(255, 92, 27, 255)),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 230, 0, 255), end: const Color.fromARGB(255, 0, 140, 255)),
        weight: 0.2,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        
        body: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Center(
              child: AnimatedContainer(
                
                duration: const Duration(seconds: 2),
                width: 800,
                height: 800,
                decoration: BoxDecoration(
                  // color: Colors.black,
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _colorAnimation.value!,
                      Colors.white.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}