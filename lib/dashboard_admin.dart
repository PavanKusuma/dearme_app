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

class DashboardAdmin extends StatefulWidget{
  const DashboardAdmin({Key? key}) : super(key: key);

  @override
  DashboardAdminState createState() => DashboardAdminState();
}

class DashboardAdminState extends State<DashboardAdmin> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

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
     super.build(context);   
    // get the selected theme
    // get the selected theme
    
    return Scaffold(
// backgroundColor: Color(0xFF080B23),
      body: SafeArea(
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

                            // (role.toLowerCase()!= Constants.issuer.toLowerCase() && profileUpdated != 0) ? 
                            InkWell(
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => Schedule())),
                              // onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => GreetUser())),
                              // onTap: () => scheduleBottomSheet(context, scheduleList),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Container(child:
                                
                                Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                              
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      // color: Palette.appBackgroundSolitude,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                          gradient: const LinearGradient(
                                              colors: [
                                                // Color(0xFFFFC7E2),
                                                // Color(0xFFFAC6BD),
                                                 Color(0xFF8E2DE2), // Start color of the globe
                                                 Color(0xFF4A00E0)
                                              ],
                                              begin: FractionalOffset(0.0, 0.0),
                                              end: FractionalOffset(1.0, 0.0),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  offset: const Offset(1.0, 1.0),
                                                  blurRadius: 12.0,
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
                                            Text('${getGreeting()}, $username', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600, color: Colors.white)),
                                            sizedBox(16),
                                            Text(DateFormat('EEEE', 'en_US').format(getDate(now.toString())), style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, fontWeight: FontWeight.w600, color: Colors.white)),
                                            sizedBox(4),
                                            // styledText(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), Constants.header3, Constants.lightbg),
                                            Text(DateFormat('d MMM, y', 'en_US').format(getDate(now.toString())), style: GoogleFonts.poppins(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: 18, fontWeight: FontWeight.w600, color: Palette.white) ),

                                            
                                          ],
                                        ),),
                                        // AnimatedContainer(duration: Duration(milliseconds: 300),
                                        // width: _bigger ? 20: 100,
                                        // child:   SvgPicture.asset('assets/icon/schedule_2.svg', width: 100,
                                        //       height: 100,allowDrawingOutsideViewBox: true,),
                                        // ),
                                        (mediaCount != 0) ? 
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Palette.red.withOpacity(0.4),
                                                  offset: const Offset(0.0, 0.0),
                                                  blurRadius: 14.0,
                                                  spreadRadius: 0.3,
                                                ),
                                              ],
                                              // border: Border.all(color: Palette.black, width: 2.0),
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(userImage),
                                              ),
                                            ),
                                          ) : sizedBox(0),
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
                           

                         
                            
                            // show search student option for admins
                           Container(
                                height: 250,
                                margin: const EdgeInsets.fromLTRB(16,0,16,8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        // color: Color(0xFF080B23),
                                        offset: const Offset(0.0, 0.0),
                                        blurRadius: 24.0,
                                        spreadRadius: 0.3,
                                      ),
                                    ]
                                  ),
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      // padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    decoration: const BoxDecoration(),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                       Text('Mood dashboard', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600)),
                                          outingDataLoader ? const AppProgress(height: 20, width: 20,) : sizedBox(0),
                                        ],
                                      ),
                                      ),
                                      sizedBox(32),
                                      Image.asset('assets/moodmetrics.webp', width: 150, height: 150)
                                      
                          ],
                        ),
                            )
                            ,
                            

                             sizedBox(16),
                             Text('How is your mood today!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70), textAlign: TextAlign.center,), 
                             
                            
                            //  Center(
                            //     child:  Sphere(),
                            //   ),
                            //  Center(
                            //     child:  VibratingImage(),
                            //   ),
                              sizedBox(48),
                             Container(
                              alignment: Alignment.center,
                              child: Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.white70)), 
                            ),

                            
                            sizedBox(48),


                          ],
                        ),
                      ),
                      
                    ],
                  ),

                  ),),
        
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
