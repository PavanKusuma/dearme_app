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
import 'package:psych_app/chat_detail.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/modal/assessment.dart';
import 'package:psych_app/modal/feeling.dart';
import 'package:psych_app/modal/feeling_detail.dart';
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
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:flutter_html/flutter_html.dart';


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

class LibraryFeelingDetail extends StatefulWidget {
  final String feeling;

  LibraryFeelingDetail({required this.feeling});

  @override
  LibraryFeelingDetailState createState() => LibraryFeelingDetailState();
}

class LibraryFeelingDetailState extends State<LibraryFeelingDetail> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<LibraryFeelingDetail> {

// late GlobalKey<FormState> _formKey;

  DateTime today = DateTime.now();
  String? username, collegeId = '';
  bool isLoading = true;
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;
  int offset = 0;
  String description2 = '';
  List<String> description3 = [];
  List<String> links = [];
  
  String universityId= '', role = '', type = '', branch = '', campusId = '', course = '', gcmRegId = '';

  List<FeelingDetail> list = [];
  List<FeelingDetail> oldList = [];
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
        


        // assign the default selected branch
        branch = branch.split(',')[0];
        
      });
      
    }

   // record the result of the user
  //  closeAssessment(context);
    getFeelingData();
  }

  void getFeelingData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
        isLoading = true;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.appointments}${APIUrls.pass}/$role/All/$offset/$userObjectId/$campusId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.feelings}${APIUrls.pass}/$role/$offset/FEELING/${widget.feeling}", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<FeelingDetail> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<FeelingDetail>((json) => FeelingDetail.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              list.clear();
              oldList.clear();
              list.addAll(list1);

              description2 = list1[0].description2!;
              description3 = list1[0].description3!.split('<DearMe>');
              links = list1[0].links!.split('<DearMe>');

              isLoading = false;
              isDataAvailable = true;
            });
          }
          else {
            // no requests
            setState(() {
              emptyStateMsg = 'Loading...';
              isLoading = false;
              isDataAvailable = false;
            });
          }

        }
        else {
          // no requests
          setState(() {
            emptyStateMsg = 'Loading...';
            isLoading = false;
            isDataAvailable = false;
          });
        }

      
      }
      else {
          // no requests
          setState(() {
            emptyStateMsg = 'Loading...';
            isLoading = false;
            isDataAvailable = false;
          });
        }
    }
    else {
        Future.delayed(const Duration(seconds: 2), () {

          // this is to check for retrying only once more. Else it will end the loop
          if(connectionStatus)
          {
            getFeelingData();
            // print('Again trying');
          
            // set the connection Status variable to false
            setState(() {
              connectionStatus = false;
              isLoading = false;
              isDataAvailable = false;
            });
          }
        });
      }
  }
  




  @override
  Widget build(BuildContext context){
    final text = "It is great <b>texty</b> for this <i>sentence</i>";

// Example HTML string
    // String htmlString = "This is <b>bold</b> text and this is <b>another bold</b> text.";

    // // Function to convert HTML string to TextSpan for RichText
    // TextSpan htmlToTextSpan(String html) {
    //   List<TextSpan> spans = [];
    //   final RegExp exp = RegExp(r'(<b>.*?<\/b>)|([^<]+)');
    //   exp.allMatches(html).forEach((match) {
    //     final String? boldText = match.group(1);
    //     final String? normalText = match.group(2);
    //     if (boldText != null) {
    //       final String cleanText = boldText.replaceAll(RegExp(r'<\/?b>'), '');
    //       spans.add(TextSpan(text: cleanText, style: TextStyle(fontWeight: FontWeight.bold)));
    //     } else if (normalText != null) {
    //       spans.add(TextSpan(text: normalText));
    //     }
    //   });
    //   return TextSpan(children: spans, style: TextStyle(color: Colors.black));
    // }


    String htmlString = "This is <b>bold</b> text, this is <i>italic</i> text, and this is <b><i>bold and italic</i></b> text.";

    // Function to convert HTML string to TextSpan for RichText
    TextSpan htmlToTextSpan(String html) {
      List<TextSpan> spans = [];
      final RegExp exp = RegExp(r'(<b>.*?<\/b>)|(<i>.*?<\/i>)|([^<]+)');
      exp.allMatches(html).forEach((match) {
        final String? boldText = match.group(1);
        final String? italicText = match.group(2);
        final String? normalText = match.group(3);
        
        if (boldText != null) {
          final String cleanText = boldText.replaceAll(RegExp(r'<\/?b>'), '');
          spans.add(TextSpan(text: cleanText, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, fontWeight: FontWeight.bold)));
        } else if (italicText != null) {
          final String cleanText = italicText.replaceAll(RegExp(r'<\/?i>'), '');
          spans.add(TextSpan(text: cleanText, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, fontStyle: FontStyle.italic)));
        } else if (normalText != null) {
          spans.add(TextSpan(text: normalText));
        }
      });
      return TextSpan(children: spans, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium));
    }
    
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
                    // Colors.pink.withOpacity(0.5),
                    // Colors.pink.withOpacity(0.3),
                    // Colors.grey.withOpacity(0.3),
                    // Colors.black45.withOpacity(0.3),
                    // Colors.purple.withOpacity(0.3),

                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0),
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
          padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                InkWell(
                  onTap: () => 

                      // show dialog to confirm exit
                      Navigator.pop(context)
                    ,
                  child: Container(
                          padding: EdgeInsets.fromLTRB(0, 16, 16, 32),
                          child: Icon(PhosphorIconsBold.arrowBendUpLeft),
                  ),
                ),
                // Text('check', style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.displaySmall)), 
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatUser())),
                      child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
                                decoration: BoxDecoration(
                                color: const Color(0x66EEEEEE),
                                border: Border.all(color: const Color(0xFFCCCCCC)),
                                // color: Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    // color: Colors.black26,
                                    color: Color(0xCCF5F5F5),
                                    // color: Color(0xFF080B23),
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 24.0,
                                    spreadRadius: 0.3,
                                  ),
                                ]
                              ),
                            child:
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('Help', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                                SizedBox(width: 4,),
                                Icon(PhosphorIconsRegular.lifebuoy, color: Palette.black, size: 24,),
                          ],
                        ),
                      )
                    ),
                    InkWell(
                        onTap: () => {
                            _showResources(context)
                            },
                      child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
                                decoration: BoxDecoration(
                                color: const Color(0x66EEEEEE),
                                border: Border.all(color: const Color(0xFFCCCCCC)),
                                // color: Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    // color: Colors.black26,
                                    color: Color(0xCCF5F5F5),
                                    // color: Color(0xFF080B23),
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 24.0,
                                    spreadRadius: 0.3,
                                  ),
                                ]
                              ),
                            child:
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('Resources', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                                SizedBox(width: 4,),
                                Icon(PhosphorIconsRegular.fileText, color: Palette.black, size: 24,),
                          ],
                        ),
                      )
                    )
                ]
                ),
                
              ],),
        
            Container(
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
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        
                        Text(widget.feeling!, style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displayMedium, color: Palette.black), textAlign: TextAlign.center, ), 
                        
                      ],
                    ),
                  ]
                ),
            ),


            // sizedBox(16),
             (description2!.length > 1) ? Container(
              // decoration: BoxDecoration(
              //   color: Color(0x66FFFFFF),
              //   border: Border.all(color: Color(0xFFFFFFFF)),
              //   // color: Color(0xFFFFFFFF),
              //   borderRadius: BorderRadius.circular(10),
              //   boxShadow: const [
              //     BoxShadow(
              //       // color: Colors.black26,
              //       color: Color(0xCCFFFFFF),
              //       // color: Color(0xFF080B23),
              //       offset: Offset(0.0, 0.0),
              //       blurRadius: 24.0,
              //       spreadRadius: 0.3,
              //     ),
              //   ]
              // ),
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(list[0].description!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                      ],
                    ),
                  ]
                ),
            ) : AppProgress(height: 36, width: 36),

            sizedBox(16),
             (description2!.length > 1) ? Container(
              decoration: BoxDecoration(
                color: Color(0x66FFFFFF),
                border: Border.all(color: Color(0xFFFFFFFF)),
                // color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCF5F5F5),
                    // color: Color(0xFF080B23),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(description2, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                        
// RichText(
//   text: TextSpan(
//     children: [
//       TextSpan(
//         text: "It is great ",
//         style: TextStyle(fontSize: 16.0, color: Colors.black),
//       ),
//       TextSpan(
//         text: "texty",
//         style: TextStyle(
//           fontSize: 16.0,
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       TextSpan(
//         text: " for this ",
//         style: TextStyle(fontSize: 16.0, color: Colors.black),
//       ),
//       TextSpan(
//         text: "sentence",
//         style: TextStyle(
//           fontSize: 16.0,
//           color: Colors.black,
//           fontStyle: FontStyle.italic,
//         ),
//       ),
//     ],
//   ),
// ),



                      ],
                    ),
                  ]
                ),
            ) : sizedBox(0),
            
            sizedBox(16),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Color(0x66FFCEBF),
            //     border: Border.all(color: Color(0xFFFFCEBF)), 
            //     borderRadius: BorderRadius.circular(10),
            //     boxShadow: const [
            //       BoxShadow(
            //         // color: Colors.black26,
            //         color: Color(0xCCFFCEBF),
            //         offset: Offset(0.0, 0.0),
            //         blurRadius: 24.0,
            //         spreadRadius: 0.3,
            //       ),
            //     ]
            //   ),
            //   // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            //   child: 
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             Text('Resources', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
            //             MaterialButton(
            //               child: Text("View", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Palette.white)),
            //               padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            //               color: Palette.black,
            //               textColor: Palette.white,
            //               splashColor: Palette.white,
            //               colorBrightness: Brightness.light,
            //               shape: const StadiumBorder(),
            //               onPressed: () {
            //                 _showResources(context);
            //               },
            //             )
            //           ],
            //         ),
            //       ]
            //     ),
            //   ),
            //   sizedBox(4),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Color(0x66FFE6E3),
            //     border: Border.all(color: Color(0xFFFFE6E3)), 
            //     borderRadius: BorderRadius.circular(10),
            //     boxShadow: const [
            //       BoxShadow(
            //         // color: Colors.black26,
            //         color: Color(0xCCFFE6E3),
            //         offset: Offset(0.0, 0.0),
            //         blurRadius: 24.0,
            //         spreadRadius: 0.3,
            //       ),
            //     ]
            //   ),
            //   margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            //   child: 
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: <Widget>[
            //             Text('Are you feeling ${widget.feeling}?', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
            //             MaterialButton(
            //               child: Text("Yes", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Palette.white)),
            //               padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            //               color: Palette.black,
            //               textColor: Palette.white,
            //               splashColor: Palette.white,
            //               colorBrightness: Brightness.light,
            //               shape: const StadiumBorder(),
            //               onPressed: () {
                            
            //                 Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentNew()));
            //                 // Navigator.pop(context);
            //               },
          
            //             )
            //           ],
            //         ),
            //       ]
            //     ),
            //   ),

            sizedBox(16),
            Container(
              decoration: BoxDecoration(
                color: Color(0xAAFFE6E3),
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
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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

            sizedBox(8),
            Container(
              decoration: BoxDecoration(
                color: Color(0xAAF0E0DF),
                border: Border.all(color: Color(0xFFF0E0DF)), 
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCF0E0DF),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Chat with Psychologist', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                        MaterialButton(
                          child: Text("Chat now", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Palette.white)),
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                          color: Palette.black,
                          textColor: Palette.white,
                          splashColor: Palette.white,
                          colorBrightness: Brightness.light,
                          shape: const StadiumBorder(),
                          onPressed: () {
                            
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatUser()));
                            // Navigator.pop(context);
                          },
          
                        )
                      ],
                    ),
                  ]
                ),
              ),

            
              
            sizedBox(32),
             (description3.length > 1) ? Container(
              decoration: BoxDecoration(
                color: Color(0x66DDC9FF),
                border: Border.all(color: Color(0xFFDDC9FF)),
                // color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCDDC9FF),
                    // color: Color(0xFF080B23),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(text: htmlToTextSpan(description3[0]),),
                      ],
                    ),
                  ]
                ),
            ) : sizedBox(0),
            
            sizedBox(16),
             (description3.length > 1) ? Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0x66DDC9FF),
                border: Border.all(color: Color(0xFFDDC9FF)),
                // color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    // color: Colors.black26,
                    color: Color(0xCCDDC9FF),
                    // color: Color(0xFF080B23),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 24.0,
                    spreadRadius: 0.3,
                  ),
                ]
              ),
              // margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(text: htmlToTextSpan(description3[1]),),
                      ],
                    ),
                  ]
                ),
            ) : sizedBox(0),

            // (widget.result.message1!.length > 1) ? Container(
            //   decoration: BoxDecoration(
            //     color: Color(0x66FFFFFF),
            //     border: Border.all(color: Color(0xFFFFFFFF)),
            //     // color: Color(0xFFFFFFFF),
            //     borderRadius: BorderRadius.circular(10),
            //     boxShadow: const [
            //       BoxShadow(
            //         // color: Colors.black26,
            //         color: Color(0xCCFFFFFF),
            //         // color: Color(0xFF080B23),
            //         offset: Offset(0.0, 0.0),
            //         blurRadius: 24.0,
            //         spreadRadius: 0.3,
            //       ),
            //     ]
            //   ),
            //   margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            //   child: 
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: <Widget>[
            //             Text(widget.result.message1!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
            //           ],
            //         ),
            //       ]
            //     ),
            // ) : sizedBox(0),

            sizedBox(4),

            // (widget.result.message2!.length > 1) ? Container(
            //   decoration: BoxDecoration(
            //     color: Color(0x66FFFFFF),
            //     border: Border.all(color: Color(0xFFFFFFFF)),
            //     // color: Color(0xFFFFFFFF),
            //     borderRadius: BorderRadius.circular(10),
            //     boxShadow: const [
            //       BoxShadow(
            //         // color: Colors.black26,
            //         color: Color(0xCCFFFFFF),
            //         // color: Color(0xFF080B23),
            //         offset: Offset(0.0, 0.0),
            //         blurRadius: 24.0,
            //         spreadRadius: 0.3,
            //       ),
            //     ]
            //   ),
            //   margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            //   child: 
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: <Widget>[
            //             Text(widget.result.message2!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
            //           ],
            //         ),
            //       ]
            //     ),
            // ) : sizedBox(0),
              

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
//     getLibraryTopicDetailData();
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
  // void closeAssessment(BuildContext context) async {

  //   setState(() {
  //     isClosing = true;
  //   });
  //   // query parameters    
  //   Map<String, String> queryParams = {
  //     // "appointmentId":appointmentId,
  //     };

  //   var A = randomString("A");

  //   // API call
  //   //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
  //   var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.answers}${APIUrls.pass}/$role/$A/$campusId/$userObjectId/${widget.assessment.assessmentId}/${widget.resultString}/${widget.result.resultId}", queryParams)), headers: {"Accept": "application/json"});
    
  //   // get the result body which is JSON
  //   var jsonString = jsonDecode(result.body); 
    
  //   // convert jsonString to Map
  //   var jsonObject = jsonString as Map; 

  //   // check if the api returned success
  //   if(jsonObject['status'] == 200){
      
  //     // showToast(context, 'Your assessment is saved!',Constants.success);
        
  //   }
  //   else {
  //     // show the error msg
  //   //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error occured. Please try later!'), duration: Duration(seconds: 2),));
  //   showToast(context, jsonObject['message'],Constants.error);
  //   }
  // }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;



void _showResources(BuildContext context){
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
          top: Radius.circular(24.0)
        )
      ),
      backgroundColor: Color(0xEEFFCEBF),

      // decoration: BoxDecoration(
      //           color: Color(0x66FFCEBF),
      //           border: Border.all(color: Color(0xFFFFCEBF)), 
      //           borderRadius: BorderRadius.circular(10),
      //           boxShadow: const [
      //             BoxShadow(
      //               // color: Colors.black26,
      //               color: Color(0xCCFFCEBF),
      //               offset: Offset(0.0, 0.0),
      //               blurRadius: 24.0,
      //               spreadRadius: 0.3,
      //             ),
      //           ]
      //         ),

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
              // padding: const EdgeInsets.all(16),
              // height: 300, // Adjust the height as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    
                    child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Resources', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.bold)),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: 
                            InkWell(
                              onTap: () => {
                                    Navigator.pop(context)
                                    },
                              child: Icon(PhosphorIconsRegular.x, color: Palette.textShade1, size: 24,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  sizedBox(16),
                  
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Disable ListView's scrolling
                shrinkWrap: true,
                      // controller: scrollController,
                      // scrollDirection: Axis.vertical,
                      itemCount: links.length,
                      itemBuilder: (context, position){
                        
                        return 
                        // InkWell(
                        //    onTap: () => {print('ok'),
                        //     _openResource(links[position])},
                        //   child: 
                            Container(
                              
                              margin: EdgeInsets.all(4),
                              child: AnyLinkPreview(
                                        link: links[position],
                                        displayDirection: UIDirection.uiDirectionHorizontal,
                                        showMultimedia: false,
                                        bodyMaxLines: 2,
                                        bodyTextOverflow: TextOverflow.ellipsis,
                                        titleStyle: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, color: Colors.blue.shade700, decoration: TextDecoration.underline, decorationColor: Colors.blue.shade700, ),
                                        bodyStyle: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.black87),
                                        errorBody: 'Click to view',
                                        errorTitle: '',
                                        errorWidget: sizedBox(0),
                                        // errorWidget: Container(
                                        //     color: Colors.grey[300],
                                        //     child: Text('Oops!'),
                                        // ),
                                        errorImage: "https://google.com/",
                                        cache: Duration(days: 7),
                                        backgroundColor: Colors.grey[300],
                                        borderRadius: 12,
                                        removeElevation: false,
                                        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
                                        onTap: (){
                                          
                                          _openResource(links[position]);
                                        }, // This disables tap event
                                    ),
                              // child: requestForApprovalCard(position, context1),
                            // )
                        );
                      },
                    ),
                  // Text(links[0], style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium) ), 
                  sizedBox(64),
              ],)
              
            )
        );
        

    });
  }

 
  // Function to open resource link
  void _openResource(String resourceUrl) async {
      
      Uri url = Uri.parse(resourceUrl);
     
      await canLaunchUrl(url).then((value) => {
        // print(value),
        // print(url),
        // launchUrl(url, mode: LaunchMode.externalNonBrowserApplication),
        launchUrl(url, mode: LaunchMode.platformDefault),
      });
  }


}


