import 'dart:convert';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
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

class Appointments extends StatefulWidget {
  const Appointments({Key? key}) : super(key: key);

  @override
  AppointmentsState createState() => AppointmentsState();
}

class AppointmentsState extends State<Appointments> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<Appointments> {

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
    if(list.isEmpty ) {

      getAppointmentsData();
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
  void getAppointmentsData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        first = false;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.appointments}${APIUrls.pass}/$role/All/$offset/$userObjectId/$campusId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.appointments}${APIUrls.pass}/$role/S3/All/$offset/$collegeId/$campusId", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<Appointment> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<Appointment>((json) => Appointment.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              list.clear();
              oldList.clear();
              list.addAll(list1);

              // segregate between old and new items
              for (var element in list1) {
                if(element.isOpen == 1){
                  // list.add(element);
                  showCreateCTA = false;
                }
                // else {
                //   oldList.add(element);
                // }
              }
              
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
            getAppointmentsData();
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
        if(oldList.length-5 == offset){
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
      getAppointmentsData();
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
                        Text('Appointments', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                      ],),
                        sizedBox(8),
                        Text('Reach out for help', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],
                    ),
              ),



    
              
              (showCreateCTA) ? Row(
                
                
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  
                  Expanded(
                    child: 
                  Container(
                    
                    
                    child: Container(
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
                              createNewRequest(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 14.0,
                              ),
                              child: Text('Book a slot', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                            ),
                          )
                        
                        // InkWell(
                        //   onTap: () => {
                        //         // verifyToCreate(context)
                        //         createNewRequest(context)
                        //   },
                        //   child: 
                          
                          
                          // Container(
                          //   padding: EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //           color: const Color(0x66FFFFFF),
                          //           border: Border.all(color: const Color(0xFFFFFFFF)),
                          //           // color: Color(0xFFFFFFFF),
                          //           borderRadius: BorderRadius.circular(50),
                          //           boxShadow: const [
                          //             BoxShadow(
                          //               // color: Colors.black26,
                          //               color: Color(0xCCFFFFFF),
                          //               // color: Color(0xFF080B23),
                          //               offset: Offset(0.0, 0.0),
                          //               blurRadius: 24.0,
                          //               spreadRadius: 0.3,
                          //             ),
                          //           ]
                          //         ),
                          //         child:  Row(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                          //                   Icon(PhosphorIconsRegular.calendarPlus, color: Colors.pink, size: 18,),
                          //                   const SizedBox(width: 8,),
                          //                   Text('Book Appointment', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.pink)),
                          //                 ],
                          //             )
                          // ),
                        // ),
                        

                        // MaterialButton(
                          
                        //       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        //       color: Palette.lightBackground,
                        //       colorBrightness: Brightness.light,
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        //       onPressed: () => {

                        //         // verifyToCreate(context)
                        //         createNewRequest(context)
                        //         },
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Container(
                        //             decoration: BoxDecoration(
                        //                 color: Palette.appPrimary,
                        //                 shape: BoxShape.circle,
                        //               ),
                        //             width: 24,
                        //             height: 24,
                        //               alignment: Alignment.center,
                        //               child: Icon(PhosphorIconsRegular.calendarPlus, color: Palette.white, size: 18,),
                        //           ),
                        //           // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                        //           const SizedBox(width: 8,),
                        //           Text('Book Appointment', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.blue)),
                        //         ],
                        //       )
                        // ),
                    ),
                  ),
                  ),
                ],
              ) : sizedBox(0),
              
              
              
            
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
                      (list.isNotEmpty) ?
                      RefreshIndicator(
                        onRefresh: _refreshList,
                        child: 
                          ListView.builder(

                          // controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          itemBuilder: (context, index){
                            
                            return Container(
                              
                                  child: (list[index].isOpen == 1) ? myRequestCard(index, context) : myRequestCardCompleted(index, context),
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
                                child: Text('No history available!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText2)), 
                            ),
                            sizedBox(8),
                            
                      ],),

                      
                     


                      //  RefreshIndicator(
                      //   onRefresh: _refreshList,
                      //   child: SingleChildScrollView(
                      // child: 
                      //   Wrap(
                      //       children: [
                             
                      //                 // REQUEST ITEM from the list
                      //                 (list.isNotEmpty) ?  myRequestCard(0, context) 
                      //                   :
                      //                   Column(
                      //                       mainAxisAlignment: MainAxisAlignment.center,
                      //                       mainAxisSize: MainAxisSize.max,
                      //                       children: [
                                            
                      //                         Container(
                      //                           alignment: Alignment.center,
                      //                           child: Text('No active requests!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)), 
                      //                         ),
                      //                       sizedBox(8),
                                            
                      //                 ],),

                      //         sizedBox(16),

                      //         // OLD REQUESTS
                      //                 (list.isNotEmpty) ?  myRequestCard(0, context) 
                      //                   :
                      //                   Column(
                      //                       mainAxisAlignment: MainAxisAlignment.center,
                      //                       mainAxisSize: MainAxisSize.max,
                      //                       children: [
                                            
                      //                         Container(
                      //                           alignment: Alignment.center,
                      //                           child: Text('No active requests!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)), 
                      //                         ),
                      //                       sizedBox(8),
                                            
                      //                 ],),
                                    
                      //       ])
                      // )
                      // ),


                      
                
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

  // create new request
  createNewRequest(BuildContext context) async{
    // print(allowedDates.length);
    // print(blockedDates.length);
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentNew()));
    
// print(result);
    if(result!=null){

      // request item
      Appointment appointmentItem = new Appointment();

      Map<String, dynamic> r =  result;
      
      appointmentItem.appointmentId = r['appointmentId'];
      appointmentItem.collegeId = r['collegeId'];
      appointmentItem.adminId = r['adminId'];
      appointmentItem.adminName = r['adminName'];
      appointmentItem.topic = r['topic'];
      appointmentItem.description = r['description'];
      appointmentItem.requestDate = r['requestDate'];
      appointmentItem.isOpen = 1;
      appointmentItem.requestStatus = r['requestStatus'];
      appointmentItem.notes = '-';
      appointmentItem.mode = 0;
      appointmentItem.createdOn = r['createdOn'];
      appointmentItem.updatedOn = '-';
      appointmentItem.campusId = r['campusId'];

      // add object to list
      List<Appointment> list1 = [];
      list1.add(appointmentItem);
      list1.addAll(list);

      setState(() {
        list = list1;
      });

      // set the data available to true
      // so that the user won't be able to create new request again.
      setState(() {
        isDataAvailable = true;
      });
      getAppointmentsData();
      // show update message
      // showToast(context, 'Your $requestType request is submitted');


    }
  }

 Future<void> _refreshList() async {
    // Add your refresh logic here, e.g. fetching new data from a server
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
        isDataAvailable = true;
      });
    getAppointmentsData();
    // getOfficialDates();
  }


  String calculateTimeDifference(DateTime startTime, DateTime endTime) {
  final difference = endTime.difference(startTime);

  if (difference.inDays >= 1) {
    final days = difference.inDays;
    final hours = difference.inHours - days * 24;
    final minutes = difference.inMinutes - (days * 24 * 60) - (hours * 60);
    return '${days} day${days == 1 ? '' : 's'}, ${hours} hr${hours == 1 ? '' : 's'}, ${minutes} min${minutes == 1 ? '' : 's'}';
  } else if (difference.inHours >= 1) {
    final hours = difference.inHours;
    final minutes = difference.inMinutes - (hours * 60);
    return '${hours} hr${hours == 1 ? '' : 's'}, ${minutes} min${minutes == 1 ? '' : 's'}';
  } else {
    final minutes = difference.inMinutes;
    return '${minutes} min${minutes == 1 ? '' : 's'}';
  }
}

// single feed card
Widget myRequestCard(int position, BuildContext context){
  return Container(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
    margin: const EdgeInsets.all(16),

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              list[position].mode! == 0 ? 
                Container(
                  decoration: const BoxDecoration(
                  color: Color(0xFFE9D8FD),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text('In person', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, letterSpacing:0.5, fontWeight: FontWeight.w500, color: const Color(0xFF4C51BF) )),
                )
                : Container(
                        decoration: const BoxDecoration(
                        color: Color(0xFFFFD6E9),
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text('Virtual meet', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, letterSpacing:0.5, fontWeight: FontWeight.w500, color: const Color(0xFFC53078) )),
                      ),
                    sizedBox(8),
              Row(
                
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: 
                  Container(
                    decoration: BoxDecoration(
            
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child:  Column(
                                children: [
                                  Text("${DateFormat('MMM d, y', 'en_US').format(getDate(list[position].requestDate!)).toUpperCase()}, ${DateFormat().add_jm().format(getDate(list[position].requestDate!)).toUpperCase()}", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.w600, color: Colors.black87 )),
                                  // Text(DateFormat('MMM d, y', 'en_US').format(getDate(list[position].requestDate!)).toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                                  // sizedBox(4),
                                  // Text(DateFormat().add_jm().format(getDate(list[position].requestDate!)).toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text(list[position].description!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                  
                                ],
                              ),
                  ),
                  ),
                ],
              ),
              
              
              
              
                  //////////////////////////////////////
                  //////////////////////////////////////
                  //////////////////////////////////////
                  // show the request journey
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        //////////////////////////////////////////////
                        // first row for status : submitted
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    sizedBox(16),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Palette.green,
                                        shape: BoxShape.circle
                                      ),
                                      child: Icon(PhosphorIconsRegular.check, color: Palette.white, size: 16,),
                                    ),
                                    VerticalDottedLine(height: 40, color: (list[position].requestStatus == Constants.submitted) ? Palette.textShade1 : Palette.green),
                                  ],
                                ),

                                Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Container(
                                        decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          sizedBox(4),  
                                          Text('Submitted', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall)),      
                                          // styledText("Submitted", Constants.header1, Constants.lightbg),
                                          sizedBox(8),
                                          Text((list[position].createdOn != 'just now') ? DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].createdOn!)) : 'just now', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)),      
                                          sizedBox(4),
                                        ],
                                      ),
                                  ),
                                ],
                                ),
                          ],),

                          
                        //////////////////////////////////////////////
                        // second row for status : Approved
                        // check if any of the statuses ahead is mentioned and also if rejected by issuer / approver
                        (list[position].requestStatus == Constants.confirmed || list[position].requestStatus == Constants.cancelled) ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // sizedBox(16),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Palette.green,
                                          shape: BoxShape.circle
                                        ),
                                        // margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                        child: Icon(PhosphorIconsRegular.check, color: Palette.white, size: 16,),
                                      ),
                                      
                                      VerticalDottedLine(height: 30, color: Palette.green),
                                      
                                    ],
                                  ),
                                

                                
                                Container(

                                      decoration: const BoxDecoration(
                                      // color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    // margin: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // sizedBox(4),  
                                        Text("Confirmed by ${list[position].adminId}", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium)),
                                        sizedBox(16),
                                        // close the request
                                          // applicable when returned, rejected, and the request is open
                                          (list[position].isOpen == 1 && list[position].requestStatus == Constants.cancelled) ? Container(
                                            alignment: Alignment.centerRight,
                                            child:
                                              !isClosing ? 

                                              InkWell(
                                                onTap: () => onSubmit(context, list[position].appointmentId!, position),
                                                child: Container(
                                                      decoration: BoxDecoration(
                                                      color: Palette.appBackgroundSolitude,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                      border: Border.all(
                                                            color: Palette.appBackgroundSolitude, // Set the color of the border here
                                                            width: 0.5, // Set the width of the border here
                                                          ),
                                                        ),
                                                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                                        child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          // sizedBox(8),
                                                          Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Palette.appPrimary,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                    width: 16,
                                                                    height: 16,
                                                                      alignment: Alignment.center,
                                                                      child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.white, size: 12, ),
                                                                  ),
                                                                  const SizedBox(width: 8,),
                                                                  Text('Close request', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.blue)),
                                                                ],
                                                            )
                                                  ])),
                                              ) :  const AppProgress(height: 30, width: 30,)
                                          ) : sizedBox(0),
                                          
                                      ],
                                    ),
                                ),
                                
                          ],) : Container(
                            // This is to show the waiting status.
                            alignment: Alignment.centerLeft,
                            child: 
                            (list[position].requestStatus == Constants.submitted) ? 
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                sizedBox(16),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Palette.textShade1,
                                    shape: BoxShape.circle
                                  ),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: _animationController,
                                      curve: Curves.easeInOut,
                                      ),
                                    child: Icon(PhosphorIconsRegular.dotsThree, color: Palette.white, size: 16,),
                                  ),
                                ),
                                const SizedBox(width: 16,),
                                Text("Waiting for approval", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall)) 
                              ]
                            )
                            : sizedBox(0),
                          ),
                          
                          

                        //////////////////////////////////////////////
                        // third row for status : Issued 
                        // check if any of the statuses ahead is mentioned and also if rejected by issuer
                        (list[position].requestStatus == Constants.completed) ? Row(
                        // (list[position].requestStatus == Constants.issued && (list[position].requestStatus != Constants.rejected && list[position].requestStatus != Constants.approved) ) ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // sizedBox(16),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Palette.green,
                                          shape: BoxShape.circle
                                        ),
                                        // margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                        child: Icon(PhosphorIconsRegular.check, color: Palette.white, size: 16),
                                      ),
                                      
                                      VerticalDottedLine(height: 60, color: Palette.green),
                                      
                                    ],
                                  ),                  
                                Container(
                                      decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.all(Radius.circular(10))
                                    ),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // sizedBox(4),        
                                        Text("Completed", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall)),
                                        sizedBox(8),
                                        Text('on ${DateFormat('MMM dd, yyyy · hh:mm aa', 'en_US').format(getDate(list[position].updatedOn!))}', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall,)),
                                        // Text('${DateFormat('MMM d, y  -  hh:mm aa', 'en_US').format(getDate(list[position].issuedOn!).toLocal()).toUpperCase()}', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)),
                                        sizedBox(4),
                                        Text('by ${list[position].adminId}', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium)),
                                        sizedBox(4),
                                      ],
                                    ),
                                ),
                                    
                                  
                          ],) : (list[position].requestStatus == Constants.confirmed) ? Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    sizedBox(16),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Palette.textShade1,
                                        shape: BoxShape.circle
                                      ),
                                      child: FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.easeInOut,
                                          ),
                                        child: Icon(PhosphorIconsRegular.dotsThree, color: Palette.white, size: 16,),
                                      ),
                                      // Icon(PhosphorIconsRegular.checkBold, color: Palette.white, size: 16,),
                                    ),
                                    const SizedBox(width: 16,),
                                    // Text("Going to meet in "+ today.difference( getDate(list[position].requestDate!)).inMinutes.toString() + " minutes", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall)),
                                    Text("Meeting in "+ calculateTimeDifference(today,getDate(list[position].requestDate!)), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleSmall)) 
                                  ]
                                )
                                // child: styledText("Waiting for approval! Contact your warden to issue", Constants.special, Constants.lightbg),
                              ) : sizedBox(0),


                            sizedBox(8),
                            
                            
                      ],
                    ),




                        // cancel the request
                        // applicable before returned, and the request is open
                        (list[position].isOpen == 1 ) ? 
                        
                          
                        Container(
                          
                          child:
                            !isClosing ? Column(
                              children: [
                                divider(Palette.textShade2),sizedBox(4),
                                InkWell(
                                  onTap: () => cancelRequest(context, list[position].appointmentId!, position),
                                  child: Container(
                                    
                                        decoration: BoxDecoration(
                                        // color: Palette.appBackgroundSolitudeRed,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(
                                              color: Palette.appBackgroundSolitudeRed, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // sizedBox(8),
                                            
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Palette.red,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      width: 16,
                                                      height: 16,
                                                        alignment: Alignment.center,
                                                        child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.white, size: 12, ),
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('Cancel appointment', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red)),
                                                    // MaterialButton(        
                                                    //       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                                    //       color: Palette.appBackgroundSolitude,
                                                    //       splashColor: Palette.textShade2,
                                                    //       colorBrightness: Brightness.light,
                                                    //       textColor: Palette.primary,
                                                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                          
                                                    //       onPressed: () => onSubmit(context, list[position].appointmentId!, position),
                                                    //       child: Text('Close request', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.blue)),
                                                    // )
                                                  ],
                                              )
                                    ])),
                                ) ]) :  const AppProgress(height: 30, width: 30,)
                            ) : sizedBox(0),
            ]
          ),

          
      // ),
    ),
  );

}

Widget myRequestCardCompleted(int position, BuildContext context){
  return Container(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),

    // add decoration
    child: 
    Container(
      // decoration: BoxDecoration(
      //   color: Theme.of(context).cardColor,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Theme.of(context).shadowColor,
      //       offset: const Offset(0.0, 0.0),
      //       blurRadius: 24.0,
      //       spreadRadius: 0.3,
      //     ),
      //   ]
      // ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              list[position].mode! == 0 ? 
                Container(
                  decoration: const BoxDecoration(
                  color: Color(0xFFE9D8FD),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text('In person', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, letterSpacing:0.5, fontWeight: FontWeight.w500, color: const Color(0xFF4C51BF) )),
                )
                : Container(
                        decoration: const BoxDecoration(
                        color: Color(0xFFFFD6E9),
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text('Virtual meet', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, letterSpacing:0.5, fontWeight: FontWeight.w500, color: const Color(0xFFC53078) )),
                      ),
                    sizedBox(8),
              Row(
                
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: 
                  Container(
                    decoration: BoxDecoration(
            
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    // padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${DateFormat('MMM d, y', 'en_US').format(getDate(list[position].requestDate!)).toUpperCase()}, ${DateFormat().add_jm().format(getDate(list[position].requestDate!)).toUpperCase()}", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text(list[position].description!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium )),
                                  sizedBox(4),
                                  divider(Colors.black12)
                                ],
                              ),
                  ),
                  ),
                ],
              ),
              
              
            ]
          ),

          
      // ),
    ),
  );

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
      list.removeAt(position);
      
      setState(() {
        list = list;
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

// 1 stage
// 2 appointmentId
// 3 collegeId
// 4 adminId
// 5 updatedOn
// 6 playerId
// 7 notes

    // cancel request
  void cancelRequest(BuildContext context, String appointmentId, int position) async {
    setState(() {
      isClosing = true;
    });
    // query parameters    
    Map<String, String> queryParams = {
      // "appointmentId":appointmentId,
      };

    // API call
    //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
    // print("${APIUrls.updateAppointment}${APIUrls.pass}/S4/$appointmentId/$collegeId/-/-/$gcmRegId/Cancelled by $username");
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S4/$appointmentId/-/$collegeId/Cancelled by $username", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      list[position].isOpen = 0;
      
      // list.removeAt(position);
      
      setState(() {
        list = list;
        isDataAvailable = false;
        isClosing = false;
        showCreateCTA = true;
      });

      showToast(context, 'Request cancelled!',Constants.success);
        
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
