import 'dart:convert';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/appointmentdetail_admin.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/modal/appointment.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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

class AppointmentsAdmin extends StatefulWidget {
  const AppointmentsAdmin({Key? key}) : super(key: key);

  @override
  AppointmentsAdminState createState() => AppointmentsAdminState();
}

class AppointmentsAdminState extends State<AppointmentsAdmin> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin<AppointmentsAdmin> {

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
    // if(list.isEmpty) {

      getAppointmentsData();
      // getOfficialDates();
    // }
    
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
      // print("${APIUrls.appointments}${APIUrls.pass}/$role/S1/All/$offset/$collegeId/$campusId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.appointments}${APIUrls.pass}/$role/S1/All/$offset/$collegeId/$campusId", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<Appointment> list1;
      List<Appointment> list2;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['newdata'] as List;
        var requests1 = jsonObject['olddata'] as List;
        
        if(requests.isNotEmpty || requests1.isNotEmpty){
          // convert to list
          list1 = requests.map<Appointment>((json) => Appointment.fromJson(json)).toList();
          list2 = requests1.map<Appointment>((json) => Appointment.fromJson(json)).toList();

          if(list1.isNotEmpty || list2.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              list.clear();
              oldList.clear();
              list.addAll(list1);
              list.addAll(list2);

              // segregate between old and new items
              // for (var element in list1) {
              //   if(element.adminId == '-'){
              //     list.add(element);
                  
              //   }
              //   else {
              //     oldList.add(element);
              //   }
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
        // padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

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
                        
                        // sizedBox(8),
                        // Text('Reach out for help', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium), textAlign: TextAlign.center,), 
                        // sizedBox(8)
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
                      
                      RefreshIndicator(
                        onRefresh: _refreshList,
                        child: 
                        (list.isNotEmpty) ?
                          ListView.builder(

                          // controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          itemBuilder: (context, index){
                            
                            return Container(
                              
                                  child: (list[index].adminId == "-") ? myRequestCard(index, context) : myRequestCardCompleted(index, context),
                                );
                          })
                    
                      
                          :
                          
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // loader while fetching data
                              // isLoading? AppProgress(height: 30, width: 30,) : new SizedBox(height: 0,),
                              Icon(PhosphorIconsRegular.checkCircle),
                              sizedBox(16),
                              Container(
                                alignment: Alignment.center,
                                child: Text('No bookings yet!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText2)), 
                            ),
                            sizedBox(8),
                            
                      ],)
                      )
                     


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
        ]));
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
  return 
  InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetail(appointment: list[position]))).whenComplete(() => { }),
    // onTap: () => (list[position].requestStatus == Constants.completed || list[position].requestStatus == Constants.cancelled) ? null : Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetail(appointment: list[position]))),
    child:
    Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),

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
                    padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${DateFormat('MMM d, y', 'en_US').format(getDate(list[position].requestDate!)).toUpperCase()}, ${DateFormat().add_jm().format(getDate(list[position].requestDate!)).toUpperCase()}", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w600 )),
                                  sizedBox(4),
                                  Text(list[position].description!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium )),
                                  
                                ],
                              ),
                  ),
                  ),
                   (list[position].requestStatus != Constants.completed || list[position].requestStatus != Constants.cancelled || list[position].requestStatus != Constants.inMeeting) ?
                   Container(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        // Icon(PhosphorIconsRegular.dot, color: Palette.appPrimary, size: 16, ),
                                        // const SizedBox(width: 8,),
                                        Text('Edit', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary)),
                                        
                                      ],
                                  )
                        ]),
                    ) : sizedBox(0),
                ],
              ),
              // divider(Palette.textShade2),sizedBox(4),
              divider(Colors.black12),sizedBox(4),
              
                        // cancel the request
                        // applicable before returned, and the request is open
                        (list[position].isOpen == 1 ) ? 
                        
                          
                        Container(
                          
                          child:
                            !isClosing ? Row(

                              children: [
                                
                                InkWell(
                                  onTap: () => acceptRequest(context, list[position].appointmentId!, list[position].collegeId!, position),
                                  child: Container(
                                        decoration: BoxDecoration(
                                              // color: Palette.appBackgroundSolitudeRed,
                                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                                              border: Border.all(
                                              color: Palette.appPrimary, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(PhosphorIconsRegular.check, color: Palette.appPrimary, size: 16, ),
                                                    const SizedBox(width: 8,),
                                                    Text('Accept', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary)),
                                                  ],
                                              )
                                    ])),
                                ),
                                SizedBox(width: 8,),
                                InkWell(
                                  onTap: () => cancelRequest(context, list[position].appointmentId!, position),
                                  child: Container(
                                        decoration: BoxDecoration(
                                        // color: Palette.appBackgroundSolitudeRed,
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        border: Border.all(
                                              color: Palette.red, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(PhosphorIconsRegular.x, color: Palette.red, size: 16, ),
                                                    const SizedBox(width: 8,),
                                                    Text('Cancel', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red)),
                                                  ],
                                              )
                                    ])),
                                )
                                
                                 ]) :  const AppProgress(height: 30, width: 30,)
                            ) : sizedBox(0),
            ]
          ),

          
      // ),
    ),
  )
  );

}

Widget myRequestCardCompleted(int position, BuildContext context){
  return 
  InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetail(appointment: list[position]))).whenComplete(() => { }),
    // onTap: () => (list[position].requestStatus == Constants.completed || list[position].requestStatus == Constants.cancelled) ? null : Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetail(appointment: list[position]))),
    child:
  Container(
    // padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),

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

                                  Row(children: [
                                    Icon((list[position].requestStatus! == Constants.completed) ? PhosphorIconsRegular.check : (list[position].requestStatus! == Constants.cancelled) ? PhosphorIconsRegular.x : PhosphorIconsRegular.clock, size: 16,),
                                    SizedBox(width: 8,),
                                    Text(list[position].requestStatus!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium )),
                                  ],),
                                  
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
  )
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
    // Accept request
  void acceptRequest(BuildContext context, String appointmentId, String studentId, int position) async {
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
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S1/$appointmentId/$collegeId/$username/$today/$studentId", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      list[position].adminId = collegeId;
      list[position].adminName = username;
      list[position].requestStatus = Constants.confirmed;
      
      // list.removeAt(position);
      
      setState(() {
        list = list;
        isDataAvailable = false;
        isClosing = false;
        
      });

      showToast(context, 'Booking accepted!',Constants.success);
        
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
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S4/$appointmentId/$collegeId/-/$today/$gcmRegId/Cancelled by $username", queryParams)), headers: {"Accept": "application/json"});
    
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
