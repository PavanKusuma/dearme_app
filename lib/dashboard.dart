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
import 'package:psych_app/emergency_call.dart';
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
// import 'package:code_scan/code_scan.dart';

class Dashboard extends StatefulWidget{
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

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
  late AnimationController _animationController;
  late AnimationController _animationController2;
  double _scale = 1.0;

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

    _animationController = AnimationController(duration: const Duration(seconds: 1),vsync: this,);
    _animationController.repeat();

    _animationController2 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }
void _animateScale() {
    if (_animationController2.isCompleted) {
      _animationController2.reverse();
    } else {
      _animationController2.forward();
    }
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
      getAffirmation();

      // if(preferences.containsKey(Constants.pendingPay)){
      //   pendingPay = preferences.getBool(Constants.pendingPay)!;
      // }
  }


    Future<void> getAffirmation() async {
        try {
          Random random = Random();
          final jsonData = await loadJsonFromAssets('assets/affirmations.json');
          setState(() {
            List<dynamic> mixedList = jsonData[Constants.affirmations];
            List<String> selectedAffirmations = mixedList.whereType<String>().toList();
            selectedAffirmation = selectedAffirmations[random.nextInt(selectedAffirmations.length)];
            // selectedFeelings = jsonData['Happy'] as List<String>; // Assuming a list of strings
          });
        } catch (error) {
          print('Error loading JSON: $error');
        }
      }

      Future<Map<String, dynamic>> loadJsonFromAssets(String assetsPath) async {
      final String jsonString = await rootBundle.loadString(assetsPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    }

 

  // get food stats
  void bookAppointment() async {
      
      // check internet connection
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
    _scale = 1 + _animationController2.value;
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
                margin: const EdgeInsets.all(32),
                child: 
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            
                            children: [ 
                                Text('Dear Me', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                                // sizedBox(8),
                                // Text('Your data is encrypted and is private', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                                // sizedBox(8)
                              ],
                          ),
                          InkWell(
                              
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyCalling())),
                              child: Container(
                                      // padding: const EdgeInsets.all(16),
                                      child: const Icon(PhosphorIconsRegular.phoneCall, color: Colors.red, size: 36,),
                            ),
                          ),
                          ],
                        ),
                      ),
                            // sizedBox(16),
                            
                            // (role.toLowerCase()!= Constants.issuer.toLowerCase() && profileUpdated != 0) ? 
                            InkWell(
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Schedule())),
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => GreetUser())),
                              // onTap: () => scheduleBottomSheet(context, scheduleList),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Container(child:
                                
                                Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                              
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      
                                      // decoration: const BoxDecoration(
                                      //   borderRadius: BorderRadius.all(Radius.circular(8)),
                                      //     gradient: LinearGradient(
                                      //         colors: [
                                      //            Color(0xFF8E2DE2), // Start color of the globe
                                      //            Color(0xFF4A00E0)
                                      //         ],
                                      //         begin: FractionalOffset(0.0, 0.0),
                                      //         end: FractionalOffset(1.0, 0.0),
                                      //         stops: [0.0, 1.0],
                                      //         tileMode: TileMode.clamp),
                                      //         boxShadow: [
                                      //           BoxShadow(
                                      //             color: Colors.black26,
                                      //             offset: Offset(1.0, 1.0),
                                      //             blurRadius: 12.0,
                                      //             spreadRadius: 0.3,
                                      //           ),
                                      //         ]
                                      //   ),

                                       decoration: BoxDecoration(
                                          color: Color(0x66FFFFFF),
                                          border: Border.all(color: Color(0xFFDDDDDD)),
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
                                      child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded( child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            
                                            sizedBox(8),
                                            // Text('Dear me,', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                                            // Icon(PhosphorIconsFill.quotes, color: Colors.black38, size: 36 ),
                                            // sizedBox(2),
                                            // Text('Dear Me,', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                                            // Text('${getGreeting()}!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                                            // sizedBox(16),
                                            Text(selectedAffirmation, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                                            
                                            // Text('You will be alright. Kindly take good care of yourself. You can find help here.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.normal, color: Palette.black)),
                                            
                                            
                                            // Text(DateFormat('EEEE', 'en_US').format(getDate(now.toString())), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, fontWeight: FontWeight.normal, color: Colors.black45)),
                                            // sizedBox(4),
                                            // // styledText(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), Constants.header3, Constants.lightbg),
                                            // Text(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black45) ),

                                            
                                          ],
                                        ),),
                                        // AnimatedContainer(duration: Duration(milliseconds: 300),
                                        // width: _bigger ? 20: 100,
                                        // child:   SvgPicture.asset('assets/icon/schedule_2.svg', width: 100,
                                        //       height: 100,allowDrawingOutsideViewBox: true,),
                                        // ),
                                        // (mediaCount != 0) ? 
                                        //   Container(
                                        //     margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        //     width: 80,
                                        //     height: 80,
                                        //     decoration: BoxDecoration(
                                        //       boxShadow: [
                                        //         BoxShadow(
                                        //           color: Palette.red.withOpacity(0.4),
                                        //           offset: const Offset(0.0, 0.0),
                                        //           blurRadius: 14.0,
                                        //           spreadRadius: 0.3,
                                        //         ),
                                        //       ],
                                        //       // border: Border.all(color: Palette.black, width: 2.0),
                                        //       shape: BoxShape.circle,
                                        //       image: DecorationImage(
                                        //         fit: BoxFit.cover,
                                        //         image: NetworkImage(userImage),
                                        //       ),
                                        //     ),
                                        //   ) : sizedBox(0),
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
                            //// MOOD MONITOR
                            ////
                            InkWell(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodMonitor())),
                              
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
                                          Color(0xFFF2EBD2), // Start color of the globe
                                          Color(0xFFF9EBB8), // End color of the globe
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
                                  height: MediaQuery.of(context).size.height/3,
                                      // padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    decoration: const BoxDecoration(
                                      // color: ui.Color(0x22007E86),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    const SizedBox(width: 32,),
                                        // Expanded( child: 
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                                  Text('Mood Monitor', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA01575F))),
                                                  Text('How are you doing this ${getGreeting1()}?', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: ui.Color(0xFF01575F)), textAlign: TextAlign.center,),
                                                  sizedBox(8),
                                                  Text('Check in now', style: GoogleFonts.dmSans(fontSize: 20, color: ui.Color(0xFF01575F))),
                                              
                                              // Column(
                                              //   crossAxisAlignment: CrossAxisAlignment.center,
                                              //   mainAxisSize: MainAxisSize.min,
                                              //   children: [
                                              //     Text('Mood Monitor', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA01575F))),
                                              //     Text('How are you doing this ${getGreeting1()}?', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: ui.Color(0xFF01575F)), textAlign: TextAlign.center,),
                                              //     sizedBox(8),
                                              //     Text('Check in now', style: GoogleFonts.dmSans(fontSize: 20, color: ui.Color(0xFF01575F))),
                                              // ],
                                              // ),
                                              
                                              // sizedBox(8),
                                              // GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black38), textAlign: TextAlign.center,), 
                                              
                                            ],
                                          ),

                                          InkWell(
                                                // onTap: () => createChat(),
                                                child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: const BoxDecoration(
                                                      // color: Palette.blue,
                                                      color: ui.Color(0xFFFFC900),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: FadeTransition(
                                                      opacity: CurvedAnimation(
                                                        parent: _animationController,
                                                        curve: Curves.easeInOut,
                                                        ),
                                                      child: Icon(PhosphorIconsRegular.plus, color: Color(0xFF000000), size: 36 ),
                                                    ),
                                                  ),
                                                // Container(
                                                //   padding: EdgeInsets.fromLTRB(16, 8, 14, 8),
                                                  
                                                //   decoration: BoxDecoration(
                                                //       // color: Palette.blue,
                                                //       color: ui.Color(0xFFFFC900),
                                                //       shape: BoxShape.circle,
                                                //     ),
                                                  
                                                //     alignment: Alignment.center,
                                                //     child: Icon(PhosphorIconsRegular.plus, color: Color(0xFF000000), size: 36 ),
                                                // ),

                                              )
                                        // ),

                                          
                                        ],
                                      ),
                                      ),
                              )
                            ),
                            
                            ////
                            //// MOOD METRICS
                            ////
                            InkWell(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodMonitorMetrics())),
                              
                              child: Container(
                                // height: 250,
                                margin: const EdgeInsets.fromLTRB(16,0,16,8),
                                padding: const EdgeInsets.all(32),
                                 decoration: BoxDecoration(
                                  color: Color(0xFFDEED7E),
                                    // color: ui.Color(0xFFE4FDFF),
                                    // gradient: const LinearGradient(
                                    //     begin: Alignment.topCenter,
                                    //     end: Alignment.bottomCenter,
                                    //     colors: [
                                    //       Color(0xFFBBD900), // Start color of the globe
                                    //       Color(0xFFEBFD7E), // End color of the globe
                                    //     ],
                                    //   ),
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
                                              Image.asset('assets/moodmonitoring.webp', scale: 2,),
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
                                              Text('Get insights into how you are doing.', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA01575F))),
                                              // GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black38), textAlign: TextAlign.center,), 
                                            ],
                                          ),
                                        ),

                                          
                                        ],
                                      ),
                                      ),
                              )
                            ),
                            
                            ////
                            //// LIBRARY
                            ////
                            sizedBox(8),
                            InkWell(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DearMeLibrary())),
                              
                              child: Container(
                                // height: 250,
                                margin: const EdgeInsets.fromLTRB(16,0,16,8),
                                padding: const EdgeInsets.all(32),
                                 decoration: BoxDecoration(
                                  color: ui.Color(0xFFFFEE8D),
                                    // color: ui.Color(0xFFFEFBE6),
                                    // gradient: const LinearGradient(
                                    //     begin: Alignment.topCenter,
                                    //     end: Alignment.bottomCenter,
                                    //     colors: [
                                    //       Color(0xFFFED601), // Start color of the globe
                                    //       Color(0xFFFFE891), // End color of the globe
                                    //     ],
                                    //   ),
                                    // border: Border.all(color: const Color(0x44867100)),
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text('Library', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: ui.Color(0xFF5E4B00))),
                                              sizedBox(8),
                                              
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                              Text('Emotions & Feelings', style: GoogleFonts.dmSans(fontSize: 20, color: ui.Color(0xFF5E4B00))),
                                              ],
                                              ),
                                              
                                              sizedBox(8),
                                              Text('Learn more and care about your well-being', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA5E4B00))),
                                              // GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black38), textAlign: TextAlign.center,), 
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 32,),
                                        Expanded( child: 
                                          Column(
                                            children: [
                                              Image.asset('assets/library.webp', scale: 2,),
                                            ]
                                          ),
                                        ),

                                          
                                        ],
                                      ),
                                      ),
                              )
                            ),
                            
                            ////
                            //// SELF ASSESSMENTS
                            ////
                            sizedBox(8),
                            InkWell(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Assessments())),
                              
                              child: Container(
                                // height: 250,
                                margin: const EdgeInsets.fromLTRB(16,0,16,8),
                                padding: const EdgeInsets.all(32),
                                 decoration: BoxDecoration(
                                  color: ui.Color(0xFFE3CFFF),
                                    // color: ui.Color(0xFFEBDCFF),
                                    // border: Border.all(color: const Color(0x446302E5)),
                                    // gradient: const LinearGradient(
                                    //     begin: Alignment.topCenter,
                                    //     end: Alignment.bottomCenter,
                                    //     colors: [
                                    //       Color(0xFFD2B1FF), // Start color of the globe
                                    //       Color(0xFFC890FF), // End color of the globe
                                    //     ],
                                    //   ),
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
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                       
                                        outingDataLoader ? const AppProgress(height: 20, width: 20,) : sizedBox(0),
                                        // Expanded( child: 
                                          Column(
                                            children: [
                                              Image.asset('assets/assessments.webp', scale: 2,),
                                            ]
                                          ),
                                        // ),
                                        // Expanded( child: 
                                        sizedBox(32),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text('Self Assessments', style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: ui.Color(0xFF6302E5))),
                                              sizedBox(8),
                                              
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                              Text('Your well-being is your priority', style: GoogleFonts.dmSans(fontSize: 20, color: ui.Color(0xFF6302E5))),
                                              ],
                                              ),
                                              
                                              sizedBox(8),
                                              Text('Access quick tools & quizes to assess yourself', style: GoogleFonts.dmSans(fontSize: 16, color: ui.Color(0xAA6302E5))),
                                              // GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black38), textAlign: TextAlign.center,), 
                                            ],
                                          ),
                                        // ),
                                        

                                          
                                        ],
                                      ),
                                      ),
                              )
                            ),
                            


                            //   sizedBox(48),
                            //  Container(
                            //   alignment: Alignment.center,
                            //   child: Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70)), 
                            // ),

                            
                            sizedBox(48),


                          ],
                        ),
                      ),
                      
                    ],
                  ),

                  ),),
        
    )
    )
    ],
    )
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


void _selectFoodDate(BuildContext context){
    showModalBottomSheet(
      
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: true,
      useSafeArea: true,
      
      elevation: 20.0,
      context: context, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0)
        )
      ),
      backgroundColor: Theme.of(context).cardColor,
      constraints: BoxConstraints(
                      // maxHeight: 400.0, // Set the maximum height
                      maxWidth: MediaQuery.of(context).size.width - 20.0
                    ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context){
        return 
            SingleChildScrollView(child: 
            Container(
              margin: const EdgeInsets.all(16),
              // height: 300, // Adjust the height as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    
                    child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Select a date', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.headline5)),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: 
                            InkWell(
                              onTap: () => {
                                    Navigator.pop(context)
                                    },
                              child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: Palette.textShade1, size: 24,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  sizedBox(16),
                  SfDateRangePicker(
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.single,
                    minDate: DateTime.now(),
                    initialSelectedDate: DateTime.parse(foodStatDate),
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      // Handle the selected date range

                      // print('Clicked');
                      // print(args);
                      // print(args.value);
                      // print(DateFormat('yyyy-MM-dd', 'en_US').format(args.value));

                      // set the date to call the stats again
                      setState(() {
                        foodStatDate = DateFormat('yyyy-MM-dd', 'en_US').format(args.value).toString();
                      },);
                    },
                  ),
                 MaterialButton(
                      padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                      color: Palette.primary,
                      splashColor: Palette.textShade2,
                      colorBrightness: Brightness.dark,
                      elevation: 2,
                      highlightElevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onPressed: () {
                        // if(phoneNumberController.text.length == 10){
                        //   setState(() => {
                        //     phoneErrorMsg = ''  
                        //   });
                        //   updatePhoneNumber(context, phoneNumberController.text);
                        // }
                        // else {
                        //   setState(() => {
                        //     phoneErrorMsg = 'Enter full phone number'  
                        //   });
                        // }
                        // onSubmit(context);
                          // getFoodStats();
                          Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.paperPlane(PhosphorIconsStyle.regular), size: 12,),
                          const SizedBox(width: 8,),
                          Text('Select date', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText1, color: Palette.white),),
                        ],
                      ) 
                    ),
              ],)
              
            )
        );
        

    });
  }




void _selectAppointmentDate(BuildContext context){
    showModalBottomSheet(
      
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: true,
      useSafeArea: true,
      
      elevation: 20.0,
      context: context, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0)
        )
      ),
      backgroundColor: Theme.of(context).cardColor,
      constraints: BoxConstraints(
                      minHeight: 400.0, // Set the maximum height
                      maxWidth: MediaQuery.of(context).size.width - 20.0
                    ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context){
        return 
            SingleChildScrollView(child: 
            Container(
              margin: const EdgeInsets.all(16),
              // height: 300, // Adjust the height as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    
                    child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Book appointment', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: 
                            InkWell(
                              onTap: () => {
                                    Navigator.pop(context)
                                    },
                              child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: Colors.black45, size: 24,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  sizedBox(32),
                 Container(
                    decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    // boxShadow: [
                    //     BoxShadow(
                    //       color: Theme.of(context).shadowColor,
                    //       offset: const Offset(0.0, 0.0),
                    //       blurRadius: 32.0,
                    //       spreadRadius: 0.3,
                    //     ),
                    //   ]
                    ),
                    
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium),
                      controller: descriptionController,
                      minLines: 6,
                      maxLines: 6,
                      // maxLength: 120,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: InputBorder.none,
                        
                        hintText: 'Type your reason for appointment',
                          ),
                      validator: (value) { // validator function is called on calling form validate() method
                        if (value!.isEmpty) {
                          return 'Provide reason to proceed';
                        }
                        return null;
                      },
                      //onSaved: (value) => description = value,
                    ),
                  ),
                  sizedBox(32),
                
                    GestureDetector(
                      onTap: () {
                        // Perform action on tap
                        bookAppointment();
                        Navigator.pop(context);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 12.0),
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
                            child: 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.calendarCheck(PhosphorIconsStyle.regular), color: Colors.white,),
                                const SizedBox(width: 8,),
                                Text('Book now'.toUpperCase(), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText1, color: Palette.white, fontWeight: FontWeight.bold),),
                              ],
                            ) 
                    
            // Text('Book now', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)  )
          ),
        ),
      ),
    )
              ],)
              
            )
        );
        

    });
  }
  
  @override
  bool get wantKeepAlive => true; // Indicate to keep the widget alive

}


// class Sphere extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(24),
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade900, Colors.blue.shade500, Colors.blue.shade300],
//               stops: [0.2, 0.5, 0.9],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.shade900.withOpacity(0.8),
//                 offset: Offset(4, 4),
//                 blurRadius: 15,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//           child: VibratingImage(),
//         ),
//         Text('Angry', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70)), 
//       ],
//     );
    
//   }
// }




// class VibratingImage extends StatefulWidget {
//   @override
//   _VibratingImageState createState() => _VibratingImageState();
// }

// class _VibratingImageState extends State<VibratingImage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(0.02, 0.0),
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _animation,
//       child: Container(
//         height: 100, // Set the container size
//         width: 100,
//         child: Image.asset('assets/angry.png'), // Replace with the actual path to your image asset
//       ),
//     );
//   }
// }










/// this is the sequence
/// 

// class VibratingImagesRow extends StatefulWidget {
//   @override
//   _VibratingImagesRowState createState() => _VibratingImagesRowState();
// }

// class _VibratingImagesRowState extends State<VibratingImagesRow> {
//   final ScrollController _scrollController = ScrollController();
//   final int _itemCount = 10; // Number of images in the row

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200, // Height of the row
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         controller: _scrollController,
//         itemCount: _itemCount,
//         itemBuilder: (BuildContext context, int index) {
//           return Center(
//             child: VibratingImage(),
//           );
//         },
//       ),
//     );
//   }
// }

// class VibratingImage2 extends StatefulWidget {
//   @override
//   _VibratingImageState createState() => _VibratingImageState();
// }

// class _VibratingImage2State extends State<VibratingImage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(0.02, 0.0),
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _animation,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Image.asset('assets/angry.png', width: 150, height: 150), // Replace with your image path
//       ),
//     );
//   }
// }















///// row of images
///
///

class VibratingImagesRow extends StatefulWidget {
  @override
  _VibratingImagesRowState createState() => _VibratingImagesRowState();
}

class _VibratingImagesRowState extends State<VibratingImagesRow> {
  final ScrollController _scrollController = ScrollController();
  final int itemCount = 5; // Number of images in the row

  // This function determines if the index is the one in the center of the viewport
  bool isCenter(int index) {
    if (!_scrollController.hasClients) return false;
    final centerOfViewport = _scrollController.position.viewportDimension / 2;
    final startOfItem = (index * 200.0) - 20.0; // Adjusted for centering
    final endOfItem = startOfItem + 120.0;
    final offsetCenter = _scrollController.offset + centerOfViewport;
    return (startOfItem < offsetCenter) && (endOfItem > offsetCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white12,
      height: 200, // Height of the row
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          setState(() {}); // Triggers a rebuild on scroll to update the scaling
          return false;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            final isCentered = isCenter(index);
            return Stack(
              alignment: Alignment.center,
              children: [
                if (isCentered) Sphere(), // Only show the Sphere for the center image
                Transform.scale(
                  scale: isCentered ? 1.0 : 0.6,
                  child: VibratingImage(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Sphere extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade500,
            Colors.blue.shade300,
          ],
          stops: [0.2, 0.5, 0.9],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.8),
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class VibratingImage extends StatefulWidget {
  @override
  _VibratingImageState createState() => _VibratingImageState();
}

class _VibratingImageState extends State<VibratingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0.0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/angry.png', width: 150, height: 150), // Replace with your image path
      ),
    );
  }
}