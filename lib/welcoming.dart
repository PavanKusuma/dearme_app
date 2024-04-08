import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/audio_handler.dart';
import 'package:psych_app/dashboard.dart';
import 'dart:math';

import 'package:psych_app/setup.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/verify.dart';
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';
// void welcome() {
//   // runApp(const Verify());
//   runApp( const MyWelcome());
// }

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> with SingleTickerProviderStateMixin {
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

// class MyApp3 extends StatefulWidget {
//   @override
//   _MyApp3State createState() => _MyApp3State();
// }

// class _MyApp3State extends State<MyApp3> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _rotationController;
//   late Animation<Color?> _colorAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 5),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 20),
//       vsync: this,
//     )..repeat();

//     _colorAnimation = TweenSequence<Color?>([
      
//       TweenSequenceItem(
//         tween: ColorTween(begin: const Color.fromARGB(255, 0, 255, 8), end: const Color.fromARGB(255, 255, 230, 0)),
//         weight: 1,
//       ),
//       TweenSequenceItem(
//         tween: ColorTween(begin: const Color.fromARGB(255, 255, 230, 0), end: const Color.fromARGB(255, 255, 17, 0)),
//         weight: 1,
//       ),
//       TweenSequenceItem(
//         tween: ColorTween(begin: const Color.fromARGB(255, 255, 17, 0), end: const Color.fromARGB(255, 92, 27, 255)),
//         weight: 1,
//       ),
//       TweenSequenceItem(
//         tween: ColorTween(begin: const Color.fromARGB(255, 230, 0, 255), end: const Color.fromARGB(255, 0, 255, 8)),
//         weight: 1,
//       ),
//     ]).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
        
//         body: AnimatedBuilder(
//           animation: _colorAnimation,
//           builder: (context, child) {
//             return Center(
//               child: RotationTransition(turns: _rotationController,
//               child: 
//               AnimatedContainer(
                
//                 duration: const Duration(seconds: 2),
//                 width: 600,
//                 height: 600,
//                 decoration: BoxDecoration(
//                   // color: Colors.black,
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       _colorAnimation.value ?? Colors.blue,
//                       Colors.white,
//                     ],
//                   ),
//                 ),
//               )
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



class MyWelcome extends StatefulWidget {

  // final MyAudioHandler audioHandler;

  // MyWelcome({required this.audioHandler});
  

  @override
  _MyWelcomeState createState() => _MyWelcomeState();
  
}

class _MyWelcomeState extends State<MyWelcome> {

  bool userExists = false, theme = true;
  static int year = 0, profileUpdated = 0;
  static String username = '', role='', type='', branch='', collegeId='';
  

  @override
  void initState() {
    // get user data
    getUserData();

    super.initState();
  }

  // get user data
  void getUserData() async {
    
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
      if(preferences.containsKey(Constants.username)){
        
        setState(() {
          userExists = true;
          username = preferences.getString(Constants.username)!;
          collegeId = preferences.getString(Constants.collegeId)!;
          role = preferences.getString(Constants.role)!;
          // theme = themeChangeProvider.darkTheme;
          // theme = themeChange.darkTheme;
    
          // theme = preferences.getBool(Constants.themeStatus)!;
          // print("theme"+theme.toString());
        });
      }

      // if(preferences.containsKey(Constants.pendingPay)){
      //   pendingPay = preferences.getBool(Constants.pendingPay)!;
      // }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Accessing the audioHandler instance
    final audioHandler = Provider.of<AudioHandler>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          
          children: [
            // Container(
            //   child:  MyApp2(),
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Colors.pink.withOpacity(0.3),
                    // Colors.black.withOpacity(0.3),

                    //  Colors.black45.withOpacity(0.3),
                    
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.1),
                    // Colors.black45.withOpacity(0.3),
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
            Positioned(
              // top: (MediaQuery.of(context).size.height/2)-20,
              top: 120,
              left: 0,
              right: 0,
              child: Container(
              alignment: Alignment.center,
                // height: MediaQuery.of(context).size.height,
                child: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                
                children: [
                  
                    Center(child:
                      Text('Dear Me,', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displayMedium, color: Colors.black87, fontWeight: FontWeight.normal)), 
                    ),
                    // const Text( 'Dear Me,', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), ),
                    // Image.network('list[0].media!', height: 50,),
                    Image.asset( 'assets/getstarted.webp', scale: 1.5),
                    // TypewriterText("Your well-being is your priority!"),
                    TypewriterText("You deserve happiness!"),
                    DelayedStart( userExists: userExists,),
                    sizedBox(32),
                    TextButton(
                      onPressed: () {
                        
                        audioHandler.stop();
                      },
                      child: Text("Play background music", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontSize: 14, fontWeight: FontWeight.normal)), 
                    ),
                    Center(child:
                      Text('You can Stop/Play the music from your profile later.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall, color: Colors.black54, fontSize: 12, fontWeight: FontWeight.normal)), 
                    )
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}




class TypewriterText extends StatefulWidget {
  final String text;

  TypewriterText(this.text);

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  int _charIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _displayedText += widget.text[_charIndex];
        _charIndex++;
      });

      if (_charIndex >= widget.text.length) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width/10),
      alignment: Alignment.center,
      child: 
    Text(_displayedText, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black87, ),  )
    );
  }
}



class DelayedStart extends StatefulWidget {
  //  const DelayedStart(bool userExists, {super.key});

  //  final Appointment appointment;
   final bool userExists;

  DelayedStart({required this.userExists});

  // @override
  // _MyWelcomeState createState() => _MyWelcomeState();
  
  // final VoidCallback onPressed;

  // const DelayedStart({
  //   Key? key,
  //   required this.onPressed,
  // }) : super(key: key);

  @override
  _DelayedStartState createState() => _DelayedStartState();
}

class _DelayedStartState extends State<DelayedStart> {
  // final bool userExists;
  // _DelayedStartState(this.userExists);

   bool _showButton = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showButton
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6302E5),
                // primary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                 if (widget.userExists) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SetUp()));
                    // return const GreetUser();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Verify()));
                    
                    // return const Verification();
                  }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 14.0,
                ),
                child: Text('Get Started', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
              ),
            )
          : const SizedBox(),
    )
    ;
  }
}
          
        