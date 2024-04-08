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
import 'package:psych_app/modal/appointment.dart';
import 'package:psych_app/util/divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/appheader1.dart';
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

class AppointmentDetail extends StatefulWidget {
  final Appointment appointment;

  AppointmentDetail({required this.appointment});

  @override
  AppointmentDetailState createState() => AppointmentDetailState();
}

class AppointmentDetailState extends State<AppointmentDetail> with SingleTickerProviderStateMixin {

  final formKey = GlobalKey<FormState>(); // this is global key to validate form
  final formKey1 = GlobalKey<FormState>(); // this is global key to validate form

  TextEditingController descriptionController = new TextEditingController();
  TextEditingController vNameController = new TextEditingController();
  TextEditingController vPhoneController = new TextEditingController();
  // dates
  DateTime today = DateTime.now();
  // DateTime fromDate = DateTime.now();
  // TimeOfDay? fromTime, toTime;
  DateTime? changedDate = DateTime.now();
  TimeOfDay? changedTime;
  DateTime toDate = DateTime.now().add(const Duration(days: 1));
  int? days = 2, year;
  String? universityId, collegeId, campusId, username, branch, description = '', errorMsg = '', role='';
  String? fatherName='',fatherPhoneNumber = '';
  String? motherName='',motherPhoneNumber = '';
  String? guardianName='',guardianPhoneNumber = '',guardian2Name='',guardian2PhoneNumber = '', parentNumber = '';
  bool isLoading = false;
  int foodCount = 0;
  int isAllowed = 1;
  bool changeSchedule = false;

  
  bool isDataAvailable = false;
  bool showWarning = false;
  bool isClosing = false;

  List<Appointment> list = [];
  late Appointment currentAppointment;

  // connection status
  bool connectionStatus = true;

  // String appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now()).toString();
  

  bool checkBlockedDates = true; // check blocked dates always the user gets to this page.
  int _selectedValue = 1;
  // audio element to play sound
  AudioPlayer player = AudioPlayer();

  late AnimationController _animationController;
  late Animation<double> _animation, sizeAnimation;
  bool containerWidth = true;

  bool submitted = false;

  @override
  void initState(){

    // fetch requests
    getUserData();
    setState(() {
      currentAppointment = widget.appointment;
      changedDate = getDate(widget.appointment.requestDate!);
      changedTime = getTime(widget.appointment.requestDate!);

    });
    // fromTime = const TimeOfDay(hour: 6, minute: 0);
    // toTime = const TimeOfDay(hour: 18, minute: 0);
    
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
        collegeId = preferences.getString(Constants.collegeId);  
        campusId = preferences.getString(Constants.campusId);  
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

        // visitors.add(Visitor(name:fatherName,phoneNumber: fatherPhoneNumber,relation: 'Father'));
        
        // (motherName!.length > 1) ? visitors.add(Visitor(name:motherName,phoneNumber: motherPhoneNumber,relation: 'Mother')) : null;
        // (guardianName!.length > 1) ? visitors.add(Visitor(name:guardianName,phoneNumber: guardianPhoneNumber,relation: 'Guardian')) : null;
        // (guardian2Name!.length > 1) ? visitors.add(Visitor(name:guardian2Name,phoneNumber: guardian2PhoneNumber,relation: 'Guardian 2')) : null;
    
      });
    }

    // get official dates to show in the calendar
    // getOfficialDates();
    // blockedDates1 = widget.blockedDates;
    // allowedDates1 = widget.allowedDates;
  }

  void refreshWidget(){
    setState(() {
      
    });
  }

// add and remove the selected branches from the list
// void onVisitorSelected(Visitor option) {

//   setState(() {
//     if (selectedVisitors.contains(option)) {
//       foodCount = selectedVisitors.length - 1;
//       selectedVisitors.remove(option);

//       if(option.relation == 'Father' || option.relation == 'Mother' || option.relation == 'Guardian' || option.relation == 'Guardian 2'){
//         ActualSelectedVisitors.remove(option);
//       }
//     } else {
//       // foodCount = selectedVisitors.length + 1;
//       selectedVisitors.add(option);
      
//       if(option.relation == 'Father' || option.relation == 'Mother' || option.relation == 'Guardian' || option.relation == 'Guardian 2'){
//         ActualSelectedVisitors.add(option);
//       }
      
//     }
//   });
// }



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
              submitted ? 
              Container(
                color: Palette.black,
                child:                  
                    Center(
                      child: Stack(
                              // alignment: Alignment.center,
                                children: [
                                  
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        width: _animation.value,
                                        height: _animation.value,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Palette.appPrimary,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin: const EdgeInsets.all(64),
                                        padding: const EdgeInsets.all(64),
                                        width: _animation.value,
                                        height: _animation.value,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Palette.appPrimary,
                                          border: Border.all(
                                                    color: Palette.black,
                                                    width: 1,
                                                  ),
                                        ),
                                      )
                                      ),
                                     Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin: const EdgeInsets.all(84),
                                        padding: const EdgeInsets.all(84),
                                        width: _animation.value,
                                        height: _animation.value,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Palette.appPrimaryDark,
                                        ),
                                      )
                                    ),
                                     Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        margin: const EdgeInsets.all(128),
                                        // padding: const EdgeInsets.all(128),
                                        width: _animation.value - 80,
                                        height: _animation.value - 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Palette.black,
                                        ),
                                        child: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.regular), color: Palette.white, size: (_animation.value-100)/3,),
                                      )
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        margin: const EdgeInsets.all(84),
                                        child: Text('Booking request is submitted!', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.white)),
                                      )
                                    ),
                                ],
                              ),
                            ),
                         
              )
             :
              SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                children: [
                  
              Container(
                margin: const EdgeInsets.all(16),
                child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Appointment Details', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)),  
                        IconButton(
                        onPressed: () => Navigator.pop(context),
                        
                        iconSize: 36.0,
                        icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular), size: 24.0, color: Palette.black),
                        color: Palette.primary,
                      ),
                      ],),
                        
                        // sizedBox(8),
                        // Text('Your data is encrypted and is private', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],
                    ),
              ),


                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    
                  //   children: [ 
                      
                  //       Container(
                  //         padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  //         child: AppHeader1('Appointment Details', ' ', 0, connectionStatus),
                  //       ),
                  //       IconButton(
                  //       onPressed: () => Navigator.pop(context),
                        
                  //       iconSize: 36.0,
                  //       icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular), size: 24.0, color: Palette.black),
                  //       color: Palette.primary,
                  //     ),
                        
                  //     ],
                  //   ),
                  sizedBox(8),
Container(

    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),

    // add decoration
    child: 
    Container(
       decoration: BoxDecoration(
                                    color: const Color(0x66FFFFFF),
                                    border: Border.all(color: const Color(0xFFFFFFFF)),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              Row(
                
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: 
                  Container(
                    decoration: const BoxDecoration(
            
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //         color: Palette.lightBackground,
                                      //         shape: BoxShape.circle,
                                      //       ),
                                      //     width: 48,
                                      //     height: 48,
                                      //       alignment: Alignment.center,
                                      //       child: Icon(PhosphorIconsRegular.calendarBlank, size: 24.0, color: Palette.appPrimary),
                                      //   ),
                                        Icon(PhosphorIconsRegular.calendarBlank, size: 24.0, color: Colors.black45),
                                        const SizedBox(width: 16,),
                                        Expanded(child: 
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(DateFormat('EEEE, MMM d, y', 'en_US').format(changedDate!), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                              // sizedBox(4),
                                              // Text(DateFormat().add_jm().format(getDate(widget.appointment.requestDate!)).toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                            ],
                                          )
                                        ),
                                        (widget.appointment.requestStatus == Constants.submitted || widget.appointment.requestStatus == Constants.confirmed) ?
                                        InkWell(
                                          onTap: () => _selectAppointmentDate(context),
                                          child: Text('Edit', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary )),
                                        ) : sizedBox(0)
                                    ],
                                  ),
                                 sizedBox(8),
                                  divider(Palette.textShade2),
                                  sizedBox(8),
                                  Row(
                                    children: [
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //         color: Palette.lightBackground,
                                      //         shape: BoxShape.circle,
                                      //       ),
                                      //     width: 48,
                                      //     height: 48,
                                      //       alignment: Alignment.center,
                                      //       child: Icon(PhosphorIconsRegular.watch, size: 24.0, color: Palette.appPrimary),
                                      //   ),
                                        Icon(PhosphorIconsRegular.watch, size: 24.0, color: Colors.black45),
                                        const SizedBox(width: 16,),
                                        Expanded(child: 
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Text(DateFormat('EEEE, MMM d, y', 'en_US').format(getDate(widget.appointment.requestDate!)), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                              // sizedBox(4),
                                              Text(changedTime!.format(context), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                              
                                            ],
                                          )
                                        ),
                                        (widget.appointment.requestStatus == Constants.submitted || widget.appointment.requestStatus == Constants.confirmed) ?
                                        InkWell(
                                          onTap: () async  { 
                                            var selectedTime = await _selectedTime(context, getTime(widget.appointment.requestDate!)); 
                                            setState(() {
                                              if(selectedTime!=null){
                                                changeSchedule = true;
                                                changedTime = selectedTime;
                                              }
                                            });
                                            
                                          },
                                          child: Text('Edit', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary )),
                                        ) : sizedBox(0)
                                    ],
                                  ),
                                 
                                  
                                  sizedBox(8),
                                  divider(Palette.textShade2),
                                  sizedBox(8),
                                  Text(widget.appointment.description!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                  sizedBox(8),
                                  divider(Palette.textShade2),
                                  sizedBox(8),
                                  Row(
                                    children: [
                                      Text('Meeting: ', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge )),
                                      widget.appointment.mode! == 0 ? 
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
                                            
                                    ],
                                  ),
                                  sizedBox(8),
                                  // divider(Palette.textShade2),
                                  // sizedBox(8),
                                  
                                ],
                              ),
                  ),
                  ),
                ],
              ),
              
              
                        // cancel the request
                        // applicable before returned, and the request is open
                        // (widget.appointment.isOpen == 1 ) ? 
                        
                          
                        // Container(
                          
                        //   child:
                        //     !isClosing ? Row(
                        //       children: [
                                
                        //         (changeSchedule) ?
                        //         InkWell(
                        //           onTap: () => editRequest(context, widget.appointment),
                        //           child: Container(
                        //                 decoration: BoxDecoration(
                        //                 // color: Palette.appBackgroundSolitudeRed,
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10)),
                        //                 border: Border.all(
                        //                       color: Palette.green, // Set the color of the border here
                        //                       width: 1, // Set the width of the border here
                        //                     ),
                        //                   ),
                        //                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        //                   child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: <Widget>[
                        //                     // sizedBox(8),
                                            
                        //                     Row(
                        //                         crossAxisAlignment: CrossAxisAlignment.center,
                        //                         mainAxisSize: MainAxisSize.min,
                        //                           children: <Widget>[
                        //                             Container(
                        //                               decoration: BoxDecoration(
                        //                                   color: Palette.green,
                        //                                   shape: BoxShape.circle,
                        //                                 ),
                        //                               width: 16,
                        //                               height: 16,
                        //                                 alignment: Alignment.center,
                        //                                 child: Icon(PhosphorIconsRegular.check, color: Palette.white, size: 12, ),
                        //                             ),
                        //                             const SizedBox(width: 8,),
                        //                             Text('Save changes'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.green, fontWeight: FontWeight.bold)),
                                                    
                        //                           ],
                        //                       )
                                            
                        //             ])),
                        //         ) : sizedBox(0), 
                        //         (changeSchedule) ? const SizedBox(width: 16,) : sizedBox(0),
                        //         InkWell(
                        //           onTap: () => cancelRequest(context, widget.appointment),
                        //           child: Container(
                        //                 decoration: BoxDecoration(
                        //                 // color: Palette.appBackgroundSolitudeRed,
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10)),
                        //                 border: Border.all(
                        //                       color: Palette.appBackgroundSolitudeRed, // Set the color of the border here
                        //                       width: 1, // Set the width of the border here
                        //                     ),
                        //                   ),
                        //                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        //                   child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: <Widget>[
                        //                     // sizedBox(8),
                                            
                        //                     Row(
                        //                         crossAxisAlignment: CrossAxisAlignment.center,
                        //                         mainAxisSize: MainAxisSize.min,
                        //                           children: <Widget>[
                        //                             Container(
                        //                               decoration: BoxDecoration(
                        //                                   color: Palette.red,
                        //                                   shape: BoxShape.circle,
                        //                                 ),
                        //                               width: 16,
                        //                               height: 16,
                        //                                 alignment: Alignment.center,
                        //                                 child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.white, size: 12, ),
                        //                             ),
                        //                             const SizedBox(width: 8,),
                        //                             Text('Cancel'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red, fontWeight: FontWeight.bold)),
                                                    
                        //                           ],
                        //                       )
                                            
                        //             ])),
                        //         ), 
                                
                        //         ]) :  const AppProgress(height: 30, width: 30,)
                        //     ) : sizedBox(0),
            ]
          ),

          
      // ),
    ),
  ),
                  sizedBox(8),

                  Container(
                    decoration: BoxDecoration(
                                    color: const Color(0x66FFFFFF),
                                    border: Border.all(color: const Color(0xFFFFFFFF)),
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
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                      controller: descriptionController,
                      minLines: 1,
                      maxLines: 6,
                      // maxLength: 120,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0x66FFFFFF),
                        // fillColor: Theme.of(context).cardColor,
                        border: InputBorder.none,
                        
                        hintText: 'Meeting notes',
                          ),
                      validator: (value) { // validator function is called on calling form validate() method
                        if (value!.isEmpty) {
                          return 'Provide reason to proceed';
                        }
                        return null;
                      },
                      //onSaved: (value) => description = value,
                    ),
                  ),
                  sizedBox(8),
                  sizedBox(8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: 
                  Row(

                              children: [

                                (changeSchedule) ?
                                InkWell(
                                  onTap: () => editRequest(context, widget.appointment),
                                  child: Container(
                                        decoration: BoxDecoration(
                                        // color: Palette.appBackgroundSolitudeRed,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(
                                              color: Palette.green, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // sizedBox(8),
                                            Text('Save changes'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.green, fontWeight: FontWeight.bold)),
                                            // Row(
                                            //     crossAxisAlignment: CrossAxisAlignment.center,
                                            //     mainAxisSize: MainAxisSize.min,
                                            //       children: <Widget>[
                                            //         Container(
                                            //           decoration: BoxDecoration(
                                            //               color: Palette.green,
                                            //               shape: BoxShape.circle,
                                            //             ),
                                            //           width: 16,
                                            //           height: 16,
                                            //             alignment: Alignment.center,
                                            //             child: Icon(PhosphorIconsRegular.check, color: Palette.white, size: 12, ),
                                            //         ),
                                            //         const SizedBox(width: 8,),
                                            //         Text('Save changes'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.green, fontWeight: FontWeight.bold)),
                                                    
                                            //       ],
                                            //   )
                                            
                                    ])),
                                ) : 
                                (widget.appointment.requestStatus == Constants.submitted) ?
                                InkWell(
                                  onTap: () => acceptRequest(context, widget.appointment),
                                  child: Container(
                                        decoration: BoxDecoration(
                                        // color: Palette.appBackgroundSolitudeRed,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(
                                              color: Palette.appPrimary, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // sizedBox(8),
                                            Text('Accept'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary, fontWeight: FontWeight.bold)),
                                            // Row(
                                            //     crossAxisAlignment: CrossAxisAlignment.center,
                                            //     mainAxisSize: MainAxisSize.min,
                                            //       children: <Widget>[
                                            //         Container(
                                            //           decoration: BoxDecoration(
                                            //               color: Palette.appPrimary,
                                            //               shape: BoxShape.circle,
                                            //             ),
                                            //           width: 16,
                                            //           height: 16,
                                            //             alignment: Alignment.center,
                                            //             child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.white, size: 12, ),
                                            //         ),
                                            //         const SizedBox(width: 8,),
                                            //         Text('Accept'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.appPrimary, fontWeight: FontWeight.bold)),
                                                    
                                            //       ],
                                            //   )
                                            
                                    ])),
                                ) : sizedBox(0), 
                                const SizedBox(width: 16,),
                                (widget.appointment.requestStatus != Constants.cancelled) ?
                                InkWell(
                                  onTap: () => cancelRequest(context, widget.appointment),
                                  child: Container(
                                        decoration: BoxDecoration(
                                        // color: Palette.appBackgroundSolitudeRed,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(
                                              color: Palette.red, // Set the color of the border here
                                              width: 1, // Set the width of the border here
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                          child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // sizedBox(8),
                                            Text('Cancel'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red, fontWeight: FontWeight.bold)),
                                            // Row(
                                            //     crossAxisAlignment: CrossAxisAlignment.center,
                                            //     mainAxisSize: MainAxisSize.min,
                                            //       children: <Widget>[
                                            //         Container(
                                            //           decoration: BoxDecoration(
                                            //               color: Palette.red,
                                            //               shape: BoxShape.circle,
                                            //             ),
                                            //           width: 16,
                                            //           height: 16,
                                            //             alignment: Alignment.center,
                                            //             child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.white, size: 12, ),
                                            //         ),
                                            //         const SizedBox(width: 8,),
                                            //         Text('Cancel'.toUpperCase(), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red, fontWeight: FontWeight.bold)),
                                                    
                                            //       ],
                                            //   )
                                            
                                    ])),
                                ) : sizedBox(0),
                               
                                // InkWell(
                                //   // onTap: () => cancelRequest(context, list[position].appointmentId!, position),
                                //   child: Container(
                                //         decoration: BoxDecoration(
                                //         // color: Palette.appBackgroundSolitudeRed,
                                //         borderRadius: const BorderRadius.all(Radius.circular(4)),
                                //         border: Border.all(
                                //               color: Palette.red, // Set the color of the border here
                                //               width: 1, // Set the width of the border here
                                //             ),
                                //           ),
                                //           padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                                //           child: Column(
                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                //           children: <Widget>[
                                //             Row(
                                //                 crossAxisAlignment: CrossAxisAlignment.center,
                                //                 mainAxisSize: MainAxisSize.min,
                                //                   children: <Widget>[
                                //                     Icon(PhosphorIconsRegular.x, color: Palette.red, size: 16, ),
                                //                     const SizedBox(width: 8,),
                                //                     Text('Cancel', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.red)),
                                //                   ],
                                //               )
                                //     ])),
                                // )
                                
                                 ])
                  )

                ],
              ),
            ),
            ),
            )
        
    )]));
  }

  // void increment() {
  //   if(foodCount < ActualSelectedVisitors.length){
  //     setState(() {
  //       foodCount++;
  //     });
  //   }
  // }

  // void decrement() {
  //   if(foodCount > 0){
  //     setState(() {
  //       foodCount--;
  //     });
  //   }
  // }

  // add visitor
    // void addVisitorDetail(BuildContext context1){
      
    //   // validate() methods call the validator functions for all form elements
    //   if(formKey1.currentState!.validate()){ 
    //     formKey1.currentState!.save();

    //     // verify if this request duration contains any of blocked dates
    //     if(vNameController.text.length > 2) {
          
    //       String relation = '';
    //       switch (_selectedValue) {
    //         case 1:
    //           relation = "Brother";
    //           break;
    //         case 2:
    //           relation = "Sister";
    //           break;
    //         case 3:
    //           relation = "Uncle";
    //           break;
    //         case 4:
    //           relation = "Aunt";
    //           break;
    //         default:
    //       }

          
    //       // clear values
    //       // vNameController.text = '';
    //       // vPhoneController.text = '';
          
    //         setState(() {
    //           // add to selected list
    //           // selectedVisitors.add(Visitor(name:vNameController.text,phoneNumber: vPhoneController.text,relation: relation));
    //           // add visitors
    //           visitors.add(Visitor(name:vNameController.text,phoneNumber: vPhoneController.text,relation: relation));
    //           // selectedVisitors.add(Visitor(name:vNameController.text,phoneNumber: vPhoneController.text,relation: relation));
    //           _selectedValue = 1;
    //         });
    //         refreshWidget();
          
    //       //  submitRequest();
    //     }
    //     else {
          
    //     }
        

    //   }
    //   else {
    //     setState(() {
    //       //errorMsg = 'Please provide your details';
    //     });
    //   }

    // }

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


// 1 stage
// 2 appointmentId
// 3 collegeId
// 4 adminId
// 5 updatedOn
// 6 playerId
// 7 notes
    // Accept request
  void acceptRequest(BuildContext context, Appointment appointment) async {
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
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S1/${appointment.appointmentId}/$collegeId/$username/$today/${appointment.collegeId}", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      appointment.adminId = collegeId;
      appointment.adminName = username;
      appointment.requestStatus = Constants.confirmed;
      
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
  void cancelRequest(BuildContext context, Appointment appointment) async {
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
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S4/${appointment.appointmentId}/$collegeId/${appointment.collegeId}/Cancelled by $username", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      appointment.isOpen = 0;
      
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



// get the selected time
Future<TimeOfDay?> _selectedTime(BuildContext context, TimeOfDay time) => showTimePicker(
  context: context,
  initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
  
);





  


    // submit request
  void submitRequest() async {

      
    // query parameters    
    Map<String, String> queryParams = {
      // "requestId":randomString("R"),
      // "requestType":widget.requestType,
      // "collegeId":userObjectId!,
      // "username":username!,
      // "branch":branch!,
      // "year":year.toString(),
      // "description":descriptionController.text,
      // "requestFrom":DateFormat('yyyy-MM-dd hh:mm:ss', 'en_US').format(fromDate),
      // "requestTo":DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(toDate),
      // "requestDate":"just now",
      // "timeFrom":fromTime!.hour.toString()+fromTime!.minute.toString(),
      // "timeTo":toTime!.hour.toString()+toTime!.minute.toString(),
      // "duration":days.toString(),
      // "requestStatus": Constants.submitted,
      };

      var A = randomString("A");

    // add time to the date
    DateTime changedDate1 = DateTime(
      changedDate!.year,
      changedDate!.month,
      changedDate!.day,
      changedTime!.hour,
      changedTime!.minute,
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
        "requestDate":DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(changedDate1),
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
      // key, requestId, collegeId, visitOn, description, count, foodCount, requestDate, visitorsList
      // list of visitors
      // print("${APIUrls.newVisitorpass}${APIUrls.pass}/$V/$userObjectId/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(changedDate1)}/${Uri.encodeComponent(descriptionController.text)}/${selectedVisitors.length}/$foodCount/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$visitorsList/$isAllowed/$username/$parentNumber");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.newAppointment}${APIUrls.pass}/$A/$collegeId/-/${Uri.encodeComponent(descriptionController.text)}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(changedDate1)}/0/$campusId", queryParams)), headers: {"Accept": "application/json"});
      
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
          submitted = true;
        });
        _animationController.forward();
        
        // play the sound
        player.setAsset('assets/notification.mp3');
        player.play();
        

        // show the success animation
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            Navigator.pop(context, queryParams1);
          });
        });
        
          
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



    // 0. Pass
    // 1. stage
    // 2. appointmentId
    // 4. requestDate
    // 5. playerId
    // edit request
  void editRequest(BuildContext context, Appointment appointment) async {
    setState(() {
      isClosing = true;
    });

    // add time to the date
    DateTime changedDate1 = DateTime(
      changedDate!.year,
      changedDate!.month,
      changedDate!.day,
      changedTime!.hour,
      changedTime!.minute,
    );

    String updatedDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(changedDate1);
    // query parameters    
    Map<String, String> queryParams = {
      // "appointmentId":appointmentId,
      };

    // API call
    //var result = await get(Uri.encodeFull(APIUrls.getUrl(APIUrls.newRequest, queryParams)), headers: {"Accept": "application/json"});
    // print("${APIUrls.updateAppointment}${APIUrls.pass}/S4/$appointmentId/$collegeId/-/-/$gcmRegId/Cancelled by $username");
    var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.updateAppointment}${APIUrls.pass}/S5/${appointment.appointmentId}/$updatedDate/$collegeId/${appointment.collegeId}", queryParams)), headers: {"Accept": "application/json"});
    
    // get the result body which is JSON
    var jsonString = jsonDecode(result.body); 
    
    // convert jsonString to Map
    var jsonObject = jsonString as Map; 

    // check if the api returned success
    if(jsonObject['status'] == 200){
      
      // remove the item from list
      appointment.requestDate = updatedDate;
      
      // list.removeAt(position);
      
      setState(() {
        list = list;
        isDataAvailable = false;
        isClosing = false;
        changeSchedule = false;
      });

      showToast(context, 'Changes updated!',Constants.success);
        
    }
    else {
      // show the error msg
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error occured. Please try later!'), duration: Duration(seconds: 2),));
    showToast(context, jsonObject['message'],Constants.error);
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
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
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
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.single,
                    minDate: DateTime.now(),
                    initialSelectedDate: DateTime.parse(DateFormat('yyyy-MM-dd', 'en_US').format(changedDate!).toString()),
                    // initialSelectedDate: DateTime.parse(appointmentDate),
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      // Handle the selected date range
                      
                      // set the date to call the stats again
                      setState(() {
                        changeSchedule = true;
                        changedDate = args.value;
                        // appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(args.value).toString();
                      },);
                    },
                  ),
                 MaterialButton(
                      padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                      color: Palette.primary,
                      splashColor: Palette.textShade2,
                      colorBrightness: Brightness.dark,
                      elevation: 2,
                      highlightElevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                          Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.paperPlane(PhosphorIconsStyle.regular), size: 12,),
                          const SizedBox(width: 8,),
                          Text('Select date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1, color: Palette.white),),
                        ],
                      ) 
                    ),
              ],)
              
            )
        );
        

    });
  }

}
