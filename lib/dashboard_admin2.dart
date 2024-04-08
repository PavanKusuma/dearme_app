import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

// // import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/appointment_new.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/mood_monitor_metrics_admin.dart';
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
// import 'package:code_scan/code_scan.dart';

class DashboardAdmin2 extends StatefulWidget{
  const DashboardAdmin2({Key? key}) : super(key: key);

  @override
  DashboardAdmin2State createState() => DashboardAdmin2State();
}

class DashboardAdmin2State extends State<DashboardAdmin2> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  TextEditingController descriptionController = new TextEditingController();
  ScrollController? scrollController;
  bool isLoading = false;
  bool connectionStatus = true;
  static int year = 0, profileUpdated = 0, mediaCount = 0;
  static String username = '', role='', type='', branch='', collegeId='', userImage='', description='';
  
  String foodStatDate = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now()).toString();
  int visitorsCount = 0;
  DateTime today = DateTime.now();

  bool outingDataLoader = false;
  // int pending = 0, approved =0, issued =0, rejected = 0, returned = 0, inOuting = 0, official = 0;

  bool _bigger = true;
  // academic payment
  bool pendingPay = true;
  
  DateTime now = new DateTime.now();

  @override
  void initState() {
    // get user data
    getUserData();
    

    scrollController = new ScrollController()..addListener(_scrollListener);
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

 

  // get food stats
  void bookAppointment() async {
      
      // check dmSansnet connection
      if(await checkInternetConnectivity()){

        // show the loader
        setState(() {
          connectionStatus = true;
          outingDataLoader = true;
        });

        // query parameters    
        Map<String, String> queryParams = {
          // "offset":"0",
          };

        // API call
        // print("${APIUrls.hostels}${APIUrls.pass}/U3/$foodStatDate");
        print("${APIUrls.newAppointment}${APIUrls.pass}/SSS33/${descriptionController.text}");
        var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.newAppointment}${APIUrls.pass}/SSS33/${descriptionController.text}", queryParams)), headers: {"Accept": "application/json"});
        // print(result.body);
        // get the result body which is JSON
        var jsonString = jsonDecode(result.body); 
        // convert jsonString to Map
        var jsonObject = jsonString as Map; 

        List<Appointment> list1 = [];
        // check if the api returned success
        if(jsonObject['status'] == 200){
          // get the list data from jsonObject
          String msg = jsonObject['message'] as String;
          showToast(context, msg, Constants.success);
          // var circulars = jsonObject['data'] as List;
          // convert to list
          
          // list1 = circulars.map<Appointment>((json) => Appointment.fromJson(json)).toList();
          
        }

        // update the list items and toggle the loading
        setState(() {
          outingDataLoader = false;
          // vFoodList = list1;

        });

      }
      else {
        
        Future.delayed(const Duration(seconds: 5), () {

          bookAppointment();
          
          // set the connection Status variable to false
          setState(() {
            connectionStatus = false;
          });
          
        });
      }
  }


   Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    
    // setState(() {
    //   pending = 0;
    //   approved = 0;
    //   issued = 0;
    //   rejected = 0;
    // });
    await Future.delayed(const Duration(seconds: 2));

    // getRequestStats();
  }


  @override
  Widget build(BuildContext context){
     super.build(context);   
    // get the selected theme
    // get the selected theme
    
    return Scaffold(
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


            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(child: 
              RefreshIndicator(
          onRefresh: _refreshList,
          child: Container(
//        margin: EdgeInsets.all(16.0),
        
                  child: CustomScrollView(

                    slivers: <Widget>[
                      
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            sizedBox(16),
                           

                            Center(
                              child: connectionStatus ? sizedBox(0) : Text('No network detected. Try again later!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, color: Palette.red, fontWeight: FontWeight.bold)),
                            ),
                            Center(
                              child: Text('Dear Me,', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                            ),
                            sizedBox(16),

                            // (role.toLowerCase()!= Constants.issuer.toLowerCase() && profileUpdated != 0) ? 
                            InkWell(
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Schedule())),
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => GreetUser())),
                              // onTap: () => scheduleBottomSheet(context, scheduleList),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                child: Container(child:
                                
                                Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                              
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      // color: Palette.appBackgroundSolitude,

                                      decoration: BoxDecoration(
                                          color: Color(0x66FFFFFF),
                                          border: Border.all(color: Color(0xFFFFFFFF)),
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
                                      // decoration: BoxDecoration(
                                      //   borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      //     gradient: const LinearGradient(
                                      //         colors: [
                                      //           // Color(0xFFFFC7E2),
                                      //           // Color(0xFFFAC6BD),
                                      //            Color(0x668E2DE2), // Start color of the globe
                                      //            Color(0x224A00E0)
                                      //         ],
                                      //         begin: FractionalOffset(0.0, 0.0),
                                      //         end: FractionalOffset(1.0, 0.0),
                                      //         stops: [0.0, 1.0],
                                      //         tileMode: TileMode.clamp),
                                      //         boxShadow: [
                                      //           BoxShadow(
                                      //             // color: Colors.black26,
                                      //             // offset: const Offset(1.0, 1.0),
                                      //             // blurRadius: 12.0,
                                      //             // spreadRadius: 0.3,
                                      //             // color: Colors.black26,
                                      //         color: Color(0xCCFFFFFF),
                                      //         // color: Color(0xFF080B23),
                                      //         offset: Offset(0.0, 0.0),
                                      //         blurRadius: 24.0,
                                      //         spreadRadius: 0.3,
                                      //           ),
                                      //         ]
                                      //   ),
                                      child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded( child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            
                                            sizedBox(8),
                                            Text('${getGreeting()}, $username', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600, color: Colors.black87)),
                                            sizedBox(16),
                                            Text(DateFormat('EEEE', 'en_US').format(getDate(now.toString())), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, fontWeight: FontWeight.w600, color: Colors.black87)),
                                            sizedBox(4),
                                            // styledText(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), Constants.header3, Constants.lightbg),
                                            Text(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87) ),

                                            
                                          ],
                                        ),),
                                        
                                      ],
                                    ),
                                    ),

                                    // This is just temporary
                                    // This is just temporary
                                    // This is just temporary
                                    // sizedBox(16),
                                    
                                  ],
                                )
                              ),
                              ),
                            ),

                         
                          ],
                        ),
                      ),
                      
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                           

                            ////
                            //// MOOD METRICS
                            ////
                            InkWell(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodMonitorMetricsAdmin())),
                              
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
                                          Color(0xFFBBD900), // Start color of the globe
                                          Color(0xFFEBFD7E), // End color of the globe
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
                                      // padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    decoration: const BoxDecoration(
                                      // color: ui.Color(0x22007E86),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                       
                                        outingDataLoader ? const AppProgress(height: 20, width: 20,) : sizedBox(0),
                                        Expanded( child: 
                                          Column(
                                            children: [
                                              Image.asset('assets/moodmetrics.webp'),
                                            ]
                                          ),
                                        ),
                                        const SizedBox(width: 32,),
                                        Expanded( child: 
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text('Mood Metrics', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: ui.Color(0xFF01575F))),
                                              sizedBox(8),
                                              
                                              // Column(
                                              //   crossAxisAlignment: CrossAxisAlignment.start,
                                              //   mainAxisSize: MainAxisSize.min,
                                              //   children: [
                                              // // Text('Track your mood everyday', style: GoogleFonts.dmSans(fontSize: 20, color: ui.Color(0xFF01575F))),
                                              // ],
                                              // ),
                                              
                                              sizedBox(8),
                                              Text('Get insights into how everyone is doing.', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA01575F))),
                                              // GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black38), textAlign: TextAlign.center,), 
                                            ],
                                          ),
                                        ),

                                          
                                        ],
                                      ),
                                      ),
                              )
                            ),
                            

                         
                            
                            

                             sizedBox(16),
                            //  Text('How is your mood today!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70), textAlign: TextAlign.center,), 
                             
                            
                            //  Center(
                            //     child:  Sphere(),
                            //   ),
                            //  Center(
                            //     child:  VibratingImage(),
                            //   ),
                              sizedBox(48),
                             Container(
                              alignment: Alignment.center,
                              child: Text('Pull down to refresh!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70)), 
                            ),

                            
                            sizedBox(48),


                          ],
                        ),
                      ),
                      
                    ],
                  ),

                  ),
                ),
              ),
            )
            // Positioned(
            //   top: (MediaQuery.of(context).size.height/2)-20,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //   alignment: Alignment.center,
            //     // height: MediaQuery.of(context).size.height,
            //     child: 
            //   Column(
            //     children: [
            //         const Text( 'TRUST', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), ),
            //         TypewriterText("Welcome here! \nWe believe that you are the most unique human being ever existed on this planet. \nEverything that you do will help you become the better version of yourself."),
            //         DelayedStart( userExists: userExists,),
            //     ],
            //   ),
            //   )
            // ),
          ],
        ),
      );
  }


  void _scrollListener(){
    if(scrollController!.position.pixels == scrollController!.position.maxScrollExtent){
      startLoader();
    }
  }

  void startLoader(){
    setState((){
      isLoading = !isLoading;
      
      // getCircularData();
    });
  }





  
  @override
  bool get wantKeepAlive => true; // Indicate to keep the widget alive

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