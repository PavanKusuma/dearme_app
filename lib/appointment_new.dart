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

  // String appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(DateTime.now()).toString();
  

  bool checkBlockedDates = true; // check blocked dates always the user gets to this page.
  int _selectedValue = 1;
  // audio element to play sound
  AudioPlayer player = AudioPlayer();

  late AnimationController _animationController;
  late Animation<double> _animation, sizeAnimation;
  bool containerWidth = true;


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



  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  /// called whenever a selection changed on the date picker widget.
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    /// 
    
    // List<DateTime> dateList = [];
    setState(() {
      if (args.value is PickerDateRange) {
        // dateList.add(args.value.startDate);
        // dateList.add(args.value.endDate);
        
            setState(() {
              fromDate = args.value.startDate;
              if(args.value.endDate == null){
                toDate = args.value.startDate;
              }
              else {
                toDate = args.value.endDate;

                DateTime f = DateTime.parse(fromDate.toString());
                DateTime t = DateTime.parse(toDate.toString());

                DateTime from =  DateTime(f.year, f.month, f.day);
                DateTime to =  DateTime(t.year, t.month, t.day);

                // condition to check if blockedDate exists between the selected duration
                // for (var element in widget.blockedDates) {
                //   if(element.isAfter(from) && element.isBefore(to)){
                    
                //     // this means, there is atleast one blocked date in the duration selected
                //     isAllowed = false;
                //     break;
                //   }
                //   else {

                //     // this means, there is no blocked date in the duration selected
                //     isAllowed = true;
                //   }
                // }
              }


              days = toDate.difference(fromDate).inDays + 1;
            });
            // ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        
        setState(() {
          
          fromDate = args.value;
          toDate = args.value;
          days = fromDate.difference(fromDate).inDays + 1;
        });
      } 
      // else if (args.value is List<DateTime>) {
      //   _dateCount = args.value.length.toString();
      // } else {
      //   _rangeCount = args.value.length.toString();
      // }
    });

            // setState(() {
            //   days = toDate.difference(fromDate).inDays + 1;
            // });
    // return dateList;
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

                          checkBlockedDates ? Container(
                            
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
                            
                            child:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            )
                            
                          )
                          : const AppProgress(height: 30, width: 30,),
                        ), 
                      // ),
                      // Expanded(
                      //   flex: 1,
                      //   child: 
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
                            child: 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      child: Icon(PhosphorIconsLight.clock, size: 32.0, color: Colors.pink),
                                  ),
                                  
                                ],
                              ),
                              
                              const SizedBox(width: 8,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  
                                  Text(fromTime!.format(context), style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontWeight: FontWeight.bold)),
                                ],
                              )
                              
                            ],
                          ),
                          
                          )
                            ),
                        // ),
                      ],
                        
                  ),
                  ),

                  // Container(
                  //   padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    
                  //   child: Text('Duration: $days Day(s)', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)),
                  // ),

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

                    isLoading? sizedBox(0) : 
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



  // show QR bottom sheet
  dateRangeSelect(BuildContext context){
    showModalBottomSheet(
      //enableDrag: true,
      isScrollControlled: true,
      // backgroundColor: Palette.white,
        context: context,
        builder: (BuildContext context){
          return 
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              sizedBox(16),
              Container(
                alignment: Alignment.center,
                height: 6.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Palette.text3Dark,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              ),
              sizedBox(32),

                  // (widget.allowedDates.isNotEmpty) ? Container(
                    
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).shadowColor,
                  //           borderRadius: const BorderRadius.all(Radius.circular(8))
                  //         ),
                  //         margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  //         child:  
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           mainAxisSize: MainAxisSize.max,
                  //           children: <Widget>[
                  //             Icon(PhosphorIcons.checkCircleBold, size: 12.0, color: Palette.blue),
                  //             const SizedBox(width: 4),
                  //             Flexible(
                  //               child:
                  //                 Text('Official outing days are shown in blue on calendar', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.caption,)),
                                
                  //             ),
                  //           ],
                  //         ),
                  //       ) : sizedBox(0),

                  // (widget.blockedDates.isNotEmpty) ? Container(
                    
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).shadowColor,
                  //           borderRadius: const BorderRadius.all(Radius.circular(8))
                  //         ),
                  //         margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  //         child:  
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           mainAxisSize: MainAxisSize.max,
                  //           children: <Widget>[
                  //             Icon(PhosphorIcons.prohibitBold, size: 12.0, color: Palette.red,),
                  //             const SizedBox(width: 4),
                  //             Flexible(
                  //               child:
                  //                 Text('Some days are blocked by your management for outing. You can anyway submit the request.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.caption,)),
                                
                  //             ),
                  //           ],
                  //         ),
                  //       ) : sizedBox(0),
                      
              sizedBox(16),
             
              Expanded(
                child: 
                SfDateRangePicker(
                  todayHighlightColor: Palette.accent,
                                  onSelectionChanged: _onSelectionChanged,
  
                                  selectionMode: DateRangePickerSelectionMode.single,
                                  view: DateRangePickerView.month,
                                  monthViewSettings: DateRangePickerMonthViewSettings(blackoutDates: [DateTime(2020, 03, 26)],
                                  // weekendDays: const [7],
                                  // specialDates:blockedDates,
                                  showTrailingAndLeadingDates: true),
                                  

                                  // selection styling
                                  startRangeSelectionColor: Palette.green,
                                  endRangeSelectionColor: Palette.green,
                                  rangeSelectionColor: Palette.green.withOpacity(0.4),
                                  selectionRadius: 10,
                                  selectionShape: DateRangePickerSelectionShape.circle,
                                  cellBuilder: cellBuilder,
                                  // cellBuilder: cellBuilder(context,  DateRangePickerCellDetails c, allowedDates, blockedDates),

                                  monthCellStyle: DateRangePickerMonthCellStyle(
                                    blackoutDatesDecoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(color: const Color(0xFFF44436), width: 1),
                                        shape: BoxShape.circle),
                                    // weekendDatesDecoration: BoxDecoration(
                                    //     color: const Color(0xFFDFDFDF),
                                    //     border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                                    //     shape: BoxShape.circle),
                                    specialDatesDecoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 234, 221, 207),
                                        // border: Border.all(color: const Color(0xFF2B732F), width: 1),
                                        shape: BoxShape.circle),
                                    blackoutDateTextStyle: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough),
                                    specialDatesTextStyle: const TextStyle(color: Colors.black),
                                  ),
                                  initialSelectedDate: fromDate,
                                  // initialSelectedRange: PickerDateRange(fromDate, fromDate), 
                                  minDate: new DateTime.now(),
                                  // maxDate: new DateTime.now(),
                                )
              
              ),
                

              sizedBox(32),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        child: Text("Select", style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.blue)),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                        color: Palette.appBackgroundSolitude,
                        textColor: Palette.black,
                        splashColor: Palette.textShade2,
                        colorBrightness: Brightness.light,
                        shape: const StadiumBorder(),
                        onPressed: () => Navigator.pop(context),

                      )

                    ],
                  ),
                
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
    DateTime fromDate1 = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
      fromTime!.hour,
      fromTime!.minute,
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
      // print("${APIUrls.newVisitorpass}${APIUrls.pass}/$V/$userObjectId/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(fromDate1)}/${Uri.encodeComponent(descriptionController.text)}/${selectedVisitors.length}/$foodCount/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(today)}/$visitorsList/$isAllowed/$username/$parentNumber");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.newAppointment}${APIUrls.pass}/$A/$collegeId/-/${Uri.encodeComponent(descriptionController.text)}/${DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(fromDate1)}/0/$campusId", queryParams)), headers: {"Accept": "application/json"});
      
      print(result);
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
                      // Handle the selected date range

                      // print('Clicked');
                      // print(args);
                      // print(args.value);
                      // print(DateFormat('yyyy-MM-dd', 'en_US').format(args.value));

                      // set the date to call the stats again
                      setState(() {
                        fromDate = args.value;
                        // appointmentDate = DateFormat('yyyy-MM-dd', 'en_US').format(args.value).toString();
                      },);
                    },
                  ),

                  // decoration: BoxDecoration(
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

                 MaterialButton(
                      padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                      color: const Color(0xFFFFFFFF),
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
                          Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsLight.paperPlane, size: 12, color: Colors.pink),
                          const SizedBox(width: 8,),
                          Text('Select date', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.pink),),
                        ],
                      ) 
                    ),
              ],)
              
            )
        );
        

    });
  }

}


// cell builder helps to construct every date of the calendar
Widget cellBuilder(BuildContext context, DateRangePickerCellDetails details){
 DateTime visibleDates = details.date;

 switch (checkOfficialDateType(visibleDates)) {
   case Constants.allow:
     return  Container(
          // padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Palette.blue.withOpacity(0.4),
              border: Border.all(color: Palette.blue.withOpacity(0.4), width: 1),
              shape: BoxShape.circle),
              child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Text(
                            details.date.day.toString(),
                            textAlign: TextAlign.center,
                          ),
                      Icon(
                          PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
                          size: 13,
                          color: Palette.blue,
                      
                        ),
                      ],)
          );
    //  break;
   case Constants.block:
        return Container(
                // padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Palette.red.withOpacity(0.4),
                    border: Border.all(color: Palette.blue.withOpacity(0.4), width: 1),
                    shape: BoxShape.circle),
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text(
                                details.date.day.toString(),
                                textAlign: TextAlign.center,
                              ),
                          Icon(
                              PhosphorIcons.prohibit(PhosphorIconsStyle.bold),
                              size: 13,
                              color: Palette.red,
                          
                            ),
                ],
          ));
     
    //  break;
   default: return 
   // trying to show different colors based on the previous, current and future dates
                    Center(
                      child: ( visibleDates.difference(DateTime.now()).inDays < 0) ? Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(0),
                      // decoration:  BoxDecoration(
                      //                 color: Palette.appBackgroundSolitude,
                      //                   shape: BoxShape.circle),
                      child: Text(
                        details.date.day.toString(),
                        textAlign: TextAlign.center,
                      ),

                    ) : ( visibleDates.difference(DateTime.now()).inDays > 0) ? Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(0),
                      decoration:  BoxDecoration(
                                      color: Palette.appBackgroundSolitude,
                                        shape: BoxShape.circle),
                      child: Text(
                        details.date.day.toString(),
                        textAlign: TextAlign.center,
                      )) : 
                      Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(0),
                      decoration:  BoxDecoration(
                                      color: Palette.appBackgroundSolitude,
                                       
                                        shape: BoxShape.circle),
                      child: Text(
                        details.date.day.toString(),
                        textAlign: TextAlign.center,
                        
                      ),

                    )
                    )
                  ;
 } 
}


// this function will help to check if any date is 
// either allowed or blocked date
// returns a string "Allow" or "Block" or ""
String checkOfficialDateType(DateTime date) {

  String val = '';
  
  if(allowedDates1.length > 0){
    for (int j = 0; j < allowedDates1.length; j++) {
      
        if (date.year == allowedDates1[j].year &&
            date.month == allowedDates1[j].month &&
            date.day == allowedDates1[j].day) {
          // return Constants.allow;
            { print('yes');
              val = Constants.allow;
              break;
            }
        }

        for (int k = 0; k < blockedDates1.length; k++) {
        
          if (date.year == blockedDates1[k].year &&
              date.month == blockedDates1[k].month &&
              date.day == blockedDates1[k].day) {
            // return Constants.allow;
              { 
                val = Constants.block;
                break;
              }
          }  
        }
    }
  }
  else {
    for (int k = 0; k < blockedDates1.length; k++) {
    
      if (date.year == blockedDates1[k].year &&
            date.month == blockedDates1[k].month &&
            date.day == blockedDates1[k].day) {
        // return Constants.allow;
          { 
            val = Constants.block;
            break;
          }
      }

      for (int j = 0; j < allowedDates1.length; j++) {
      
        if (date.year == allowedDates1[j].year &&
          date.month == allowedDates1[j].month &&
          date.day == allowedDates1[j].day) {
          // return Constants.allow;
            { 
              val = Constants.allow;
              break;
            }
        }  
      }
    }
  }

  
  return val;
}


