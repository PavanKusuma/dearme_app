import 'dart:convert';
import 'dart:io';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/assessment_result.dart';
import 'package:psych_app/assessments.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/modal/assessment.dart';
import 'package:psych_app/modal/question.dart';
import 'package:psych_app/modal/result.dart';
import 'package:psych_app/moodwheel.dart';

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

class MoodCheckIn extends StatefulWidget {
  // final Assessment assessment;

  // MoodCheckIn({required this.assessment});

  @override
  MoodCheckInState createState() => MoodCheckInState();
}

class MoodCheckInState extends State<MoodCheckIn> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<MoodCheckIn> {

// late GlobalKey<FormState> _formKey;
  TextEditingController descriptionController = new TextEditingController();
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

  List<Question> questionsList = [];
  List<Result> resultsList = [];
  String emotion = '', feeling = '';
  String resultString = '';
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


  bool _isOverlayVisible = false;
  String _selectedString = 'Happy'; // Initial selected string
  List<String> _strings = ['Happy', 'Sad', 'Angry', 'Surprised', 'Excited'];

  @override
  void initState(){

super.initState();
  // _formKey = GlobalKey();

// print(Provider.of<SharedState>(context).isDataLoaded);
    getUserData();
    
    scrollController = new ScrollController()..addListener(_scrollListener);
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

   
  }

  // save mood checkin
  // createdOn, campusId, collegeId, emotion, feeling, description
  void saveMoodCheckIn() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.questions}${APIUrls.pass}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$campusId/$userObjectId/$emotion/$feeling/${Uri.encodeComponent(descriptionController.text)}");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.questions}${APIUrls.pass}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$campusId/$collegeId/$emotion/$feeling/${Uri.encodeComponent(descriptionController.text)}", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      // check if the api returned success
      if(jsonObject['status'] == 200){

        // get the list data from jsonObject
        var message = jsonObject['message'] as String;
        showToast(context, message, Constants.success);
      
      }
      else {
          // no requests
          setState(() {
            emptyStateMsg = 'No pending requests';
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
            saveMoodCheckIn();
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
  

  // detect scroll to end and load more items
  void _scrollListener(){
    if(scrollController!.position.pixels == scrollController!.position.maxScrollExtent){
      setState(() {
        // increment offset by 5
        if(questionsList.length-5 == offset){
          offset = offset+5;
          // show up the loader
          startLoader();
        }
        else {
          //print('do nothing');
          
        }
      });
    }
  }

  // show the loader while loading more items
  void startLoader(){
    setState((){
      isLoading = !isLoading;
      saveMoodCheckIn();
      // getOfficialDates();
    });
  }



  @override
  Widget build(BuildContext context){
  
  return Scaffold(
  appBar: AppBar(title: Text('Half Hidden Container')),

  body: 
  Stack(
    alignment: Alignment.bottomCenter,
  children: [
    // Other widgets
    Positioned(
      bottom: -(MediaQuery.of(context).size.width/2), // Adjust to control hidden portion
      child: 
    Container(
      alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // bottom: MediaQuery.of(context).size.width/2, // Adjust to control hidden portion
      child: ClipRect(
        child: Container(
          
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child:    Text('Hello'),
          
  ),
      )
    ),)
  ],
)


);

  }

 Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
        isDataAvailable = true;
      });
    saveMoodCheckIn();
    // getOfficialDates();
  }


// single feed card
Widget myRequestCard(int position, BuildContext context){
  int? _selectedOption;
  return InkWell(
    // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodCheckIn())),

    // add decoration
    child: 
    Container(
      decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
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
                        
                        // Text(questionsList[position].question!, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge)), 
                        Text(questionsList[position].question!, style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.titleLarge) ), 
                        // Image.asset('assets/mood.png', width: 150, height: 150),

                        sizedBox(16),
                        ...List.generate(questionsList[position].options!, (index) {
                          
                          return 
                          InkWell(
                            onTap: () {
                              setState(() {

                                // // check if assessment is 'Scoring' or 'Interpretation'
                                // if(widget.assessment.assessmentType == 1){

                                //   if(index == 0){
                                //     marks = marks + 3;
                                //   }
                                // }
                                // storing the index of the answer as choosen option
                                questionsList[position].selectedOption = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: 
                              Row(
                              children: [
                                Radio(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Palette.appPrimary,
                                  fillColor: MaterialStateProperty.all(Palette.black),
                                  value: questionsList[position].selectedOption,
                                  groupValue: index,
                                  onChanged: (value) {
                                    setState(() {
                                      // storing the index of the answer as choosen option
                                      questionsList[position].selectedOption = index;
                                      // _selectedOption = index;
                                    });
                                  },
                                ),
                                const SizedBox(width:4),
                                Flexible(
                                    child: Text(questionsList[position].optionTexts![index], style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.bodyLarge) ), 
                                    // Text(questionsList[position].optionTexts![index], style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, letterSpacing: 0.4, fontSize: 14, color: Palette.black)),
                                )
                              ],
                            ))
                          );
                          
                        }),
                         
                            
                        sizedBox(8),

                            
                      ],
                    ),


            ]
          ),

          
      // ),
    ),
  );

}


  _confirmRejectionDialog(BuildContext context1) async {
  
    return showDialog(
        context: context1,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            title: const Text('Close assessment'),

            content: 

            Text('Your option selections will be lost', style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.titleMedium)), 
                  

            actions: <Widget>[
              MaterialButton(
                child: Text('Don\'t close', style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.titleMedium)), 
                
                onPressed: () {
                  
                  Navigator.of(context).pop();
                  
                },
              ),
              MaterialButton(
                child: Text('Close now', style: GoogleFonts.averiaGruesaLibre(textStyle: Theme.of(context).textTheme.titleMedium)), 
                
                onPressed: () {
                  
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Navigator.popUntil(context, ModalRoute.withName('/Assessments'));
                  
                  // updateRequest(context1, requestItem, Constants.rejected, context1,  textFieldController.text, '-');
                  // updateRequest(context1, requestItem, Constants.rejected, position, context1,  textFieldController.text, '-');
                },
              )
            ],
          );
        });
  }

  // on subitting values
  void onSubmit(BuildContext context, String appointmentId, int position){
    
      // verify if collegeId exists and matches with the phoneNumber
      closeRequest(context, appointmentId, position);
    }


  // close request
  void closeRequest(BuildContext context, String appointmentId, int position) async {
    setState(() {
      isClosing = true;
    });
    // query parameters    
    Map<String, String> queryParams = {
      // "appointmentId":appointmentId,
      };

    // API call
    //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S1.5/$appointmentId", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      questionsList.removeAt(position);
      
      setState(() {
        questionsList = questionsList;
        isDataAvailable = false;
        isClosing = false;
      });

      showToast(context, 'Request closed!',Constants.success);
        
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
