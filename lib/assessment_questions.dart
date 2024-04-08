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

class Questions extends StatefulWidget {
  final Assessment assessment;

  Questions({required this.assessment});

  @override
  QuestionsState createState() => QuestionsState();
}

class QuestionsState extends State<Questions> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<Questions> {

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

  List<Question> questionsList = [];
  List<Result> resultsList = [];
  late Result result;
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

  @override
  void initState(){

super.initState();
  // _formKey = GlobalKey();

// print(Provider.of<SharedState>(context).isDataLoaded);
    getUserData();
    if(questionsList.isEmpty ) {

      getQuestionsData();
      // getOfficialDates();
    }
    
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

// S1 ADMIN ––––– get the appointments that are unassigned and assigned by campus by duration
// S2 ADMIN ––––– get the appointments by user
// S3 USERS ––––– get the appointments that are mine by requestDate
// S4 SUPERADMIN ––––– get all appointments 

// 1 role – SuperAdmin / PAdmin / Student
// 2 stage
// 3 requestStatus – Approved, Issued or All
// 4 offset – 0
// 5 collegeId - Super33
// 6 campusId - SVECW or All
// 7 dates – from,to
  // get the feed data
  void getQuestionsData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.questions}${APIUrls.pass}/$role/$offset/$collegeId/$campusId/${widget.assessment.assessmentId}");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.questions}${APIUrls.pass}/$role/$offset/$collegeId/$campusId/${widget.assessment.assessmentId}", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(utf8.decode(result.bodyBytes));
      // var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<Question> list1;
      List<Result> list2;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var questions = jsonObject['questions'] as List;
        var results = jsonObject['results'] as List;

        if(questions.isNotEmpty){
          // convert to list
          list1 = questions.map<Question>((json) => Question.fromJson(json)).toList();
          list2 = results.map<Result>((json) => Result.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              questionsList.clear();
              resultsList.clear();
              questionsList.addAll(list1);
              resultsList.addAll(list2);

              // segregate between old and new items
              // for (var element in list1) {
              //   if(element.isOpen == 1){
              //     // list.add(element);
              //     showCreateCTA = false;
              //   }
              //   // else {
              //   //   oldList.add(element);
              //   // }
              // }
              
              isLoading = false;
              isDataAvailable = true;
            });
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
          // no requests
          setState(() {
            emptyStateMsg = 'No pending requests';
            isLoading = false;
            isDataAvailable = false;
          });
        }

      
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
            getQuestionsData();
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
      getQuestionsData();
      // getOfficialDates();
    });
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
        
      
        Builder(builder: (context) => Container(


        
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
                    
                    margin: const EdgeInsets.all(16),
                    child:  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        InkWell(
                          onTap: () => 
                          // show dialog to confirm exit
                          _confirmRejectionDialog(context)
                        ,
                        child: Container(
                              padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                              child: Icon(PhosphorIconsBold.arrowBendUpLeft),
                          ),
                        ),
                        // Text('Self Assessments', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                        Expanded(child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ 
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              Text(widget.assessment.title!, style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                            ],),
                              sizedBox(8),
                              
                              Text(widget.assessment.title2!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                              // sizedBox(8)
                            ],
                          ),)
                      ],
                    ),
                  
              ),
              
            
                Expanded(
                  // child: list.isEmpty ? 
                  child: isLoading ? 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // loader while fetching data
                          isLoading? const AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                          Container(
                          alignment: Alignment.center,
                          child: Text(emptyStateMsg, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium)), 
                        )
                      ],)
                      : 
                      (questionsList.isNotEmpty) ?
                      RefreshIndicator(
                        onRefresh: _refreshList,
                        child: 
                          ListView.builder(

                          // controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: questionsList.length,
                          itemBuilder: (context, index){
                            
                            return Container(
                              
                                  child: myRequestCard(index, context),
                                );
                          })
                    
                      )
                          : 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // loader while fetching data
                              // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                              Icon(PhosphorIconsRegular.checkCircle),
                              Container(
                                alignment: Alignment.center,
                                child: Text('No questions available!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText2)), 
                            ),
                            sizedBox(8),
                            
                      ],)
                     
                
            ),
            (questionsList.isNotEmpty) ? Container(
                alignment: Alignment.center,
                child: 
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
                              

                          int stopLoop=0;

                          // check if all questions are answered
                          for(int j=0;j<questionsList.length;j++){
                            if(questionsList[j].selectedOption == -1){
                              stopLoop = 1;
                              break;
                            }
                          }

                          // execute the results if all questions are answered
                          if(stopLoop == 1){
                            showToast(context, 'Answer all questions', Constants.warning);
                          }
                          else {

                            // check if assessment is 'Scoring' or 'Interpretation'
                            if(widget.assessment.assessmentType == 1){
                              
                                marks = 0;
                                for(int j=0;j<questionsList.length;j++){

                                  // add the marks
                                  marks = marks + (questionsList[j].options! - questionsList[j].selectedOption!);

                                  // form the string of result
                                  String selectedOption = questionsList[j].selectedOption.toString();

                                  // Append the formatted string to the commaSeparatedString, ensuring a comma only if it's not the first element
                                  resultString += "${resultString.isEmpty ? "" : ","}$j-$selectedOption";
                                
                                }

                                // calculate the final score
                                // print(marks);
                                // print(marks/questionsList.length); // final score to compare with results
                                // print((marks/questionsList.length).round()); // final score to compare with results
                                // print(resultString); // final score to compare with results
                                

                                resultsList.forEach((element) {
                                  if(element.result == ((marks/questionsList.length).round()).toString()){
                                    // print(element.message1);

                                    
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AssessmentResult(resultString: resultString, assessment: widget.assessment, result: element)),);

                                  }
                                });
                              }
                              // this is YES or NO question
                              else if(widget.assessment.assessmentType == 2){

                                marks = 0;
                                for(int j=0;j<questionsList.length;j++){
                                  
                                  // add the marks only if "YES" is answered
                                  if(questionsList[j].selectedOption == 0){
                                    marks = marks + 1;
                                  }
                                  
                                  // form the string of result
                                  String selectedOption = questionsList[j].selectedOption.toString();

                                  // Append the formatted string to the commaSeparatedString, ensuring a comma only if it's not the first element
                                  resultString += "${resultString.isEmpty ? "" : ","}$j-$selectedOption";
                                
                                }

                                // calculate the final score
                                // print(marks);
                                // print(resultString); // final score to compare with results
                                

                                resultsList.forEach((element) {

                                  // Split the result string into a list of numbers
                                  List<String> rangeValues = element.result!.split(",");

                                  // Handle potential errors
                                  if (rangeValues.length == 2) {
                                    // Convert the range values to integers
                                    int minValue = int.parse(rangeValues[0]);
                                    int maxValue = int.parse(rangeValues[1]);

                                    // Check if marks is within the range
                                    if (marks >= minValue && marks <= maxValue) {
                                      // Marks is within the range, perform necessary actions
                                      // print("Marks $marks is within the range $minValue-$maxValue");
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AssessmentResult(resultString: resultString, assessment: widget.assessment, result: element)),);
                                    } 
                                  } else {
                                    // Handle invalid range format
                                    showToast(context, 'Something went wrong. Try again later!', Constants.error);
                                  }
                                });
                              }
                          }
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
                                          Text('SUBMIT', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                        ],
                                    )
                            ),
                          ),
                      )
                
                
                // MaterialButton(
                //         child: Text("SUBMIT", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge)),
                //         padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                //         color: Palette.appBackgroundSolitude,
                //         textColor: Palette.black,
                //         splashColor: Palette.textShade2,
                //         colorBrightness: Brightness.light,
                //         shape: const StadiumBorder(),
                //         onPressed: () {

                //           int stopLoop=0;

                //           // check if all questions are answered
                //           for(int j=0;j<questionsList.length;j++){
                //             if(questionsList[j].selectedOption == -1){
                //               stopLoop = 1;
                //               break;
                //             }
                //           }

                //           // execute the results if all questions are answered
                //           if(stopLoop == 1){
                //             showToast(context, 'Answer all questions', Constants.warning);
                //           }
                //           else {

                //             // check if assessment is 'Scoring' or 'Interpretation'
                //             if(widget.assessment.assessmentType == 1){
                              
                //                 marks = 0;
                //                 for(int j=0;j<questionsList.length;j++){

                //                   // add the marks
                //                   marks = marks + (questionsList[j].options! - questionsList[j].selectedOption!);

                //                   // form the string of result
                //                   String selectedOption = questionsList[j].selectedOption.toString();

                //                   // Append the formatted string to the commaSeparatedString, ensuring a comma only if it's not the first element
                //                   resultString += "${resultString.isEmpty ? "" : ","}$j-$selectedOption";
                                
                //                 }

                //                 // calculate the final score
                //                 // print(marks);
                //                 // print(marks/questionsList.length); // final score to compare with results
                //                 // print((marks/questionsList.length).round()); // final score to compare with results
                //                 // print(resultString); // final score to compare with results
                                

                //                 resultsList.forEach((element) {
                //                   if(element.result == ((marks/questionsList.length).round()).toString()){
                //                     // print(element.message1);

                                    
                //                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AssessmentResult(resultString: resultString, assessment: widget.assessment, result: element)),);

                //                   }
                //                 });
                //               }
                //               // this is YES or NO question
                //               else if(widget.assessment.assessmentType == 2){

                //                 marks = 0;
                //                 for(int j=0;j<questionsList.length;j++){
                                  
                //                   // add the marks only if "YES" is answered
                //                   if(questionsList[j].selectedOption == 0){
                //                     marks = marks + 1;
                //                   }
                                  
                //                   // form the string of result
                //                   String selectedOption = questionsList[j].selectedOption.toString();

                //                   // Append the formatted string to the commaSeparatedString, ensuring a comma only if it's not the first element
                //                   resultString += "${resultString.isEmpty ? "" : ","}$j-$selectedOption";
                                
                //                 }

                //                 // calculate the final score
                //                 // print(marks);
                //                 // print(resultString); // final score to compare with results
                                

                //                 resultsList.forEach((element) {

                //                   // Split the result string into a list of numbers
                //                   List<String> rangeValues = element.result!.split(",");

                //                   // Handle potential errors
                //                   if (rangeValues.length == 2) {
                //                     // Convert the range values to integers
                //                     int minValue = int.parse(rangeValues[0]);
                //                     int maxValue = int.parse(rangeValues[1]);

                //                     // Check if marks is within the range
                //                     if (marks >= minValue && marks <= maxValue) {
                //                       // Marks is within the range, perform necessary actions
                //                       // print("Marks $marks is within the range $minValue-$maxValue");
                //                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AssessmentResult(resultString: resultString, assessment: widget.assessment, result: element)),);
                //                     } 
                //                   } else {
                //                     // Handle invalid range format
                //                     showToast(context, 'Something went wrong. Try again later!', Constants.error);
                //                   }
                //                 });
                //               }
                //           }
                //           // Navigator.pop(context);
                //         },

                //       )
                // Text('Pull down to refresh!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)), 
              ) : sizedBox(0),
           
                   
          ],), 


        ),
        
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
    getQuestionsData();
    // getOfficialDates();
  }


// single feed card
Widget myRequestCard(int position, BuildContext context){
  int? _selectedOption;
  return InkWell(
    // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Questions())),

    // add decoration
    child: 
    Container(
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
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
                        
                        // Text(questionsList[position].question!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge)), 
                        Text(questionsList[position].question!, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600) ), 
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
                              padding: EdgeInsets.all(4),
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
                                SizedBox(width:4),
                                Flexible(
                                    child: Text(questionsList[position].optionTexts![index], style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge) ), 
                                    // Text(questionsList[position].optionTexts![index], style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, letterSpacing: 0.4, fontSize: 14, color: Palette.black)),
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
