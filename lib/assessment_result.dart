import 'dart:convert';
import 'dart:io';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/modal/assessment.dart';
import 'package:psych_app/modal/question.dart';
import 'package:psych_app/modal/result.dart';

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

class AssessmentResult extends StatefulWidget {
  final String resultString;
  final Assessment assessment;
  final Result result;

  AssessmentResult({required this.resultString, required this.assessment, required this.result});

  @override
  AssessmentResultState createState() => AssessmentResultState();
}

class AssessmentResultState extends State<AssessmentResult> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<AssessmentResult> {

// late GlobalKey<FormState> _formKey;

  DateTime today = DateTime.now();
  String? username, collegeId = '';
  bool isLoading = true;
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;
  int offset = 0;
  int year = 0;
  // bool refreshQR = false;
  String universityId= '', role = '', type = '', branch = '', campusId = '', course = '', gcmRegId = '';

  List<Result> resultsList = [];
  String emptyStateMsg = '';
  bool showCreateCTA = true;
  int marks = 0;

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
    // super.initState();
    
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
        emptyStateMsg = 'Loading securely. Please wait...';
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

   // record the result of the user
   closeAssessment(context);
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
              child:
      SafeArea(

        child: 
        
      
        Builder(builder: (context) => 
         SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
        
              // Container(
              //   margin: EdgeInsets.all(16),
              //   child: 
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
                    
              //       children: [ 
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //           Text(widget.assessment.title!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.displaySmall)), 
                        
              //         ],),
                        
              //           // sizedBox(8),
              //           // Text(widget.assessment.title2!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium), textAlign: TextAlign.center,), 
              //           // sizedBox(8)
              //         ],
              //       ),
              // ),

              Container(
                    
                    margin: const EdgeInsets.all(16),
                    child:  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        
                        // Text('Self Assessments', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                        Expanded(child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ 
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              Text(widget.assessment.title!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                            ],),
                              // sizedBox(8)
                            ],
                          ),),
                          InkWell(
                          onTap: () => 
                          // show dialog to confirm exit
                          Navigator.pop(context)
                        ,
                        child: Container(
                              padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                              child: Icon(PhosphorIconsBold.x),
                          ),
                        ),

                      ],
                    ),
                  
              ),
              
        
            (widget.result.title!.length > 1) ? Container(
              // decoration: BoxDecoration(
              //   // color: Color(0xFFFFFFFF),
              //   borderRadius: BorderRadius.circular(10),
              //   boxShadow: const [
              //     BoxShadow(
              //       // color: Colors.black26,
              //       // color: Color(0xFF080B23),
              //       offset: Offset(0.0, 0.0),
              //       blurRadius: 24.0,
              //       spreadRadius: 0.3,
              //     ),
              //   ]
              // ),
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        
                        Text('Result', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center, ), 
                        Text(widget.result.title!, style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displayMedium, color: Palette.black), textAlign: TextAlign.center, ), 
                        
                      ],
                    ),
                  ]
                ),
            ):sizedBox(0),


            sizedBox(16),

            Container(
              decoration: BoxDecoration(
                color: Color(0x66FFE6E3),
                border: Border.all(color: Color(0xFFFFE6E3)), 
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCFFE6E3),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Connect with Psychologist', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                        MaterialButton(
                          child: Text("Schedule", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Palette.white)),
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                          color: Palette.black,
                          textColor: Palette.white,
                          splashColor: Palette.white,
                          colorBrightness: Brightness.light,
                          shape: const StadiumBorder(),
                          onPressed: () {
                            
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentNew()));
                            // Navigator.pop(context);
                          },
          
                        )
                      ],
                    ),
                  ]
                ),
              ),

            sizedBox(4),

            Container(
              decoration: BoxDecoration(
                color: Color(0x66FFCEBF),
                border: Border.all(color: Color(0xFFFFCEBF)), 
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCFFCEBF),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Resources', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                        MaterialButton(
                          child: Text("View", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Palette.white)),
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                          color: Palette.black,
                          textColor: Palette.white,
                          splashColor: Palette.white,
                          colorBrightness: Brightness.light,
                          shape: const StadiumBorder(),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ]
                ),
              ),
              
            sizedBox(16),

            (widget.result.message1!.length > 1) ? Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
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
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.result.message1!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                      ],
                    ),
                  ]
                ),
            ) : sizedBox(0),

            sizedBox(4),

            (widget.result.message2!.length > 1) ? Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
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
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.result.message2!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                      ],
                    ),
                  ]
                ),
            ) : sizedBox(0),
              

            sizedBox(16),
                
            Container(
                alignment: Alignment.center,
                child: MaterialButton(
                        child: Text("Close", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge)),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        color: Palette.appBackgroundSolitude,
                        textColor: Palette.black,
                        splashColor: Palette.textShade2,
                        colorBrightness: Brightness.light,
                        shape: const StadiumBorder(),
                        onPressed: () {
                          
                          
                          Navigator.pop(context);
                        },
        
                      )
                // Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)), 
              ),
           
                   
          ],),
         )
        ),
        
      )
        )
            ]
        )
    );
  }

//  Future<void> _refreshList() async {
//     // Add your refresh logic here, e.g. fetching new data from a server
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() {
//         isDataAvailable = true;
//       });
//     getAssessmentResultData();
//     // getOfficialDates();
//   }

  // 1 role – SuperAdmin / PAdmin / Student
  // 2 answerId 
  // 3 campusId - SVECW or All
  // 4 collegeId - Super33
  // 5 assessmentId
  // 6 answers
  // 7 resultId
  // close request
  void closeAssessment(BuildContext context) async {

    setState(() {
      isClosing = true;
    });
    // query parameters    
    Map<String, String> queryParams = {
      // "appointmentId":appointmentId,
      };

    var A = randomString("A");

    // API call
    //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.answers}${APIUrls.pass}/$role/$A/$campusId/$collegeId/${widget.assessment.assessmentId}/${widget.resultString}/${widget.result.resultId}", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(utf8.decode(result.bodyBytes));
    // var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // showToast(context, 'Your assessment is saved!',Constants.success);
        
    }
    else {
      // show the error msg
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error occured. Please try later!'), duration: Duration(seconds: 2),));
    showToast(context, jsonObject['message'],Constants.error);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
}
