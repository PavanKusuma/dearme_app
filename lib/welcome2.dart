import 'dart:async';

import 'package:flutter/material.dart';
import 'package:psych_app/dashboard.dart';
import 'dart:math';

import 'package:psych_app/setup.dart';
import 'package:psych_app/verify.dart';
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';
void welcome() {
  // runApp(const Verify());
  runApp( const MyApp());
}

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

class MyApp3 extends StatefulWidget {
  @override
  _MyApp3State createState() => _MyApp3State();
}

class _MyApp3State extends State<MyApp3> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 0, 255, 8), end: const Color.fromARGB(255, 255, 230, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 255, 230, 0), end: const Color.fromARGB(255, 255, 17, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 255, 17, 0), end: const Color.fromARGB(255, 92, 27, 255)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: const Color.fromARGB(255, 230, 0, 255), end: const Color.fromARGB(255, 0, 255, 8)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
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
              child: RotationTransition(turns: _rotationController,
              child: 
              AnimatedContainer(
                
                duration: const Duration(seconds: 2),
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  // color: Colors.black,
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _colorAnimation.value ?? Colors.blue,
                      Colors.white,
                    ],
                  ),
                ),
              )
              ),
            );
          },
        ),
      ),
    );
  }
}


class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          
          children: [
            // Container(
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage('assets/noise.png'),
            //       repeat: ImageRepeat.repeat, // Tile the image across the screen
            //     ),
            //   ),
            // ),

            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Colors.blue,
            //         Colors.transparent,
            //       ],
            //     ),
            //   ),
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.bottomLeft,
            //       end: Alignment.topRight,
            //       colors: [
            //         Colors.red,
            //         Colors.transparent,
            //       ],
            //     ),
            //   ),
            // ),
            Container(
              // alignment: Alignment.topLeft,
              child:  MyApp2(),
            ),
           
            // MyApp3(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Colors.pink.withOpacity(0.3),
                    // Colors.black.withOpacity(0.3),

                     Colors.black45.withOpacity(0.3),
                    
                    Colors.grey.withOpacity(0.3),
                    Colors.black45.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // ColorChangingBlob(),
            // MovingGradientSphere(),
            //  Noise texture overlay
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
                // Image.asset(
                  
                //   'assets/nois.png',
                //   fit: BoxFit.fill,
                //   opacity: const AlwaysStoppedAnimation(.2),
                // ),
              
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height/2)-20,
              left: 0,
              right: 0,
              child: Container(
              alignment: Alignment.center,
                // height: MediaQuery.of(context).size.height,
                child: 
              Column(
                children: [
                   const Text(
                'TRUST',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
                  TypewriterText("Welcome here! \nWe believe that you are the most unique human being ever existed on this planet. \nEverything that you do will help you become the better version of yourself."),
                  // TypewriterText("Believe in you!"),
                  DelayedStartButton(
                    onPressed: () {
                    },
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

class ColorChangingBlob extends StatefulWidget {
  @override
  _ColorChangingBlobState createState() => _ColorChangingBlobState();
}

class _ColorChangingBlobState extends State<ColorChangingBlob>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<Offset> _positionTween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _positionTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(30.0, 30.0),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Generate random gradient colors based on animation value
        // final color1 = HSVColor.fromAHSV(1, _animationController.value * 360, 1, 1).toColor();
        // final color2 = HSVColor.fromAHSV(1, (_animationController.value + 0.3) * 360, 1, 1).toColor();

// Generate random gradient colors within valid hue range
final color1 = HSVColor.fromAHSV(
  1,
  (_animationController.value * 360) % 360, // Ensure hue stays within 0-360
  1,
  1,
).toColor();
final color2 = HSVColor.fromAHSV(
  1,
  ((_animationController.value + 0.3) * 360) % 360, // Ensure hue stays within 0-360
  1,
  1,
).toColor();


        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(minutes: 5),
              top: _positionTween.evaluate(_animationController).dy,
              right: _positionTween.evaluate(_animationController).dx,
              child: CustomPaint(
                painter: BlobPainter(
                  color1: color1,
                  color2: color2,
                  offset: _positionTween.evaluate(_animationController),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BlobPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Offset offset;

  BlobPainter({
    required this.color1,
    required this.color2,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.srcOver;

    final path = Path()
      ..moveTo(offset.dx, offset.dy)
      ..relativeLineTo(20.0, 0.0)
      ..quadraticBezierTo(30.0, 10.0, 20.0, 20.0)
      ..close();

    // final blobPath = Offset(size.width * 0.7, size.height * 0.7) + path.transform(
    //   Matrix4.translationValues(offset.dx, offset.dy, 0.0),
    // );

final transformedPath = path.transform(Matrix4.translationValues(offset.dx, offset.dy, 0.0).storage,);

    final gradient = LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

// Use the transformed path directly for drawing
canvas.drawPath(transformedPath, paint..shader = gradient.createShader(canvas.getLocalClipBounds()));

    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
  
}

class _MyAppState extends State<MyApp> {

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: MovingGradientSphere(),
      // home: MeshGradientBackground(),
      home: Container(
        // color: Colors.grey.withOpacity(0.9),
        color: const Color(0xFF080B23),
        // decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //         stops: [0.0, 0.5, 1.0],
        //         colors: [
        //           Color(0xFFa190d5), // A lighter shade based on the average color for the top left
        //           Color(0xFFc5ace6), // The average color for the center
        //           Color(0xFFddb8f0), // A darker shade based on the average color for the bottom right
        //         ],
        //       ),
        //     ),
      child:
      Center(
          child:Container(
            child: GlareBackground(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotatingImage(),
                const SizedBox(height: 20), // Space between the globe and the text
                TypewriterText("Believe in you!"), // Replace with your own text
                const SizedBox(height: 20),
                
                GlassyButton(userExists),
                
              ],
            ),
          ),
            // child: Text('Smart Campus App Update',style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 18, fontWeight: FontWeight.bold) ),    
          )

          
          // GlassSphere(),
        ),)
      // const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
    
    
    Scaffold(
      appBar: AppBar(
         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: MovingGradientSphere(),
      
    );
  }
}



// Moving gradient
class MovingGradientSphere extends StatefulWidget {
  @override
  _MovingGradientSphereState createState() => _MovingGradientSphereState();
}

class _MovingGradientSphereState extends State<MovingGradientSphere>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _colorAnimation = ColorTween(begin:  const Color.fromARGB(255, 162, 184, 255), end: const Color(0xFFFF9A8B))
    // _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.green)
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(500, 500),
              painter: MovingGradientSpherePainter(_colorAnimation.value),
              // painter: MovingGradientSpherePainter(_colorAnimation.value),
            );
          },
        ),
      ),
    );
  }
}




class MovingGradientSpherePainter extends CustomPainter {
  final Color? color;

  MovingGradientSpherePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      colors: [color!, Colors.white.withOpacity(0.4)],
    );
    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}








// Mesh Gradient
class MeshGradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return MultiGradientShader(bounds);
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: MovingGradientSphere(),
      ),
    );
  }

  Shader MultiGradientShader(Rect bounds) {
    return const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFE2EBF0), // Light blueish color
                  Color(0xFFC9D6FF), // Soft blue
                  Color(0xFFE2E2E2), // Light grey for a neutral transition
                  Color(0xFFFFDAC1), // Soft peach
                  Color(0xFFFF9A8B), // Light pink
                ],
                stops: [0.1, 0.3, 0.5, 0.7, 0.9],
              ).createShader(bounds);
  }
}





// bubbles
class GlassSphere extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Size of the glass sphere
    final double size = 200.0;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2), // Semi-transparent white
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}








class GlareBackground extends StatelessWidget {
  final Widget child;

  GlareBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
               const Color(0xFF4A00E0), // Inner color
                Colors.black.withOpacity(0),    // Outer color, fully transparent
              ],
              stops: [0.0, 0.9],
            ),
          ),
          width: 300, // Adjust the size of the glare to fit your design
          height: 300,
        ),
        child, // The RotatingImage widget is now correctly included
      ],
    );
  }
}


class RotatingImage extends StatefulWidget {
  @override
  _RotatingImageState createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Container(
        height: 250,
        width: 250,
        child: Image.asset('assets/globe.png'), // Make sure to include the image in your assets folder
      ),
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14,
          child: child,
        );
      },
    );
  }
}


class DelayedStartButton extends StatefulWidget {
  final VoidCallback onPressed;

  const DelayedStartButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _DelayedStartButtonState createState() => _DelayedStartButtonState();
}

class _DelayedStartButtonState extends State<DelayedStartButton> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 18), () {
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
                primary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 14.0,
                ),
                child: Text('Get Started', style: GoogleFonts.robotoMono(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, ), ),
              ),
            )
          : const SizedBox(),
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
      alignment: Alignment.centerLeft,
      child: 
    Text(_displayedText, style: GoogleFonts.robotoMono(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white, ),  )
    );
  }
}

class GlassyButton extends StatelessWidget {
  final bool userExists;
  GlassyButton(this.userExists);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

         if (userExists) {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => SetUp()));
            // return const GreetUser();
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Verify()));
            
            // return const Verification();
          }
        // Perform action on tap
        // Navigator.pop(context);
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SetUp()));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8E2DE2), // Start color of the globe
                Color(0xFF4A00E0), // End color of the globe
              ],
            ),
              borderRadius: BorderRadius.circular(30.0),
              // color: Colors.white.withOpacity(0.1), // Semi-transparent white color
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text('Get Started', style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)  )
          ),
        ),
      ),
    );
  }
}
          
        

// class RotatingImage extends StatefulWidget {
//   @override
//   _RotatingImageState createState() => _RotatingImageState();
// }

// class _RotatingImageState extends State<RotatingImage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10), // Define the duration of the rotation here
//       vsync: this,
//     )..repeat(); // Use repeat() to make the animation go on indefinitely
//   }

//   @override
//   void dispose() {
//     _controller.dispose(); // Always dispose of the controller when the widget is removed from the widget tree
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       child: Container(
//         // height: 200.0, // Set the width and height to fit your design
//         // width: 200.0,
//         child: Image.asset('assets/globe.png'), // Make sure to add your image in the assets directory
//       ),
//       builder: (context, child) {
//         return Transform.rotate(
//           angle: _controller.value * 2.0 * 3.14, // Rotate the child widget around this angle
//           child: child,
//         );
//       },
//     );
//   }
// }