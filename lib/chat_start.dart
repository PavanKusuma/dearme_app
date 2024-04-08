import 'dart:convert';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/chat_detail.dart';
import 'package:psych_app/modal/appointment.dart';

import 'package:psych_app/util/appheader1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/appointment_new.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:http/http.dart' show get;
import 'package:psych_app/util/divider.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/progress.dart';
import 'package:psych_app/util/show_toast.dart';
// import 'package:psych_app/util/show_toast.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/utils.dart';
import 'package:psych_app/util/verticalline.dart';
import 'dart:typed_data';



abstract class AnimationControllerState<T extends StatefulWidget>
    extends State<T> with SingleTickerProviderStateMixin {
  AnimationControllerState(this.animationDuration);
 
  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);
 
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class ChatStart extends StatefulWidget {
  const ChatStart({Key? key}) : super(key: key);

  @override
  ChatStartState createState() => ChatStartState();
}

class ChatStartState extends State<ChatStart> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<ChatStart> {

// late GlobalKey<FormState> _formKey;

  DateTime today = DateTime.now();
  ScrollController? scrollController;
  String? username, collegeId = '';
  bool isLoading = true;
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;
  int offset = 0;
  int year = 0;
  // bool refreshQR = false;
  String universityId= '', role = '', type = '', branch = '', campusId = '', course = '', gcmRegId = '';

  List<Appointment> list = [];
  List<Appointment> oldList = [];
  String emptyStateMsg = '';
  bool showCreateCTA = true;

  Animation<double>? _animation;

  // audio element to play sound
  AudioPlayer player = AudioPlayer();
  late AnimationController _animationController;

  // connection status
  bool connectionStatus = true;
  bool first = true;

  @override
  void initState(){

  super.initState();
  // _formKey = GlobalKey();

// print(Provider.of<SharedState>(context).isDataLoaded);
    getUserData();

    
    _animationController = AnimationController(duration: const Duration(seconds: 1),vsync: this,);
    _animationController.repeat();
    
  }

   @override
  void dispose() {
    
    // _formKey.currentState?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void getUserData() async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // get the userObjectId from storage
    if(preferences.containsKey(Constants.username)){
      
      
      setState(() {
        emptyStateMsg = 'Fetching your data securely. Please wait...';
        universityId = preferences.getString(Constants.universityId)!;  
        username = preferences.getString(Constants.username)!;
        collegeId = preferences.getString(Constants.collegeId)!;
        role = preferences.getString(Constants.role)!;  
        type = preferences.getString(Constants.type)!;  
        branch = preferences.getString(Constants.branch)!;
        campusId = preferences.getString(Constants.campusId)!;
        course = preferences.getString(Constants.course)!;
        gcmRegId = preferences.getString(Constants.gcmRegId)!;
        year = preferences.getInt(Constants.year)!;


        // assign the default selected branch
        branch = branch.split(',')[0];
        
      });
      
    }

   
  }



  @override
  Widget build(BuildContext context){
  
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
              child:  SafeArea(

        child: 
        
      
        Builder(builder: (context) => Container(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
            //   children: [ 
            //       AppHeader1('Appointments', 'All your appointments at one place', 0, connectionStatus),
                  
            //       // IconButton(
            //       //   onPressed: () => 
            //       //     Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentsHistory())),
            //       //   iconSize: 36.0,
            //       //   icon: Icon(PhosphorIconsRegular.clockCounterClockwise,color: Palette.textShade1,size: 24.0,),
            //       //   color: Palette.primary,
            //       // )
            //     ],
            //   ),

              Container(
                margin: const EdgeInsets.all(16),
                child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Anonymous Chat', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                      ],),
                        
                        sizedBox(8),
                        Text('Reach out for help', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],
                    ),
              ),



    
                Expanded(
                  // child: list.isEmpty ? 
                  child: Container(
                            padding: EdgeInsets.all(24),
                            // decoration: BoxDecoration(
                            //         color: const Color(0x66FFFFFF),
                            //         border: Border.all(color: const Color(0xFFFFFFFF)),
                            //         // color: Color(0xFFFFFFFF),
                            //         borderRadius: BorderRadius.circular(10),
                            //         boxShadow: const [
                            //           BoxShadow(
                            //             // color: Colors.black26,
                            //             color: Color(0xCCFFFFFF),
                            //             // color: Color(0xFF080B23),
                            //             offset: Offset(0.0, 0.0),
                            //             blurRadius: 24.0,
                            //             spreadRadius: 0.3,
                            //           ),
                            //         ]
                            //       ),
                                  child:  
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // loader while fetching data
                              // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                            const Icon(PhosphorIconsLight.lock, size: 64, color: Color(0xFF6302E5)),
                            sizedBox(16),
                            Text('Your conversation is very secure!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.bold,color: Colors.black)), 
                            sizedBox(16),
                            Text('Only accessed by psychology professionals to provide you help.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge,  color: Colors.black87), textAlign: TextAlign.center,),
                            sizedBox(16),
                            sizedBox(16),

                            Container(
                              margin: EdgeInsets.all(16),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF6302E5),
                                    // primary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatUser()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 14.0,
                                    ),
                                    child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                                                Icon(PhosphorIconsRegular.chatsCircle, color: Colors.white, size: 24,),
                                                const SizedBox(width: 8,),
                                                Text('Start conversation', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                              ],
                                          )
                                  ),
                                ),
                            ),
                            
                            // InkWell(
                            //   onTap: () => {
                            //         // verifyToCreate(context)
                            //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatUser())),
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.all(16),
                            //     decoration: BoxDecoration(
                            //             color: const Color(0x66FFFFFF),
                            //             border: Border.all(color: const Color(0xFFFFFFFF)),
                            //             // color: Color(0xFFFFFFFF),
                            //             borderRadius: BorderRadius.circular(50),
                            //             boxShadow: const [
                            //               BoxShadow(
                            //                 // color: Colors.black26,
                            //                 color: Color(0xCCFFFFFF),
                            //                 // color: Color(0xFF080B23),
                            //                 offset: Offset(0.0, 0.0),
                            //                 blurRadius: 24.0,
                            //                 spreadRadius: 0.3,
                            //               ),
                            //             ]
                            //           ),
                            //           child:  Row(
                            //                   mainAxisAlignment: MainAxisAlignment.center,
                            //                   children: [
                            //                     // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                            //                     Icon(PhosphorIconsRegular.chatsCircle, color: Colors.pink, size: 18,),
                            //                     const SizedBox(width: 8,),
                            //                     Text('Start conversation', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.pink)),
                            //                   ],
                            //               )
                            //   ),
                            // )
                            
                      ],)
                  )
                     


                      
                
            ),
            (list.isNotEmpty || oldList.isNotEmpty) ? Container(
                alignment: Alignment.center,
                child: Text('Pull down to refresh!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)), 
              ) : sizedBox(0),
           
                   
          ],), 


        ),
        ),
        
      )
            )
          ])
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
}
