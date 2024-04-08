import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/services.dart';
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

class MoodMonitor extends StatefulWidget {
  // final Assessment assessment;

  // MoodMonitor({required this.assessment});

  @override
  MoodMonitorState createState() => MoodMonitorState();
}

class MoodMonitorState extends State<MoodMonitor> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<MoodMonitor> {

// late GlobalKey<FormState> _formKey;
  TextEditingController descriptionController = new TextEditingController();
  DateTime today = DateTime.now();
  ScrollController? scrollController;
  String? username, collegeId = '';
  bool isLoading = false;
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;
  int offset = 0;
  int year = 0;
  // bool refreshQR = false;
  String universityId= '', role = '', type = '', branch = '', campusId = '', course = '', gcmRegId = '';

  List<Question> questionsList = [];
  List<Result> resultsList = [];
  String emotion = '';
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
  List<String> relatedFeelings = [];
  List<String> selectedFeelings = [];
  String selectedFeeling = '';

 double _rotation = 0.0;
  final int _totalImages = 6;
  int _currentFocusIndex = 0;

  void _updateRotation(Offset details) {
    setState(() {
      _rotation += details.dx / 100; // Adjust for sensitivity
    });
    _updateFocusIndex();
  }

  void _updateFocusIndex() {
    double anglePerImage = 2 * math.pi / _totalImages;
    double currentAngle = _rotation % (2 * math.pi);
    int newFocusIndex = (((currentAngle + math.pi / 2) % (2 * math.pi)) / anglePerImage).floor() % _totalImages;
    if (newFocusIndex != _currentFocusIndex) {
      _currentFocusIndex = newFocusIndex;
      print('Image in focus: Image ${_currentFocusIndex + 1}');
    }
  }

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

 Future<void> getFeelingsForEmotion(String emo) async {

  // play the sound
  player.setAsset('assets/incoming.mp3');
  player.play();

    try {
      final jsonData = await loadJsonFromAssets('assets/emotions.json');
      setState(() {
        List<dynamic> mixedList = jsonData[emo];
        relatedFeelings = mixedList.whereType<String>().toList();
        selectedFeeling = mixedList[0];
        // relatedFeelings = jsonData['Happy'] as List<String>; // Assuming a list of strings
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


  // save mood checkin
  // createdOn, campusId, collegeId, emotion, feeling, description
  void saveMoodCheckInWheel() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        isLoading = true;
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.mood}${APIUrls.pass}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$campusId/$userObjectId/$emotion/$selectedFeeling/${Uri.encodeComponent(descriptionController.text)}");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.mood}${APIUrls.pass}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$campusId/$collegeId/$emotion/${selectedFeelings.join(',')}/${Uri.encodeComponent(descriptionController.text)}", queryParams)), headers: {"Accept": "application/json"});
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
        Navigator.pop(context);
      
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
            saveMoodCheckInWheel();
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
      saveMoodCheckInWheel();
      // getOfficialDates();
    });
  }



  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth;
    final radius = circleSize / 2;
    final imageRadius = radius / 2;
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
        child:
        Container(


        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
            //   children: [ 
            //       AppHeader1('', '', 1, connectionStatus),
            //     ],
            //   ),
              Container(
                // margin: const EdgeInsets.all(16),
                child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        // Text('Mood Check-in', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                        InkWell(
                            onTap: () => 

                                // show dialog to confirm exit
                                Navigator.pop(context)
                              ,
                            child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(PhosphorIconsBold.arrowBendUpLeft),
                          ),
                        )
                        
                      ],),
                        
                        // sizedBox(8),
                        // Text('Monitor regularly to know and act on your emotions', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium), textAlign: TextAlign.center,), 
                        // sizedBox(8)
                      ],
                    ),
              ),
              
              Center(
                
                child:
                Container(
                  padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
                  child:
                      Text('How are you doing this ${getGreeting1()}?', style: GoogleFonts.dmSerifText(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF000000)), textAlign: TextAlign.center,),
                ),
              ),
              
               
    
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Expanded(
                    
                    child:

                  InkWell(
                    onTap: () {
                      setState(() {
                        getFeelingsForEmotion(Constants.happy);
                        emotion = Constants.happy;
                      });
                    },          
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16,0,8,16),
                    padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (emotion == Constants.happy) ? Color(0x336302E5) : Color(0x66FFFFFF),
                        border: Border.all(color: const Color(0xFFFFFFFF)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCCFFFFFF),
                            offset: Offset(0.0, 0.0),
                            blurRadius: 24.0,
                            spreadRadius: 0.3,
                          ),
                        ]
                      ),
                    child: 
                        Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset( 'assets/positive.webp', width: 60, height: 60, ),
                                  sizedBox(16),
                            // Text('Positive', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    )
                  )),
            
            Expanded(
                    
                    child:
               InkWell(
                    onTap: () {
                      setState(() {
                        getFeelingsForEmotion(Constants.sad);
                        emotion = Constants.sad;
                      });
                    },     
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8,0,8,16),
                    padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (emotion == Constants.sad) ? Color(0x336302E5) : Color(0x66FFFFFF),
                        border: Border.all(color: const Color(0xFFFFFFFF)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCCFFFFFF),
                            offset: Offset(0.0, 0.0),
                            blurRadius: 24.0,
                            spreadRadius: 0.3,
                          ),
                        ]
                      ),
                    child: 
                        Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset( 'assets/neutral.webp', width: 60, height: 60, ),
                                  sizedBox(16),
                            // Text('Neutral', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    )
                  )
                  ),
            
            Expanded(
                    
                    child:
               InkWell(
                    onTap: () {
                      setState(() {
                        getFeelingsForEmotion(Constants.fear);
                        emotion = Constants.fear;
                      });
                    }, 
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8,0,16,16),
                    padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (emotion == Constants.fear) ? Color(0x336302E5) : Color(0x66FFFFFF),
                        border: Border.all(color: const Color(0xFFFFFFFF)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCCFFFFFF),
                            offset: Offset(0.0, 0.0),
                            blurRadius: 24.0,
                            spreadRadius: 0.3,
                          ),
                        ]
                      ),
                    child: 
                        Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset( 'assets/negative.webp', width: 60, height: 60, ),
                                  sizedBox(16),
                            // Text('Negative', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    )
                  )
                  ),
               ],
            ),
               
            sizedBox(32),
            emotion.isNotEmpty ? Text('Select how you feel', style: GoogleFonts.dmSerifText(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF000000)) ) : sizedBox(0), 
            sizedBox(16),
             Wrap(
              spacing: 16,
              runSpacing: 16,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // children: <Widget>[
                    children: relatedFeelings.map((feeling) => 
                    InkWell(
                      onTap: () => {
                        if(!selectedFeelings.contains(feeling)) {
                          setState(() {
                            selectedFeelings.add(feeling);
                          })
                          
                        }
                        else {
                          setState(() {
                            selectedFeelings.remove(feeling);
                          })
                          
                        }
                      },
                      child: Container(
                                // margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
                                decoration: BoxDecoration(
                                color: (selectedFeelings.contains(feeling)) ? Color(0xFFFFFFFF) : Color (0x66EEEEEE),
                                border: Border.all(color: (selectedFeelings.contains(feeling)) ? Color (0xFF6302E5) : Color(0xFFCCCCCC) ),
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
                            Wrap(
                              // mainAxisSize: MainAxisSize.min,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              
                              children: <Widget>[
                                Text(feeling, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: (selectedFeelings.contains(feeling)) ? Color (0xFF6302E5) : Color(0xFF000000) ) ), 
                                
                                
                          ],
                        ),
                      )
                    )
                    ).toList()
                ),
                
                
              sizedBox(32),
            emotion.isNotEmpty ?
            Column(
              children: [
                sizedBox(16),
                Container(
                        decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  border: Border.all(color: const Color(0xFFEEEEEE)),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xCCFFFFFF),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 24.0,
                                      spreadRadius: 0.3,
                                    ),
                                  ]
                                ),
                        
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextFormField(
                          style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium),
                          controller: descriptionController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 120,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            
                            hintText:  'What is causing you to feel this way',
                            // hintText: (_selectedValue == 1) ? 'Reason and going with' : (_selectedValue == 2) ? 'Reason and place of visit' : 'Reason and place of stay',
                              ),
                          validator: (value) { // validator function is called on calling form validate() method
                            if (value!.isEmpty) {
                              return 'What is causing you to feel this way';
                            }
                            return null;
                          },
                          //onSaved: (value) => description = value,
                        ),
                      ),

                sizedBox(32),
                (selectedFeeling.isNotEmpty) ? 
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
                              saveMoodCheckInWheel();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 14.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                                          Icon(PhosphorIconsRegular.check, color: Colors.white, size: 24,),
                                          const SizedBox(width: 8,),
                                          Text('Save', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                        ],
                                    )
                            ),
                          ),
                      )
                // Container(
                //     alignment: Alignment.center,
                //     child: 
                //     // loader while fetching data
                //     isLoading? AppProgress(height: 30, width: 30,) :
                //     MaterialButton(
                //             child: Text("SAVE", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge)),
                //             padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                //             color: Palette.appBackgroundSolitude,
                //             textColor: Palette.black,
                //             splashColor: Palette.textShade2,
                //             colorBrightness: Brightness.light,
                //             shape: const StadiumBorder(),
                //             onPressed: () {

                //               saveMoodCheckInWheel();
                //               // Navigator.pop(context);
                //             },

                //           )
                //     // Text('Pull down to refresh!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)), 
                //   )
                : sizedBox(0),
              
              ],
            ) : sizedBox(0)
            
                   
          ],), 


        ),
        )
        ),
        
      )
        )
            ]
        )
    );
  }

 Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
        isDataAvailable = true;
      });
    saveMoodCheckInWheel();
    // getOfficialDates();
  }


// single feed card
Widget myRequestCard(int position, BuildContext context){
  int? _selectedOption;
  return InkWell(
    // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoodCheckInWheel())),

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
                        Text(questionsList[position].question!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge) ), 
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
                                    child: Text(questionsList[position].optionTexts![index], style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge) ), 
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

            Text('Your option selections will be lost', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium)), 
                  

            actions: <Widget>[
              MaterialButton(
                child: Text('Don\'t close', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium)), 
                
                onPressed: () {
                  
                  Navigator.of(context).pop();
                  
                },
              ),
              MaterialButton(
                child: Text('Close now', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium)), 
                
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
