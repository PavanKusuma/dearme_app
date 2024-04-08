import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;

import 'package:psych_app/background_app.dart';
import 'package:psych_app/util/sizedbox.dart';

class MoodWheel extends StatefulWidget {
  @override
  _MoodWheelState createState() => _MoodWheelState();
}

class _MoodWheelState extends State<MoodWheel> {
  double _rotation = 0.0;
  final int _totalImages = 6;
  int _currentFocusIndex = 0;

  void _updateRotation(Offset details) {
    setState(() {
      _rotation += details.dx / 100; // Adjust for sensitivity
    });
    _updateFocusIndex();
  }

  void _updateFocusIndex() {
    double anglePerImage = 2 * math.pi / _totalImages;
    double currentAngle = _rotation % (2 * math.pi);
    int newFocusIndex = (((currentAngle + math.pi / 2) % (2 * math.pi)) / anglePerImage).floor() % _totalImages;
    if (newFocusIndex != _currentFocusIndex) {
      _currentFocusIndex = newFocusIndex;
      print('Image in focus: Image ${_currentFocusIndex + 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth;
    final radius = circleSize / 2;
    final imageRadius = radius / 2;

    return Scaffold(
      // appBar: AppBar(title: Text("Rotating Circle")),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
              child:  BackgroundGradient(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.pink.withOpacity(0.3),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: 
              Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/nois.png'),
                  repeat: ImageRepeat.repeat, // Tile the image across the screen
                  opacity: 0.3
                ),
              ),
              
            ),
            ),

SafeArea(

        child: 
        
      
        Builder(builder: (context) => Container(


        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

             Container(
                margin: const EdgeInsets.all(16),
                child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Mood Check-in', style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.displaySmall)), 
                        InkWell(
                            onTap: () => 

                                // show dialog to confirm exit
                                Navigator.pop(context)
                              ,
                            child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(PhosphorIconsBold.x),
                          ),
                        )
                        
                      ],),
                        
                        sizedBox(8),
                        Text('Monitor regularly to know and act on your emotions', style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.titleMedium), textAlign: TextAlign.center,), 
                        sizedBox(8)
                      ],
                    ),
              ),

              Container(
                        decoration: const BoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('Happy', style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
          ]
        )))),

          Positioned(
            bottom: -(MediaQuery.of(context).size.width/2), // Adjust to control hidden portion
            child: 
          GestureDetector(
            onPanUpdate: (details) => _updateRotation(details.delta),
            child: Transform.rotate(
              angle: _rotation,
              child: Container(
                height: circleSize,
                width: circleSize,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   color: Colors.amber,
                // ),
                 decoration: BoxDecoration(
                  shape: BoxShape.circle,
                    color: const Color(0x66FFFFFF),
                    border: Border.all(color: const Color(0xFFFFFFFF)),
                    // color: Color(0xFFFFFFFF),
                    // borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        // color: Colors.black26,
                        color: Color(0xCCFFFFFF),
                        // color: Color(0xFF080B23),
                        offset: Offset(0.0, 0.0),
                        blurRadius: 24.0,
                        spreadRadius: 0.3,
                      ),
                    ]
                  ),
                child: Stack(
                  children: List.generate(_totalImages, (index) {
                    final angle = (math.pi / 3) * index;
                    final counterAngle = -_rotation;
                    final x = radius + (math.cos(angle) * imageRadius) - 45; // Offset by half image size
                    final y = radius + (math.sin(angle) * imageRadius) - 45; // Offset by half image size
                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.rotate(
                        angle: counterAngle,
                        child: Image.asset(
                          'assets/image${index + 1}.png',
                          width: 90,
                          height: 90,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          )
        ],
      ),
    );
  }
}
