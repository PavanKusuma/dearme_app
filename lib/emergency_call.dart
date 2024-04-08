import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

// // import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/appointment_new.dart';
import 'package:psych_app/assessments.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/library2.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/mood_monitor.dart';
import 'package:psych_app/mood_monitor_metrics.dart';
import 'package:psych_app/moodcheckin.dart';
import 'package:psych_app/moodcheckinwheel.dart';
import 'package:psych_app/moodwheel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show get;
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:psych_app/util/divider.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/progress.dart';
import 'package:psych_app/util/show_toast.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/utils.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:code_scan/code_scan.dart';

class EmergencyCalling extends StatefulWidget{
  const EmergencyCalling({Key? key}) : super(key: key);

  @override
  EmergencyCallingState createState() => EmergencyCallingState();
}

class EmergencyCallingState extends State<EmergencyCalling> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  TextEditingController descriptionController = new TextEditingController();
  ScrollController? scrollController;
  bool isLoading = false;
  bool connectionStatus = true;
  static int year = 0, profileUpdated = 0, mediaCount = 0;
  static String username = '', role='', type='', branch='', collegeId='', userImage='', description='';
  String selectedAffirmation = '';
  String foodStatDate = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now()).toString();
  int visitorsCount = 0;
  DateTime today = DateTime.now();
  // late AnimationController _animationController;
  // late AnimationController _animationController2;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  

  bool outingDataLoader = false;
  // int pending = 0, approved =0, issued =0, rejected = 0, returned = 0, inOuting = 0, official = 0;

  DateTime now = new DateTime.now();



  @override
  void initState() {
    // get user data
    getUserData();

_controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(_controller)
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          
          String telephoneUrl = "tel:7799813519";
          //callPhone(telephoneUrl);
          // await launch(telephoneUrl);
          await launchUrlString(telephoneUrl);
          // print('YESSSS');
          _controller.reverse();
        }
      });

    super.initState();
  }

  // get user data
  void getUserData() async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
      if(preferences.containsKey(Constants.username)){
        
        setState(() {
          username = preferences.getString(Constants.username)!;
          collegeId = preferences.getString(Constants.collegeId)!;
          role = preferences.getString(Constants.role)!;
          type = preferences.getString(Constants.type)!;
          year = preferences.getInt(Constants.year)!;
          branch = preferences.getString(Constants.branch)!;
          profileUpdated = preferences.getInt(Constants.profileUpdated)!;
          mediaCount = preferences.getInt(Constants.mediaCount)!;
          userImage = preferences.getString(Constants.userImage)!;


        });
        
      }
      

      // if(preferences.containsKey(Constants.pendingPay)){
      //   pendingPay = preferences.getBool(Constants.pendingPay)!;
      // }
  }


    
 

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context){
    // _scale = 1 + _animationController2.value;
     super.build(context);   
    // get the selected theme
    // get the selected theme
    
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          
          children: [
            // Container(
            //   child:  BackgroundGradient(),
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Colors.pink.withOpacity(0.3),
                    // Colors.black.withOpacity(0.3),

                    // Colors.pink.withOpacity(0.5),
                    // Colors.black45.withOpacity(0.3),
                    
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                    // Colors.black45.withOpacity(0.3),
                    // Colors.purple.withOpacity(0.3),
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


            Align(
              alignment: Alignment.topCenter,
              child:  SafeArea(
        child: 
        Container(
//        margin: EdgeInsets.all(16.0),
        
                  child: CustomScrollView(

                    slivers: <Widget>[
                      
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            sizedBox(16),
                           

                            Center(
                              child: connectionStatus ? sizedBox(0) : Text('No network detected. Try again later!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Palette.red, fontWeight: FontWeight.bold)),
                            ),
                            // Center(
                            //   child: Column(children: [
                            //     Text('Dear', style: GoogleFonts.dmSerifText(fontSize: 20, fontWeight: FontWeight.bold, )), 
                            //     Text('Me', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                            //   ],)
                              
                            //   // Text('Dear me,', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                            // ),
                            
                            // Center(
                            //   child: Text('Dear Me,', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                            //   // Text('Dear me,', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                            // ),


              Container(
                margin: const EdgeInsets.all(16),
                child: 
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(PhosphorIconsBold.arrowBendUpLeft),
                            ),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              
                              children: [ 
                                  Text('Emergency Contact', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                                  // sizedBox(8),
                                  // Text('Your data is encrypted and is private', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                                  // sizedBox(8)
                                ],
                            ),
                          
                          ],
                        ),
                      ),
                            sizedBox(64),
                            
                         
                          ],
                        ),
                      ),
                      
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                           

                         
                            
                            ////
                            //// MOOD MONITOR
                            ////
                            InkWell(
                              //  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodMonitor())),
                              
                              child: Container(
                                // height: 250,
                                margin: const EdgeInsets.fromLTRB(16,0,16,8),
                                padding: const EdgeInsets.all(32),
                                 decoration: BoxDecoration(
                                    // color: ui.Color(0xFFE4FDFF),
                                    gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          ui.Color.fromARGB(255, 242, 213, 210), // Start color of the globe
                                          ui.Color.fromARGB(255, 249, 185, 184), // End color of the globe
                                        ],
                                      ),
                                    // border: Border.all(color: const Color(0x44007E86)),
                                    // color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(10),
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
                                child: Container(
                                  height: MediaQuery.of(context).size.height/2,
                                      // padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    decoration: const BoxDecoration(
                                      // color: ui.Color(0x22007E86),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                       
                                        outingDataLoader ? const AppProgress(height: 20, width: 20,) : sizedBox(0),
                                        // Expanded( child: 
                                          // Column(
                                          //   children: [
                                          //     Image.asset('assets/moodmonitoring.webp', scale: 3,),
                                          //   ]
                                          // ),
                                        // ),
                                                    // const SizedBox(width: 32,),
                                        // Expanded( child: 
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                                  Text('For', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54)),
                                                  // sizedBox(8),
                                                  Text('EMERGENCY HELP', style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center,),
                                                  sizedBox(32),
                                                  
                                                  Text('Press and hold for 2 seconds to make the call', style: GoogleFonts.dmSans(fontSize: 20, color: Colors.black), textAlign: TextAlign.center,),
                                              
                                            ],
                                          ),

                                        Center(
                                                child: GestureDetector(
                                                  onLongPress: () => _controller.forward(),
                                                  onLongPressUp: () => _controller.reverse(),
                                                  child: AnimatedBuilder(
                                                    animation: _scaleAnimation,
                                                    builder: (_, child) {
                                                      // Scaling the container
                                                      return Transform.scale(
                                                        scale: _scaleAnimation.value,
                                                        child: Container(
                                                                    padding: const EdgeInsets.all(32),
                                                          // width: 100,
                                                          // height: 100,
                                                          decoration: const BoxDecoration(
                                                          // color: Palette.blue,
                                                          color: ui.Color.fromARGB(255, 255, 72, 0),
                                                          shape: BoxShape.circle,
                                                        
                                                          boxShadow: [
                                                            BoxShadow(
                                                              // color: Colors.black26,
                                                              color: ui.Color(0xCCFF3737),
                                                              // color: Color(0xFF080B23),
                                                              offset: Offset(0.0, 0.0),
                                                              blurRadius: 24.0,
                                                              spreadRadius: 0.3,
                                                            ),
                                                          ],
                                                        ),
                                                          child: Transform.scale(
                                                            // Counter-scaling the child
                                                            scale: 1 / _scaleAnimation.value,
                                                            alignment: Alignment.center,
                                                            child: child,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    // The child is passed here to avoid rebuilding it on every animation frame
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Text('SOS', style: GoogleFonts.dmSans(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
                                                          Text('call', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
                                                        ],
                                                      )
                                                    ),
                                                  ),
                                                ),
                                              ),
                                                                                  
                   
                                        ],
                                      ),
                                      ),
                              )
                            ),


                            sizedBox(48),


                          ],
                        ),
                      ),
                      
                    ],
                  ),

                  ),),
        
    )
    
    ],
    )
    );
  }







  
  @override
  bool get wantKeepAlive => true; // Indicate to keep the widget alive

}
