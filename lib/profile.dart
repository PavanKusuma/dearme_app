import 'dart:convert';
import 'dart:io';
import 'dart:math';

// import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_campus/database_dmSansnal.dart';
import 'package:psych_app/modal/user.dart';
// import 'package:smart_campus/profile_update.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/progress.dart';
import 'package:psych_app/util/show_toast.dart';
import 'package:psych_app/util/utils.dart' as Utils;
import 'package:psych_app/util/divider.dart';
import 'package:psych_app/util/palette.dart';
// import 'package:smart_campus/util/show_toast.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/constants.dart' as Constants;
import 'package:psych_app/util/utils.dart';
import 'package:psych_app/verify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// this is 
class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  static String username = '', campusId = '',
  phoneNumber='', email = '-', role = '-', collegeId='', branch='-', course='-', section='-',fatherName='-', fatherPhoneNumber='-', motherName='-', motherPhoneNumber='-', address='-', guardianName='-', guardianPhoneNumber='-', guardian2Name='-', guardian2PhoneNumber='-', userImage = '-', type = '-', hostelName='-',roomNumber='-', outingType='-';
  static int profileUpdated = 0, mediaCount = 0;
  static int year = 0;
  static String updateMsg = '';
  bool versionCheckProgress = false;
  bool refreshCheckProgress = false;
  bool updatePhoneNumberCheckProgress = false;
  String updatePhoneNumberCheckProgressMessage = '';
  List<String> branches = [];
  bool notify = true;
  String notificationMsg = '';
  
  // user object
  User? user ;

  TextEditingController phoneNumberController = TextEditingController();
  // Create a FocusNode
  final FocusNode otpFocusNode = FocusNode();
  late SharedPreferences prefs;

  @override
  void initState() {
      
      // get reference to dmSansnal database
      getUsers();
    
    super.initState();
  }

   @override
    void dispose() {
      otpFocusNode.dispose(); // Dispose of the FocusNode
      super.dispose();
    }

  
    // get user details
    void getUsers() async {
      // fetch from dmSansnal db
      // final dbHelper = DatabaseInternal.instance;
      // final allRows = await dbHelper.queryAllRows();
// print('users count ${allRows.length}');

 // no profile exists
        prefs = await SharedPreferences.getInstance();

        if(prefs.containsKey(Constants.username)){
          setState(() {
            
          campusId = prefs.get(Constants.campusId) as String;
          username = prefs.get(Constants.username) as String;
          collegeId = prefs.get(Constants.collegeId) as String;
          branch = prefs.get(Constants.branch) as String;
          course = prefs.get(Constants.course) as String;
          email = prefs.get(Constants.email) as String;
          role = prefs.get(Constants.role) as String;
          phoneNumber = prefs.get(Constants.phoneNumber) as String;
          fatherName = prefs.get(Constants.fatherName) as String;
          fatherPhoneNumber = prefs.get(Constants.fatherPhoneNumber) as String;
          motherName = prefs.get(Constants.motherName) as String;
          motherPhoneNumber = prefs.get(Constants.motherPhoneNumber) as String;
          guardianName = prefs.get(Constants.guardianName) as String;
          guardianPhoneNumber = prefs.get(Constants.guardianPhoneNumber) as String;
          address = prefs.get(Constants.address) as String;
          guardian2Name = prefs.get(Constants.guardian2Name) as String;
          guardian2PhoneNumber = prefs.get(Constants.guardian2PhoneNumber) as String;
          
          year = prefs.get(Constants.year) as int;
          section = prefs.get(Constants.section) as String;
          profileUpdated = prefs.get(Constants.profileUpdated) as int;
          mediaCount = prefs.get(Constants.mediaCount) as int;
          userImage = prefs.get(Constants.userImage) as String;
          type = prefs.get(Constants.type) as String;
          outingType = prefs.get(Constants.outingType) as String;
          hostelName = prefs.get(Constants.hostelName) as String;
          roomNumber = prefs.get(Constants.roomNumber) as String;

          if(prefs.get(Constants.notify) != null)
            notify = prefs.get(Constants.notify) as bool;

          if(role != Constants.student){
            branches.clear();
            branches.addAll(prefs.get(Constants.branch).toString().split(','));
          }

          
          });
        } 
     
    }



    // find the user
    void refreshUserProfile(BuildContext context) async {

      setState(() {
        refreshCheckProgress = true;
      });
      // var uuid = await DeviceUuid().getUUID();
      // query parameters    
      Map<String, String> queryParams = {
        "campusId":campusId,
        "collegeId":collegeId,
        };

      // API call
      // print("${APIUrls.user}${APIUrls.pass}/U12/$collegeId");
      var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.user}${APIUrls.pass}/U12/$collegeId", queryParams)), headers: {"Accept": "application/json"});
      
      // Decode the JSON string into a Map using the jsonDecode function
      Map<String, dynamic> jsonObject = jsonDecode(result.body);
      // print(result.body);
      // user object list
      
      // check if the api returned success
      if(jsonObject['status'] == 200){
        
          // get the user data from jsonObject
          Map<String, dynamic> userdata = jsonObject['data'];
          
          setState(() {
            // Get new user data
            user = User.fromJson(userdata);
            refreshCheckProgress = false;
          });

          bool val = await Utils.saveData(User.fromJson(userdata));

          if(val){
            showToast(context, 'Your profile is now updated!', Constants.success);
            getUsers();
          }
        
      }
      else if(jsonObject['status'] == 402){
        // no data exists
        setState(() {
          // get the error message
          refreshCheckProgress = false;
        });
        
      }
      else if(jsonObject['status'] == 404){
        // no data exists
        setState(() {
          // get the error message
          refreshCheckProgress = false;
        });
        
      }
      else {

          setState(() {
            refreshCheckProgress = false;
            showToast(context, 'Error, try again later!',Constants.error);
          });
      }
    }


// cancel scheduled notification
Future<void> cancelEightAMNotification() async {
  const int notificationId = 2; // The ID used when scheduling the notification
  await flutterLocalNotificationsPlugin.cancel(notificationId);

  // remove notification preference
  Utils.removeNotificationPreference();
  setState(() {
    notify = false;
  });
  showToast(context, 'Disabled Notification!',Constants.success);
}



// Future<void> scheduleDailyEightAMNotification() async {
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//       2, // ID for the notification
//       'Good Morning!', // Title for the notification
//       getAffirmation().toString(), // Body for the notification
//       _nextInstanceOfEightAM(), // The time you want the notification to show
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_notification_channel_id',
//           'daily_notification',
//           channelDescription: 'Daily notification to start your day',
//           importance: Importance.high,
//         ),
//         // iOS: IOSNotificationDetails(),
        
//       ),
//       androidAllowWhileIdle: true, // Show notification even when the app is idle
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time, // Match time components to repeat daily
//   );

//   // save preference
//   Utils.saveNotificationPreference(true);
//   setState(() {
//     notify = true;
//   });
//   showToast(context, 'Scheduled 8 AM Notification!',Constants.success);
// }

// tz.TZDateTime _nextInstanceOfEightAM() {
//   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
//   if (scheduledDate.isBefore(now)) {
//     // If it's after 8 AM, schedule for the next day
//     scheduledDate = scheduledDate.add(const Duration(days: 1));
//   }
//   return scheduledDate;
// }


// Future<String> getAffirmation() async {
//   String selectedAffirmation = 'Start your day with enthusiasm!';
//     try {
//       Random random = Random();
//       final jsonData = await loadJsonFromAssets('assets/affirmations.json');
//       setState(() {
//         List<dynamic> mixedList = jsonData['Affirmations'];
//         List<String> selectedAffirmations = mixedList.whereType<String>().toList();
//         selectedAffirmation = selectedAffirmations[random.nextInt(selectedAffirmations.length)];
        
//         // selectedFeelings = jsonData['Happy'] as List<String>; // Assuming a list of strings
//       });
//     } catch (error) {
//       print('Error loading JSON: $error');
//     }

//     return selectedAffirmation;
//   }



Future<void> scheduleDailyEightAMNotification() async {

  await flutterLocalNotificationsPlugin.zonedSchedule(
      2, // ID for the notification
      'Dear Me,', // Title for the notification
      // await getAffirmation(), // Body for the notification
      notificationMsg, // Body for the notification
      _nextInstanceOfEightAM(), // The time you want the notification to show
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          'daily_notification',
          channelDescription: 'Daily notification to start your day',
          importance: Importance.high,
        ),
        // iOS: IOSNotificationDetails(),
        
      ),
      androidAllowWhileIdle: true, // Show notification even when the app is idle
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Match time components to repeat daily
  );

  // save preference
  Utils.saveNotificationPreference(true);
  setState(() {
    notify = true;
  });
  showToast(context, 'Scheduled 8 AM Notification!',Constants.success);
}

tz.TZDateTime _nextInstanceOfEightAM() {

  // get the next affirmation
  getAffirmation1();

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  print(now);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
  print(scheduledDate);
  if (scheduledDate.isBefore(now)) {
    // If it's after 8 AM, schedule for the next day
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}


Future<String> getAffirmation() async {
  String selectedAffirmation = 'Start your day with enthusiasm!';
    try {
      Random random = Random();
      final jsonData = await loadJsonFromAssets('assets/affirmations.json');
      // setState(() {
        List<dynamic> mixedList = jsonData['Affirmations'];
        List<String> selectedAffirmations = mixedList.whereType<String>().toList();
        selectedAffirmation = selectedAffirmations[random.nextInt(selectedAffirmations.length)];

        // final jsonData1 = await loadJsonFromAssets('assets/affirmations.json');
        // selectedAffirmation = jsonData1['Affirmations'].whereType<String>().toList()[random.nextInt(jsonData1['Affirmations'].whereType<String>().toList().length)];
        print(selectedAffirmation);
        setState(() {
          notificationMsg = selectedAffirmation;
        });
        // selectedFeelings = jsonData['Happy'] as List<String>; // Assuming a list of strings
      // });
    } catch (error) {
      print('Error loading JSON: $error');
    }

    return selectedAffirmation;
  }
void getAffirmation1() async {
  String selectedAffirmation = 'Start your day with enthusiasm!';
    try {
      Random random = Random();
      final jsonData = await loadJsonFromAssets('assets/affirmations.json');
      // setState(() {
        List<dynamic> mixedList = jsonData['Affirmations'];
        List<String> selectedAffirmations = mixedList.whereType<String>().toList();
        selectedAffirmation = selectedAffirmations[random.nextInt(selectedAffirmations.length)];

        // final jsonData1 = await loadJsonFromAssets('assets/affirmations.json');
        // selectedAffirmation = jsonData1['Affirmations'].whereType<String>().toList()[random.nextInt(jsonData1['Affirmations'].whereType<String>().toList().length)];
        print(selectedAffirmation);
        setState(() {
          notificationMsg = selectedAffirmation;
        });
        // selectedFeelings = jsonData['Happy'] as List<String>; // Assuming a list of strings
      // });
    } catch (error) {
      print('Error loading JSON: $error');
    }

  }

  Future<Map<String, dynamic>> loadJsonFromAssets(String assetsPath) async {
  final String jsonString = await rootBundle.loadString(assetsPath);
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  return jsonData;
}





  @override
  Widget build(BuildContext context) {

    // get the selected theme
    // Accessing the audioHandler instance
    final audioHandler = Provider.of<AudioHandler>(context, listen: false);
    
    Uri facebookUrl;
    return 
    Scaffold(
      
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


        child: SingleChildScrollView(
      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,

        children: <Widget>[

          // Container(
          //     padding: EdgeInsets.fromLTRB(24, 16, 16, 0),
          //     child: Row(
          //       children: [
          //         // AppHeader('Profile', '', 0),
          //         Text('Profile', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.headline4)),
                  

          //       ],
          //     ) 
            
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
                        Text('Profile', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
                      ],),
                        
                        // sizedBox(8),
                        Text('We are keeping your data encrypted and secure', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.titleMedium, color: Colors.black54)), 
                        // sizedBox(8)
                      ],
                    ),
              ),



          Column(
          // child: CardRound(Palette.lightBackground, Column(
            
            children: <Widget>[
              Container( 
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
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child:  Column(
                    children: <Widget>[
                      sizedBox(16),
                      Text('You are', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.black54)),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                             Container(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  // color: Theme.of(context).shadowColor,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).cardColor),
                                child: Text('$campusId - $role', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),

                      
                      sizedBox(16),
                      


                      ]),
              ),
            ],
          
          ),



          // Background Audio
          InkWell(
            onTap: () => {
                // Cancel the notification
                notify ? cancelEightAMNotification() : scheduleDailyEightAMNotification()
              },
              child: Container( 
                decoration: BoxDecoration(
                      color: Color.fromARGB(255, 253, 234, 182),
                      // color: const Color(0x66FFFFFF),
                      border: Border.all(color: const Color(0x99FFB800)),
                      // color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          // color: Colors.black26,
                          color: Color(0x11FFB800),
                          // color: Color(0xFF080B23),
                          offset: Offset(0.0, 0.0),
                          blurRadius: 4.0,
                          spreadRadius: 0.3,
                        ),
                      ]
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: const EdgeInsets.all(16),
                      child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                
                          // Rate on Play Store or App Store
                          // CardRound(Theme.of(context).cardColor,
                               Container(
                                  // margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                  child:
                                  Row(
                                    children: [
                                      Icon(PhosphorIconsRegular.notification, color: Color(0xFF6D4E00), size: 36, ),
                                      const SizedBox(width:16),
                                      notify ? Text('Disable 8AM affirmation', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF6D4E00)))
                                      : Text('Schedule 8AM affirmation', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                
                              
                              
                              sizedBox(16),
                              Text('Start your day with an affirmation!', style: GoogleFonts.dmSans(fontSize: 16, color: Colors.black54))
                        
                        ],
                      )
                    ),
                  ),

                  sizedBox(16),

          // Background Audio
          InkWell(
            onTap: () => {
                // App feedback link
                // google forms from HelpMeCode – Smart Campus Platform Feedback
                audioHandler.stop()
              },
              child: Container( 
                decoration: BoxDecoration(
                      color: Color.fromARGB(255, 202, 242, 177),
                      // color: const Color(0x66FFFFFF),
                      border: Border.all(color: Color.fromARGB(255, 81, 210, 0)),
                      // color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          // color: Colors.black26,
                          color: Color(0x1162FF00),
                          // color: Color(0xFF080B23),
                          offset: Offset(0.0, 0.0),
                          blurRadius: 4.0,
                          spreadRadius: 0.3,
                        ),
                      ]
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: const EdgeInsets.all(16),
                      child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                
                          // Rate on Play Store or App Store
                          // CardRound(Theme.of(context).cardColor,
                               Container(
                                  // margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                  child:
                                  Row(
                                    children: [
                                      Icon(PhosphorIconsRegular.headphones, color: Color(0xFF2B6F00), size: 36,),
                                      const SizedBox(width:16),
                                      Text('Play Background Audio', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF2B6F00))),
                                    ],
                                  ),
                                ),
                                
                              
                              
                              sizedBox(16),
                              Text('Listen to soothing music as you use this app!', style: GoogleFonts.dmSans(fontSize: 16, color: Colors.black54))
                        
                        ],
                      )
                    ),
                  ),

                  sizedBox(16),


              
                Container( 
                      decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
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
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: 
                      Column(
                        children: [

                          /// App Feedback
                                // CardRound(Theme.of(context).cardColor,
                                    InkWell(
                                      
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                        child:
                                        Row(
                                          children: [
                                            Icon(PhosphorIconsRegular.thumbsUp, color: Colors.black45, size: 20,),
                                            const SizedBox(width:16),
                                            Text('Give app feedback', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                                          ],
                                        ),
                                      ),
                                      
                                    onTap: () => {
                                      
                                      // App feedback link
                                      // google forms from HelpMeCode – Smart Campus Platform Feedback
                                      launchUrl(
                                          Uri.parse('https://forms.gle/gm76MbBi5rmz5q3t8'),mode: LaunchMode.externalApplication
                                        )
                                    },
                                    ),
                                  // ),

                                  divider(Palette.textShade2),
                                
                                // Rate on Play Store or App Store
                                // CardRound(Theme.of(context).cardColor,
                                    InkWell(
                                      
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                        child:
                                        Row(
                                          children: [
                                            Icon(PhosphorIconsRegular.star, color: Colors.black45, size: 20,),
                                            const SizedBox(width:16),
                                            Text('Rate our App', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                                          ],
                                        ),
                                      ),
                                      
                                    onTap: () => {
                                      
                                      // Check the platform.
                                      if (Platform.isAndroid) {
                                        // Navigate to the Play Store.
                                        launchUrl(
                                          Uri.parse('https://play.google.com/store/apps/details?id=tools.smartcampus.platform&hl=en-IN'), mode: LaunchMode.externalNonBrowserApplication,
                                        )
                                      } else if (Platform.isIOS) {
                                        // Navigate to the App Store.
                                        launchUrl(
                                          Uri.parse('https://apps.apple.com/app/id1616440644')
                                        )
                                      }
                                    },
                                    ),
                                  // ),

                                  // divider(Palette.textShade2),
                                
                                  // // Follow on Facebook
                                  // // CardRound(Theme.of(context).cardColor,
                                  //   InkWell(
                                      
                                  //     child: Container(
                                  //       padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                  //       child:
                                  //       Row(
                                  //         children: [
                                  //           Icon(PhosphorIconsRegular.facebookLogo, color: Palette.appPrimary, size: 20,),
                                  //           const SizedBox(width:16),
                                  //           Text('Follow @SmartCampus', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                                  //         ],
                                  //       ),
                                  //     ),
                                      
                                  //   onTap: () => {
                                  //     facebookUrl = Uri.parse('https://www.facebook.com/profile.php?id=61553276720288'),
                                  //     launchUrl(facebookUrl, mode: LaunchMode.externalApplication),
                                     
                                  //   },
                                  //   ),
                                  // ),
                                  
                                //   divider(Palette.textShade2),

                                //   // App update
                                //  CardRound(Theme.of(context).cardColor,
                                //   InkWell(
                                    
                                //     child: Container(
                                //       padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                                //       child:
                                //       Row(
                                //         children: [
                                //           Icon(PhosphorIconsRegular.whatsappLogo, color: Palette.appPrimary, size: 20,),
                                //           const SizedBox(width:16),
                                //           Text('Join WhatsApp Community', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                                //         ],
                                //       ),
                                //     ),
                                    
                                //   onTap: () => {
                                //     launchUrl(
                                //           Uri.parse('https://www.whatsapp.com/channel/0029VaDHQodEquiN3Tcp932x'),
                                //         )
                                //   },
                                //   ),
                                // ),


                        ],
                      )
                      
                  ),
            
                  sizedBox(8),
              
              // social links
              Container( 
                      decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
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
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: 
                      Column(
                        children: [

                          /// App Feedback
                                // CardRound(Theme.of(context).cardColor,
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Icon(PhosphorIconsRegular.thumbsUp, color: Palette.textShade1, size: 20,),
                                            Text(Platform.operatingSystem+ ' App Version', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)),
                                            const SizedBox(width:16),
                                            Text('${Platform.isAndroid ? Constants.sc_app_version : Constants.sc_app_version_ios}', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Palette.textShade1)),
                                          ],
                                        ),
                                      ),
                                      
                                    
                                  // ),

                                  
                                  divider(Palette.textShade2),
                                
                                  // Follow on Facebook
                                  // CardRound(Theme.of(context).cardColor,
                                    InkWell(
                                      
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(14, 4, 16, 4),
                                        child:
                                        Row(
                                          children: [
                                            Icon(PhosphorIconsRegular.info, color: Colors.black45, size: 24,),
                                            const SizedBox(width:14),
                                            Text('Disclaimer', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                                          ],
                                        ),
                                      ),
                                      
                                    onTap: () => {_showModalBottomSheet(context, Constants.disclaimer)},
                                    ),
                                  // ),
                                  
                                  
                                  divider(Palette.textShade2),
                                
                                  // Follow on Facebook
                                  // CardRound(Theme.of(context).cardColor,
                                    InkWell(
                                      
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(14, 4, 16, 12),
                                        child:
                                        Row(
                                          children: [
                                            Icon(PhosphorIconsRegular.signOut, color: Colors.red, size: 24,),
                                            const SizedBox(width:14),
                                            Text('Sign out', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1, color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                      
                                    onTap: () => signOutUser(),
                                    ),
                                  // ),
                                  
                                

                        ],
                      )
                      
                  ),
            
                  sizedBox(8),
          // Container(
          //   margin: EdgeInsets.fromLTRB(24, 0, 8, 8),
          //   child: 
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Row(
          //         children: <Widget>[
          //           Icon(Icons.refresh, color:Palette.green,),
          //           MaterialButton(
          //               child: Text('REFRESH PROFILE'),
                            
                            
          //                   splashColor: Palette.accent,
          //                   colorBrightness: Brightness.dark,
          //                   textColor: Palette.green,
          //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            
          //                   onPressed: () => 
          //                     refreshProfile(context),
                            
          //             ),

          //         ],
          //       ),

          //       (updateMsg.length > 0) ? Text(updateMsg, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText2)) : sizedBox(0),
          //     ],
          //   ),
            
          // ),

          // Container(
          //   margin: const EdgeInsets.fromLTRB(24, 0, 8, 16),
          //   child: 
          //   Row(
          //     children: <Widget>[
          //       Icon(Icons.remove_circle_outline, color:Palette.red,),
          //       MaterialButton(
          //       child: const Text('SIGN OUT'),
                    
                    
          //           splashColor: Palette.red,
          //           colorBrightness: Brightness.dark,
          //           textColor: Palette.red,
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    
          //           onPressed: () => 
          //             // sign out user
          //             signOutUser(),
                    
          //     ),

          //     ],
          //   ),
            
            
          // ),

          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            

            child: Column(
              children: <Widget>[
                sizedBox(8),
                //  Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                // children: <Widget>[
                  
                //   Text('Version ${Platform.isAndroid ? Constants.sc_app_version : Constants.sc_app_version_ios}', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)),
                // ],
              // ),
              // sizedBox(8),
              // InkWell(
              //   onTap: () => {_showModalBottomSheet(context, Constants.disclaimer)},
              //   child: 
              //   Text('Disclaimer', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall)),
              // ),
              // sizedBox(16),
              // Text('Created for your campus with love and care!'.toUpperCase(), style: GoogleFonts.passionOne(textStyle: Theme.of(context).textTheme.displayMedium, color: Palette.textShade1)),
              
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[ 
              Text('Created for you with love to offer help & care!', textAlign: TextAlign.center, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Colors.black45, )),
              ]),
              sizedBox(48),
              sizedBox(48),
              ],
            )
              
          )


        
        ],
      ),
      )
    ),
    )]));
  }


  void checkAppVersion(BuildContext context1) async {
      setState(() {
        versionCheckProgress = true;
      });
      // check dmSansnet connection
      if(await checkInternetConnectivity()){

        String appVersion = Constants.sc_app_version;
        // query parameters    
        Map<String, String> queryParams = {
          // "offset":"0",
          };

        // API call
        // print("${APIUrls.appVersion}${APIUrls.pass}/$appVersion/$collegeId");
        var result = await get(Uri.parse(APIUrls.getUrl("${APIUrls.appVersion}${APIUrls.pass}/$appVersion/$collegeId", queryParams)), headers: {"Accept": "application/json"});
        
        // get the result body which is JSON
        var jsonString = jsonDecode(result.body); 
        // convert jsonString to Map
        var jsonObject = jsonString as Map; 

        setState(() {
          versionCheckProgress = false;
        });
        // check if the api returned success
        if(jsonObject['status'] == 200){
          // do nothing
          showToast(context, 'Your app is upto date!',Constants.success);
        }
        else if(jsonObject['status'] == 402){
          // Access revoked
          showToast(context1, jsonObject['message'],Constants.error);
          Navigator.pop(context1);
          // Navigator.push(context1, MaterialPageRoute(builder: (context) => AccessRevoked()));
          
        }
        else if(jsonObject['status'] == 404){
          // show the update screen
          updateDialog(context1);
        }
      }
      else {
        showToast(context, 'No dmSansnet connection!',Constants.warning);
      }
  }

  // update user details
  updateProfile(BuildContext context) async{
    
    // final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileUpdate()));

    // if(result!=null){

    //   Map<String, dynamic> r =  result;
    //   print(r.keys.length);

    //   updateUserData(r);
    //   // show update message
    //   showToast(context, 'Details updated!');

    // }
  }

  // update user details
    // void updateUserData(Map<String, dynamic> r) async {
    //   // fetch from dmSansnal db
    //   final dbHelper = DatabaseInternal.instance;
    //   await dbHelper.update(r);

    //     setState((){
    //         username = r['username'];
    //         phoneNumber = r['phoneNumber'];
    //         email = r['email'];
    //         collegeId = r['collegeId'];
    //         branch = r['branch'];
    //       });
    //   }


  // sign out user
  signOutUser() async {

    // showToast(context, "Signing out!");

    // clear shared preferences
    Utils.clearData();
    
    // clear dmSansnal db
    // final dbHelper = DatabaseInternal.instance;
    // await dbHelper.deleteAll();

    
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Verification()));

  }
  // Refresh profile
  refreshProfile(BuildContext context) async {

    //showToast(context, "Verifying your identity!");
    setState(() {updateMsg = 'Checking for updtes. Please wait...';});
    
    verifyUser(context);

  }


  // show a dialog for updating app version
  updateDialog(BuildContext context1) async {
    
    return showDialog(
        context: context1,
        builder: (context) {
          return AlertDialog(
            icon: Icon((Platform.isAndroid) ? PhosphorIconsRegular.googlePlayLogo : PhosphorIconsRegular.appStoreLogo, color: Palette.black, size: 48, ),
            // icon: Image.asset('assets/app_logo_bg.png',width: 36.0),
            iconPadding: const EdgeInsets.all(16),
            // iconPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            title: Text('Smart Campus App Update',style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 18, fontWeight: FontWeight.bold) ),    
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                Text('New version of app is available.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge) ),    
                sizedBox(8),
                Text('Old version of the app might not function as expected.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, letterSpacing:0.4, fontWeight: FontWeight.w400) ),    
              ],
            ),
      
      backgroundColor: Palette.white,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      actions: [
        InkWell(
            onTap: () => {
                
              // Check the platform.
                if (Platform.isAndroid) {
                  // Navigate to the Play Store.

                  openLink('https://play.google.com/store/apps/details?id=tools.smartcampus.platform&hl=en-IN')
                  // launchUrl(
                  //   Uri.parse('https://play.google.com/store/apps/details?id=tools.smartcampus.platform&hl=en-IN'),
                  // )
                } else if (Platform.isIOS) {
                  // Navigate to the App Store.
                  openLink('https://apps.apple.com/app/id1616440644')
                  // launchUrl(
                  //   Uri.parse('https://apps.apple.com/app/id1616440644'),
                  // )
                }
              },
            child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Palette.appPrimary,
                          Palette.appPrimaryDark,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // sizedBox(8),
                      
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    color: Palette.white,
                                    shape: BoxShape.circle,
                                  ),
                                width: 16,
                                height: 16,
                                  alignment: Alignment.center,
                                  child: Icon(PhosphorIconsRegular.arrowRight, color: Palette.appPrimary, size: 12, ),
                              ),
                              const SizedBox(width: 8,),
                              Text('Update now', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Palette.white)),
                            ],
                        ), 
              ])),
          ),
          Center(
            child: 
        TextButton(
          child: Text('Later', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, letterSpacing:0.4, fontWeight: FontWeight.w400) , textAlign: TextAlign.center),
          onPressed: () {
            // Keep Do Not Disturb on.
            Navigator.pop(context);
          },
        ),)
      ],
    );
        }
    );
  }


  _showModalBottomSheet(BuildContext context, String message){
    showModalBottomSheet(
      
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: true,
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
               margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).cardColor,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 24.0,
                      spreadRadius: 0.3,
                    ),
                  ]
                ),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sizedBox(8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Disclaimer', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.headline5)),
                          Container(
                            padding: EdgeInsets.all(8),
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
                  Text(message, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1)),
                  sizedBox(16),
                ],
              ),
              // )
              
            ),
        );
        

    });
  }





  void openLink(String urlString) async {

    String message = 'Hello!'; // Replace this with your message

    Uri url = Uri.parse(urlString);
    
await canLaunchUrl(url).then((value) => {
  // print(value),
  launchUrl(url, mode: LaunchMode.externalNonBrowserApplication),
});
  }

      // verify the user details
    void verifyUser(BuildContext context1) async {

      // query parameters    
      Map<String, String> queryParams = {
        "collegeId":collegeId,
        "mobileNumber":phoneNumber
        };

      // API call
      var result = await get(Uri.parse(APIUrls.getUrl(APIUrls.verifyUser, queryParams)), headers: {"Accept": "application/json"});
      
      // get the result body which is JSON
      var jsonString = jsonDecode(result.body); 
      // convert jsonString to Map
      var jsonObject = jsonString as Map; 

      List<User> list1;
      // check if the api returned success
      if(jsonObject['status'] == 200){
        // get the list data from jsonObject
        var circulars = jsonObject['data'] as List;
        // convert to list
        list1 = circulars.map<User>((json) => User.fromJson(json)).toList();

        // not more then 1 user
        if(list1.length == 1 ){
          User user = list1.elementAt(0);
          // store the user details
          onSuccessSignUp(user, context1);

        }
        
      }
      else {
        // no data exists
        //showToast(context, 'Something went wrong! Sign out and Sign in for smoother experience!');
        setState(() {updateMsg = 'Something went wrong! Sign out and Sign in for smoother experience!'; });
      }

    }


    // save user details locally
    void onSuccessSignUp(User user, BuildContext context1) async{

      // save into sharedpreferences
/*       SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(Constants.userObjectId, user.userObjectId);
      prefs.setString(Constants.campusId, user.campusId);
      prefs.setString(Constants.username, user.username);
      prefs.setString(Constants.email, user.email);
      prefs.setString(Constants.collegeId, user.collegeId); 
      prefs.setString(Constants.branch, user.branch); 
      prefs.setString(Constants.phoneNumber, user.phoneNumber); 
      prefs.setString(Constants.role, user.role); 
      prefs.setInt(Constants.year, user.year); 
      prefs.setInt(Constants.mediaCount, user.mediaCount); 
      prefs.setString(Constants.userImage, user.userImage); 
      prefs.setString(Constants.gcmRegId, user.gcmRegId); 
 */
      // save into sharedpreferences
      Utils.saveData(user);
      
      // get reference to dmSansnal database
      // final dbHelper = DatabaseInternal.instance;

      // do the data mapping
      Map<String, dynamic> row = {
        Constants.universityId : user.universityId,
        Constants.campusId : user.campusId,
        Constants.username : user.username,
        Constants.email : user.email,
        Constants.collegeId : user.collegeId,
        Constants.branch : user.branch,
        Constants.phoneNumber : user.phoneNumber,
        Constants.role : user.role,
        Constants.year : user.year,
        Constants.mediaCount : user.mediaCount,
        Constants.userImage : user.userImage,
        Constants.gcmRegId : user.gcmRegId,
        Constants.type : user.type,
        Constants.outingType : user.outingType,
        Constants.semester : user.semester,
        Constants.section : user.section,
        Constants.course : user.course,

        Constants.detailsId : user.detailsId,
        Constants.fatherName : user.fatherName,
        Constants.fatherPhoneNumber : user.fatherPhoneNumber,
        Constants.motherName : user.motherName,
        Constants.motherPhoneNumber : user.motherPhoneNumber,
        Constants.guardianName : user.guardianName,
        Constants.guardianPhoneNumber : user.guardianPhoneNumber,
        Constants.guardian2Name : user.guardian2Name,
        Constants.guardian2PhoneNumber : user.guardian2PhoneNumber,
        Constants.address : user.address,
        Constants.hostelId : user.hostelId,
        Constants.roomNumber : user.roomNumber,
        Constants.hostelName : user.hostelName,
      };

      // insert
      // final id = await dbHelper.insert(row);

      //showToast(context1, "Your profile is up to date. Reopen the app for smooth experience!");
      setState(() {updateMsg = 'Your profile is refreshed. Reopen the app for smooth experience!'; });
        
    }
  

}

// getting image
Map<String, bool> imageExistenceCache = {}; // A cache to store image existence results


Future<bool> doesImageExist1(String imageUrl) async {

  if (imageExistenceCache.containsKey(imageUrl)) {
    // If the result is already cached, return it
    return imageExistenceCache[imageUrl]!;
  }

  try {
    final response = await http.head(Uri.parse(imageUrl));
    
    final exists = response.statusCode == 200;

    // Cache the result
    imageExistenceCache[imageUrl] = exists;
    
    return exists;
  } catch (e) {
    return false; // An error occurred, or the image doesn't exist
  }
}
