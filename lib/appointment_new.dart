import 'dart:convert';
import 'dart:ui';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/modal/admin_user.dart';
import 'package:psych_app/modal/timeslot.dart';
import 'package:psych_app/util/divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/util/api_urls.dart';
// import 'package:psych_app/util/appheader.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/show_toast.dart';
// import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' show get;
import 'package:psych_app/util/progress.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/utils.dart';
import 'package:psych_app/util/constants.dart' as Constants;

class AppointmentNew extends StatefulWidget {

  @override
  AppointmentNewState createState() => AppointmentNewState();


    // final List<DateTime> allowedDates;
    // final List<DateTime> blockedDates;

    // AppointmentNew();
}
List<DateTime> blockedDates1 = [];
List<DateTime> allowedDates1 = [];

class AppointmentNewState extends State<AppointmentNew> with SingleTickerProviderStateMixin {

  final formKey = GlobalKey<FormState>(); // this is global key to validate form
  final formKey1 = GlobalKey<FormState>(); // this is global key to validate form

  TextEditingController descriptionController = new TextEditingController();
  TextEditingController vNameController = new TextEditingController();
  TextEditingController vPhoneController = new TextEditingController();
  // dates
  DateTime today = DateTime.now();
  DateTime fromDate = DateTime.now();
  TimeOfDay? fromTime, toTime;
  DateTime toDate = DateTime.now().add(const Duration(days: 1));
  int? days = 2, year;
  String? universityId, campusId,collegeId, username, branch, description = '', errorMsg = '', role='';
  String? fatherName='',fatherPhoneNumber = '';
  String? motherName='',motherPhoneNumber = '';
  String? guardianName='',guardianPhoneNumber = '',guardian2Name='',guardian2PhoneNumber = '', parentNumber = '';
  bool isLoading = false;
  int foodCount = 0;
  int isAllowed = 1;
  bool isDataAvailable = false;
  String emptyStateMsg = '';
  List<AdminUser> list = [];
  List<AdminUser> oldList = [];
  List<TimeSlot> timeSlotslist = [];
  late AdminUser selectedAdminUser;
  bool adminSelected = false;
  int selectedTimeSlotIndex = 0;
  TimeSlot? selectedSlot;
  bool gettingDates = false;

  // String appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now()).toString();
  

  bool checkBlockedDates = false; // check blocked dates always the user gets to this page.
  int _selectedValue = 1;
  // audio element to play sound
  AudioPlayer player = AudioPlayer();

  late AnimationController _animationController;
  late Animation<double> _animation, sizeAnimation;
  bool containerWidth = true;
  bool connectionStatus = true;


  // List<Visitor> visitors = [];
  // List<Visitor> selectedVisitors = [];
  // List<Visitor> ActualSelectedVisitors = [];
  


  @override
  void initState(){

    // fetch requests
    getUserData();
    fromTime = const TimeOfDay(hour: 6, minute: 0);
    toTime = const TimeOfDay(hour: 18, minute: 0);
    
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 800),vsync: this,);
    _animation = CurvedAnimation(parent: _animationController,curve: Curves.bounceIn,);
    _animation = Tween<double>(begin: 100, end: 300).animate(_animationController)
    ..addListener(() {
        setState(() {});
      });

    // _animationController.forward();
  }

  // get user related data
  void getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // get the userObjectId from storage
    if(preferences.containsKey(Constants.universityId)){
      
      setState(() {
        universityId = preferences.getString(Constants.universityId);  
        campusId = preferences.getString(Constants.campusId);  
        collegeId = preferences.getString(Constants.collegeId);  
        username = preferences.getString(Constants.username);  
        branch = preferences.getString(Constants.branch);  
        year = preferences.getInt(Constants.year);  
        role = preferences.getString(Constants.role);
        fatherName = preferences.getString(Constants.fatherName);
        fatherPhoneNumber = preferences.getString(Constants.fatherPhoneNumber);
        motherName = preferences.getString(Constants.motherName);
        motherPhoneNumber = preferences.getString(Constants.motherPhoneNumber);
        guardianName = preferences.getString(Constants.guardianName);
        guardianPhoneNumber = preferences.getString(Constants.guardianPhoneNumber);
        guardian2Name = preferences.getString(Constants.guardian2Name);
        guardian2PhoneNumber = preferences.getString(Constants.guardian2PhoneNumber);
    
      });
    }

    getAvailableAdminsData();
    
  }

  void refreshWidget(){
    setState(() {
      
    });
  }

  void getAvailableAdminsData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        isLoading = true;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};

      // API call
      // print("${APIUrls.calendar}${APIUrls.pass}/$role/1/$collegeId/$campusId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.calendar}${APIUrls.pass}/$role/1/$collegeId/$campusId", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<AdminUser> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<AdminUser>((json) => AdminUser.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              list.clear();
              oldList.clear();
              list.addAll(list1);

              
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
            getAvailableAdminsData();
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

  // get free slots of selceted Admin
  void getAdminFreeSlotsData() async {

    if(await checkInternetConnectivity()){
      
      // set connection status variable to true
      setState(() {
        connectionStatus = true;
        gettingDates = true;
      });
      

      // query parameters    
      Map<String, String> queryParams = {};


      // add time to the date
      DateTime fromDate1 = DateTime(
        fromDate.year,
        fromDate.month,
        fromDate.day,
        fromTime!.hour,
        fromTime!.minute,
      );

      // API call
      // print("${APIUrls.calendar}${APIUrls.pass}/$role/2/${selectedAdminUser.collegeId}/${DateFormat('EEEE', 'en_US').format(fromDate1)}/${DateFormat('yyyy-MM-dd', 'en_US').format(fromDate1)}/$campusId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.calendar}${APIUrls.pass}/$role/2/${selectedAdminUser.collegeId}/${DateFormat('EEEE', 'en_US').format(fromDate1)}/${DateFormat('yyyy-MM-dd', 'en_US').format(fromDate1)}/$campusId", queryParams)), headers: {"Accept": "application/json"});
      // print(result.body);
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<TimeSlot> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var requests = jsonObject['data'] as List;

        if(requests.isNotEmpty){
          // convert to list
          list1 = requests.map<TimeSlot>((json) => TimeSlot.fromJson(json)).toList();

          if(list1.isNotEmpty){
            // update the list items and toggle the loading
            setState(() {
              timeSlotslist.clear();
              timeSlotslist.addAll(list1);

              
              gettingDates = false;
              isDataAvailable = true;
            });
          }
          else {
            // no requests
            setState(() {
              timeSlotslist.clear();
              emptyStateMsg = 'No pending requests';
              gettingDates = false;
              isDataAvailable = false;
            });
          }

        }
        else {
          // no requests
          setState(() {
            timeSlotslist.clear();
            emptyStateMsg = 'No pending requests';
            gettingDates = false;
            isDataAvailable = false;
          });
        }

      
      }
      else {
          // no requests
          setState(() {
            emptyStateMsg = 'No pending requests';
            timeSlotslist.clear();
            gettingDates = false;
            isDataAvailable = false;
          });
        }
    }
    else {
        Future.delayed(const Duration(seconds: 2), () {

          // this is to check for retrying only once more. Else it will end the loop
          if(connectionStatus)
          {
            getAdminFreeSlotsData();
            // print('Again trying');
          
            // set the connection Status variable to false
            setState(() {
              connectionStatus = false;
              gettingDates = false;
              isDataAvailable = false;
            });
          }
        });
      }
  }
  

  void selectedAdmin(AdminUser adminUser){
    
    setState(() {
      selectedAdminUser = adminUser;
      adminSelected = true;  
    });
    
  }
  
  @override
  Widget build(BuildContext context) {
    
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
                    // Colors.white.withOpacity(0.3),

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
    // Scaffold(
      
    //         // backgroundColor: Palette.transparent,
    //         body: SafeArea(
              child: 
              SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                children: [
                  
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    
                  //   children: [ 
                  //       Container(
                  //         padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  //         child: Text('Book appointment'),
                  //       ),
                  //       IconButton(
                  //       onPressed: () => Navigator.pop(context),
                        
                  //       iconSize: 36.0,
                  //       icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular), size: 24.0, color: Palette.textShade1),
                  //       color: Palette.primary,
                  //     ),
                        
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
                        Text('Book Appointment', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                        InkWell(
                            onTap: () => 

                                // show dialog to confirm exit
                                Navigator.pop(context)
                              ,
                            child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(PhosphorIconsBold.x),
                          ),
                        )
                        
                      ],),
                        
                        sizedBox(8),
                        // Text('Monitor regularly to know and act on your emotions', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium), textAlign: TextAlign.center,), 
                        // sizedBox(8)
                      ],
                    ),
              ),

                  sizedBox(8),
                  InkWell(
                    onTap: () {
                      // isDataAvailable ? showAdminUsersList(context) : ''; 
                      list.isNotEmpty ? showAdminUsersList(context) : '';
                    },
                    child: 

                            Container(
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 4),
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                              decoration: BoxDecoration(
                                    color: const Color(0x66FFFFFF),
                                    border: Border.all(color: const Color(0xFFFFFFFF)),
                                    // color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
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
                              child: 
                              Column(
                                children: [
                                  
                                  (adminSelected) ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      // Container(
                                      //   height: 40, 
                                      //   width: 40, 
                                      //   alignment: Alignment.center,
                                      //   //child: list[position].mediaCount == 0 ? Image.network(list[position].userImage) : Text('KP'), 
                                      //   //child: list[position].mediaCount == 0 ? Image.network('https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png') : styledText(getAcronym(list[position].username), Constants.header3, Constants.lightbg), 
                                        
                                      //   decoration: BoxDecoration(
                                      //     shape: BoxShape.circle, 
                                      //     color: Palette.appBackgroundSolitude),
                                      //     child: selectedAdminUser.userImage!.length > 3 ? 
                                      //       // Image.network('https://smartcampusweb.vercel.app/user_sample.jpeg')
                                      //       // Image.network(requestItem.userImage!)
                                      //       Container(
                                      //             width: 200,
                                      //             height: 200,
                                      //             decoration: BoxDecoration(
                                      //               shape: BoxShape.circle,
                                      //               image: DecorationImage(
                                      //                 fit: BoxFit.cover,
                                      //                 image: NetworkImage(selectedAdminUser.userImage!),
                                      //               ),
                                      //             ),
                                      //           ) 
                                      //           : 
                                      //       Text(getAcronym(selectedAdminUser.username!).toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.black )), 
                                          
                                      //     ),
                                      
                                      
                                      Expanded(
                                        child: Container(
                                          // padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                                        decoration: const BoxDecoration(),
                                        child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Text(selectedAdminUser.username!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.bold)),
                                                    
                                                    
                                                    // Row(children: [
                                                    //   Text("${requestItem.collegeId!}  |  ", style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall,)),
                                                    //   Text(requestItem.branch!, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall,)),
                                                    //   Text((requestItem.year != 0) ? "  |  ${requestItem.year} year" : "", style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall,)),
                                                    //   // Container(
                                                    //   //   padding: EdgeInsets.all(2),
                                                    //   //   decoration: BoxDecoration(
                                                    //   //     // color: Theme.of(context).shadowColor,
                                                    //   //   borderRadius: BorderRadius.all(Radius.circular(4)),
                                                    //   //   shape: BoxShape.rectangle, 
                                                    //   //   color: Palette.appBackgroundSolitude),
                                                    //   //   child: Text((list[position].outingType!.toLowerCase() == 'yes') ? 'Self permitted' : 'Not self permitted', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall,)),
                                                    //   // ),
                                                      
                                                    // ],),
                                                    
                                                    // Container(
                                                    //     padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                                                    //     decoration: BoxDecoration(
                                                    //       // color: Theme.of(context).shadowColor,
                                                    //     borderRadius: const BorderRadius.all(Radius.circular(4)),
                                                    //     shape: BoxShape.rectangle, 
                                                    //     color: Palette.appBackgroundSolitude),
                                                    //     child: Text((requestItem.outingType!.toLowerCase() == 'yes') ? 'Self permitted' : 'Not self permitted', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: (requestItem.outingType!.toLowerCase() == 'yes') ? Palette.green : Palette.red,)),
                                                    //   ),
                                                    //   sizedBox(4),

                                                      
                                                    
                                                  ],
                                        ),),),

                                        Icon(PhosphorIconsRegular.arrowRight)
                                      ],
                                    ) : 

                                  Row(
                                    children: [
                                      Text('Select a Psychologist', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w500, color: Color(0xFF6302E5))),
                                      isLoading ? AppProgress(height: 24, width: 24) : sizedBox(0)
                                    ],
                                  )
                                ],
                              )
                              
                              
                            ),
                  ),          
                  sizedBox(8),
                  
                  (adminSelected) ?
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                    child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      
                      // Expanded(
                      //   flex: 1,
                      //   child: 
                        InkWell(
                          onTap: () => _selectAppointmentDate(context),
                          
                          child: 

                          Container(
                            
                            decoration: BoxDecoration(
                                  color: const Color(0x66FFFFFF),
                                  border: Border.all(color: const Color(0xFFFFFFFF)),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xCCFFFFFF),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 24.0,
                                      spreadRadius: 0.3,
                                    ),
                                  ]
                                ),
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.all(8.0),
                            // padding: const EdgeInsets.all(8.0),
                            
                            child: Column(
                              children: [
                                checkBlockedDates ? 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    
                                    Column(
                                      children: [
                                        Container(
                                          // width: 48,
                                          // height: 48,
                                            alignment: Alignment.center,
                                            child: Icon(PhosphorIconsLight.calendarPlus, size: 32.0, color: Colors.pink),
                                        ),
                                        
                                      ],
                                    ),
                                    
                                    const SizedBox(width: 8,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          // Text(appointmentDate, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold, fontSize: 24)),
                                          Text(DateFormat('MMMM dd yyyy', 'en_US').format(fromDate), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8),
                                          Text(DateFormat('EEEE', 'en_US').format(fromDate).toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, letterSpacing: 1)),
                                        ],
                                      ),
                                    
                                  ],
                                ) : 
                                Row(
                                    children: [
                                      Text('Select a date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.w500, color: Color(0xFF6302E5))),
                                      isLoading ? AppProgress(height: 24, width: 24) : sizedBox(0)
                                    ],
                                  )
                              ]
                            )
                            
                          )
                          // : const AppProgress(height: 30, width: 30,),
                        ), 
                        
                      (timeSlotslist.isNotEmpty && !gettingDates ) ?
                        InkWell(
                          onTap: () async  { 
                                var selectedTime = await _selectedTime(context, fromTime!); 
                                setState(() {
                                  if(selectedTime!=null)
                                    fromTime = selectedTime;
                                });
                                
                              },
                          child:  Container(

                            margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                          color: const Color(0x66FFFFFF),
                          border: Border.all(color: const Color(0xFFFFFFFF)),
                          // color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12),
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
                            child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Icon(PhosphorIconsLight.clock, size: 32.0, color: Colors.pink),
                                            SizedBox(width: 8,),
                                            Text('Select a Time Slot:', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold)),
                                        ]
                                    ),
                                                      
                                    
                                    SizedBox(height: 8),
                                    ...timeSlotslist.map<Widget>((TimeSlot slot) {
                                      return RadioListTile<TimeSlot>(
                                        title: Text('${slot.start} - ${slot.end}'),
                                        value: slot,
                                        groupValue: selectedSlot,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedSlot = value!;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ],
                                )
                              
                          )
                            )
                            
                            : 
                            (gettingDates) ? AppProgress(height: 24, width: 24) :
                            (checkBlockedDates ) ? Text('No free slots available. Choose another date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontWeight: FontWeight.bold))
                             : sizedBox(0),
                        // ),
                      ],
                        
                  ),
                  ) : sizedBox(0),
                  sizedBox(8),
                  

                  Container(
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    decoration: BoxDecoration(
                          color: const Color(0x66FFFFFF),
                          border: Border.all(color: const Color(0xFFFFFFFF)),
                          // color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12),
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
                    child: TextFormField(
                          style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                          controller: descriptionController,
                          minLines: 4,
                          maxLines: 6,
                          // maxLength: 120,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            fillColor: Color(0xCCFFFFFF),
                            border: InputBorder.none,
                            hintText:  'Type what you are feeling or reason for appointment',
                            // hintText: (_selectedValue == 1) ? 'Reason and going with' : (_selectedValue == 2) ? 'Reason and place of visit' : 'Reason and place of stay',
                              ),
                          validator: (value) { // validator function is called on calling form validate() method
                            if (value!.isEmpty) {
                              return 'Type why you want to talk';
                            }
                            return null;
                          },
                          //onSaved: (value) => description = value,
                        ),
                  ),
                  
                  
                  sizedBox(8),
                  
                  
                  
                  
                  // isLoading? sizedBox(0) : InkWell(
                  //     onTap: () => {
                         
                  //       // _thanksDialog(context)
                  //       onSubmit(context)
                  //       },
                  //     child:  Container(
                  //         padding: EdgeInsets.all(16),
                  //         margin: EdgeInsets.all(16),
                  //         decoration: BoxDecoration(
                  //                 color: const Color(0x66FFFFFF),
                  //                 border: Border.all(color: const Color(0xFFFFFFFF)),
                  //                 // color: Color(0xFFFFFFFF),
                  //                 borderRadius: BorderRadius.circular(50),
                  //                 boxShadow: const [
                  //                   BoxShadow(
                  //                     // color: Colors.black26,
                  //                     color: Color(0xCCFFFFFF),
                  //                     // color: Color(0xFF080B23),
                  //                     offset: Offset(0.0, 0.0),
                  //                     blurRadius: 24.0,
                  //                     spreadRadius: 0.3,
                  //                   ),
                  //                 ]
                  //               ),
                  //               child:  Row(
                  //                       mainAxisAlignment: MainAxisAlignment.center,
                  //                       children: [
                  //                         // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                  //                         Icon(PhosphorIconsRegular.arrowRight, color: Colors.pink, size: 18,),
                  //                         const SizedBox(width: 8,),
                  //                         Text('Book Appointment', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.pink)),
                  //                       ],
                  //                   )
                  //       ),
                  //   ),

                    (timeSlotslist.isEmpty && selectedSlot!=null)? sizedBox(0) : 
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
                              onSubmit(context);
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
                                          Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 24,),
                                          const SizedBox(width: 8,),
                                          Text('Book a slot', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                        ],
                                    )
                            ),
                          ),
                      ),

                   

                  isLoading? const AppProgress(height: 30, width: 30,) : sizedBox(0),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Text('Your personal information will never be shared to anyone. We take your wellness as our top most priority.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge)),
                    // Text('Your personal information will never be shared to anyone. We take your wellness as our top most priority.', style: TextStyle(fontWeight: FontWeight.w600, ),),
                  ),

                  

                ],
              ),
            ),
            ),
            )
            )])
    );
  }


  // on subitting values
    void onSubmit(BuildContext context1){
      // add time to the date
    
      // validate() methods call the validator functions for all form elements
      if(formKey.currentState!.validate()){ 
        formKey.currentState!.save();

        submitRequest();
        // // verify if this request duration contains any of blocked dates
        // if(isAllowed) {
        //    submitRequest();
        // }
        // else {
        //   // _displayDialog(context1);
        // }
        

      }
      else {
        setState(() {
          //errorMsg = 'Please provide your details';
        });
      }

    }


  showAdminUsersList(BuildContext context){
    showModalBottomSheet(
      //enableDrag: true,
      isScrollControlled: true,
      // backgroundColor: Palette.white,
        context: context,
        builder: (BuildContext context){
          return 
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              sizedBox(64),
              // Container(
              //   alignment: Alignment.center,
              //   height: 1.0,
              //   // width: 40.0,
              //   decoration: BoxDecoration(
              //     color: Colors.black12,
              //     borderRadius: const BorderRadius.all(Radius.circular(10)),
              //   ),
              //   margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              // ),
              sizedBox(32),

              Expanded(
                child: 
                Column(
                  children: list.map((e) => 
                  InkWell(
                    onTap: () {
                      selectedAdmin(e);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Text(e.username!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, color: Color(0xFF6302E5))),
                        ),
                        
                        divider(Colors.black12),
                      ],
                    )
                    
                  )
                  ).toList(),
                )
              
              ),
                

              sizedBox(32),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: <Widget>[
                //       MaterialButton(
                //         child: Text("Select", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.blue)),
                //         padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                //         color: Palette.appBackgroundSolitude,
                //         textColor: Palette.black,
                //         splashColor: Palette.textShade2,
                //         colorBrightness: Brightness.light,
                //         shape: const StadiumBorder(),
                //         onPressed: () => Navigator.pop(context),

                //       )

                //     ],
                //   ),
                
                sizedBox(16),
                sizedBox(32),
            ],
          );
          
          
          
        }
    );
  }

// get the selected time
Future<TimeOfDay?> _selectedTime(BuildContext context, TimeOfDay time) => showTimePicker(
  context: context,
  initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
  
);



  


    // submit request
  void submitRequest() async {

      
    // query parameters    
    Map<String, String> queryParams = {
      };

      var A = randomString("A");

    // add time to the date
    DateTime fromDate1 = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
      int.parse(selectedSlot!.start.split(':')[0]),
      int.parse(selectedSlot!.start.split(':')[1]),
      // fromTime!.hour,
      // fromTime!.minute,
    );

    
        // show the loader
        setState(() {
          isLoading = true;
        });


        Map<String, dynamic> queryParams1 = {
        "appointmentId":A,
        "collegeId":collegeId!,
        "adminId":'-',
        "adminName": '-',
        "topic":'-',
        "description":descriptionController.text,
        "requestDate":DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(fromDate1),
        "startTime":selectedSlot!.start,
        "endTime":selectedSlot!.end,
        "isOpen":1.toString(),
        "requestStatus":Constants.submitted,
        "notes": '-',
        "mode": 0,
        "createdOn": DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today),
        // "count":selectedVisitors.length.toString(),
        "updatedOn": '-',
        "campusId":campusId!,
        // "visitors": selectedVisitors,
        // "isAllowed": isAllowed ? '0' : '1',
        };

      // API call
      // print("${APIUrls.newVisitorpass}${APIUrls.pass}/$V/$userObjectId/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(fromDate1)}/${Uri.encodeComponent(descriptionController.text)}/${selectedVisitors.length}/$foodCount/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$visitorsList/$isAllowed/$username/$parentNumber");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.newAppointment}${APIUrls.pass}/$A/$collegeId/-/${Uri.encodeComponent(descriptionController.text)}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(fromDate1)}/${selectedSlot!.start}/${selectedSlot!.end}/0/$campusId", queryParams)), headers: {"Accept": "application/json"});
      
      // print(result);
      // print(APIUrls.getUrl(APIUrls.newRequest, queryParams));
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      // check if the api returned success
      if(jsonObject['status'] == 200){
        
        // pass the data back to display
        setState(() {
          isLoading = false;
          // submitted = true;
        });
        // _animationController.forward();
        
        // play the sound
        player.setAsset('assets/outgoing.mp3');
        player.play();
        Navigator.pop(context, queryParams1);

        // show the success animation
        // Future.delayed(const Duration(seconds: 2), () {
        //   setState(() {
        //     Navigator.pop(context, queryParams1);
        //   });
        // });
        
          
      }
      else {
        // update the list items and toggle the loading
      setState(() {
        isLoading = false;
        errorMsg = jsonObject['message'];
        showToast(context, jsonObject['message'],Constants.error);  
      });
      }
   
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
                          Text('Select a date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.bold)),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                  sizedBox(16),
                  
                  SfDateRangePicker(
                    selectionColor: Colors.pink,
                    todayHighlightColor: Colors.pink,
                    
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.single,
                    minDate: DateTime.now(),
                    initialSelectedDate: DateTime.parse(DateFormat('yyyy-MM-dd', 'en_US').format(fromDate).toString()),
                    // initialSelectedDate: DateTime.parse(appointmentDate),
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      // set the date to call the stats again
                      setState(() {
                        fromDate = args.value;
                        checkBlockedDates = true;
                        // appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(args.value).toString();
                      },
                      
                        
                      );
                    },
                  ),


                 MaterialButton(
                      padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                      color: Color(0xFF6302E5),
                      splashColor: Palette.textShade2,
                      colorBrightness: Brightness.light,
                      elevation: 2,
                      highlightElevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
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
                          
                          checkBlockedDates = true;
                          getAdminFreeSlotsData();
                          Navigator.pop(context);
                      },
                      child: Text('Select date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.white),),
                    ),
                    sizedBox(16),
              ],)
              
            )
        );
        

    });
  }

}