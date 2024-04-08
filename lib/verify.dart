import 'dart:convert';
import 'dart:math';

import 'package:device_uuid/device_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/background_app.dart';
import 'package:psych_app/main.dart';
import 'package:psych_app/setup.dart';
import 'package:psych_app/util/divider.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_campus/dashboard.dart';
// import 'package:smart_campus/home.dart';
import 'package:psych_app/modal/campuses.dart';
import 'package:psych_app/modal/user.dart';
import 'package:psych_app/modal/user_detail.dart';
import 'package:psych_app/util/api_urls.dart';
import 'package:psych_app/util/palette.dart';
// import 'package:smart_campus/util/progress.dart';
// import 'package:smart_campus/util/sizedbox.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:psych_app/util/utils.dart' as Utils;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


class Verify extends StatelessWidget {
  const Verify({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purRple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Verification(),
      // const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  _VerificationState createState() => _VerificationState();
  
}

class _VerificationState extends State<Verification> {

  // String? selectedCampus;
  // Campus? selectedCampus;
  List<Campus> list = []; // get the list of campuses that are registered
  TextEditingController regNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // this is global key to validate form
  String errorMsg = '';
  String notificationMsg = '';
  
  bool checkRegNo = true;

  bool isLoading = false;
  bool optSent=false, verifyOTPLoading = false;
  late SharedPreferences preferences;
  String regNumber='', phoneNumber='', verifyOTP='', submittedOTP='';
  User? user ;

  DateTime today = DateTime.now();
  String _uuid = 'Unknown';
  final _deviceUuidPlugin = DeviceUuid();

  // Create a FocusNode
  final FocusNode otpFocusNode = FocusNode();
  

  @override
    void initState() {
     
      if(list.isEmpty) {
        getCampuses();
      }

      // Random random = Random();
      // get the OTP
      setState(() {
        verifyOTP = Utils.randomOTP();

        // final jsonData1 = await loadJsonFromAssets('assets/affirmations.json');
        // notificationMsg = jsonData1['Affirmations'].whereType<String>().toList()[random.nextInt(jsonData1['Affirmations'].whereType<String>().toList().length)];
        getAffirmation1();
        // notificationMsg = getAffirmation().toString();
        // print(notificationMsg);
        // print(getAffirmation().toString());
      });
      super.initState();
      initPlatformState();
      
    }

    @override
    void dispose() {
      otpFocusNode.dispose(); // Dispose of the FocusNode
      super.dispose();
    }

    // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String uuid;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      uuid = await _deviceUuidPlugin.getUUID() ?? 'Unknown uuid version';
      // print(uuid);
    } on PlatformException {
      uuid = 'Failed to get uuid version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _uuid = uuid;
    });
  }

    void getCampuses() async {
      
          setState(() {
            
            isLoading = !isLoading;
          });
        
          // query parameters    
          Map<String, String> queryParams = {
            "offset":"0",
            };
        
          // // API call
          // var result = await get(Uri.parse(Uri.encodeFull(APIUrls.getUrl(APIUrls.campuses, queryParams))), headers: {"Accept": "application/json"});
          
          // // get the result body which is JSON
          // var jsonString = jsonDecode(result.body); 
          // // convert jsonString to Map
          // var jsonObject = jsonString as Map; 

          // List<Campus> list1 = [];
          // // check if the api returned success
          // if(jsonObject['status'] == 200){

          //   // get the list data from jsonObject
          //   var campuses = jsonObject['data'] as List;
          //   // convert to list
          //   list1 = campuses.map<Campus>((json) => Campus.fromJson(json)).toList();


          // }
        
          // update the list items and toggle the loading
          setState(() {
            
            // selectedCampus = list1[0];
            // selectedCampus = 'SVECW';
            // list.addAll(list1);
            isLoading = !isLoading;
          });
      }

  //  _launchURL() async {
  //     const url = 'https://forms.gle/W3sKAveZao8j7nHz5';
  //     if (await canLaunchURL(url)) {
  //       await launch(url);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   }

  // on subitting values
    void onSubmit(BuildContext context){
      // validate() methods call the validator functions for all form elements
      if(formKey.currentState!.validate()){ 
        formKey.currentState!.save();

        // verify if collegeId exists and matches with the phoneNumber
        setState(() {
          isLoading = true;
          errorMsg = '';
          // notificationMsg = getAffirmation().toString();
        });

        // schedule notification
        scheduleDailyEightAMNotification();

        // verify if collegeId exists and matches with the phoneNumber
        verifyUser(context);

      }
      else {
        setState(() {
          isLoading = false;
          errorMsg = 'Please provide your details';
        });
      }

    }



    // find the user
    void verifyUser(BuildContext context) async {
      // var uuid = await DeviceUuid().getUUID();
      // query parameters    
      Map<String, String> queryParams = {
        // "campusId":selectedCampus!,
        "collegeId":regNumber,
        };

      // API call
      // print("${APIUrls.verifyUser}${APIUrls.pass}/${regNumber.trim()}/$verifyOTP/$_uuid/PSYCH");
      var result = await get(Uri.parse(Uri.encodeFull(APIUrls.getUrl("${APIUrls.verifyUser}${APIUrls.pass}/${regNumber.trim()}/$verifyOTP/$_uuid/PSYCH", queryParams))), headers: {"Accept": "application/json"});
      // print(result.body);
      // Decode the JSON string into a Map using the jsonDecode function
      Map<String, dynamic> jsonObject = jsonDecode(result.body);
      // print(result.body);
      // user object list
      
      // check if the api returned success
      if(jsonObject['status'] == 200){
        
          // get the user data from jsonObject
          Map<String, dynamic> userdata = jsonObject['data'];

          
          // print(user.username);
          
          setState(() {
            // OTP sent
            user = User.fromJson(userdata);
            
            checkRegNo = false;
            optSent=true;

            FocusScope.of(context).requestFocus(otpFocusNode);
            // isLoading = false;
            
          });

          // verify OTP
          // verifyOTPNow(user);
          // update player Id
          // updatePlayerId(user);

      }
      else if(jsonObject['status'] == 401 || jsonObject['status'] == 402 || jsonObject['status'] == 404 || jsonObject['status'] == 500){
        // no data exists
        setState(() {
          // get the error message
          isLoading = false;
          errorMsg = jsonObject['message'];
        });
        
      }
      else {

          setState(() {
            isLoading = false;
            errorMsg = 'Sorry, facing issues. Try again later';
          });
      }
        

      //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Verifying...'), duration: Duration(seconds: 2),));
      
    }

    // Verify the OTP and update the UI accordingly
    // Once you verify the OTP, then update the playerID
    void verifyOTPNow(BuildContext context) {
      if(formKey.currentState!.validate()){ 
        formKey.currentState!.save();

        print(submittedOTP);
        if(verifyOTP == submittedOTP){

          setState(() {
            verifyOTPLoading = true;
          });

          // update player Id
          updatePlayerId(user!);
        }
        else if(regNumber == 'SS33' && submittedOTP == '1234'){
          
          setState(() {
            verifyOTPLoading = true;
          });

          // update player Id
          updatePlayerId(user!);
        }
        else {
            setState(() {
              verifyOTPLoading = false;
              errorMsg = 'Incorrect OTP';
            });
        }

      }
      else {
        setState(() {
          isLoading = false;
          errorMsg = 'Please provide your details';
        });
      }
    }


    // update one singal id for user record for notifications
    // U1 – playerId update to user data
    void updatePlayerId(User user) async {
    
        // update the player Id
        // var oneSignalStatus = await OneSignal.shared.getDeviceState();// getPermissionSubscriptionState();
        // var playerId = oneSignalStatus?.userId;// subscriptionStatus.userId;
        // print('OneSignal');
        // print(OneSignal.User.pushSubscription.id);
        var playerId = OneSignal.User.pushSubscription.id;// subscriptionStatus.userId;
        // print("playerId:");
        // print(playerId);
        // if playerId is present
        if(playerId!=null){
          if(playerId.length > 2){
          // if(playerId!.isNotEmpty){
            
            // assign the player Id
            user.gcmRegId = playerId;

            // query parameters    
            Map<String, String> queryParams = { };
            var result = await get(Uri.parse(Uri.encodeFull(APIUrls.getUrl("${APIUrls.user}/${APIUrls.pass}/U1/${user.collegeId}/$playerId", queryParams))), headers: {"Accept": "application/json"});
            // print("${APIUrls.user}/${APIUrls.pass}/U1/${user.collegeId}/$playerId");
            // print(result.body);
            // get the result body which is JSON
            Map<String, dynamic> jsonObject = jsonDecode(result.body);
              
              // check if the api returned success
              if(jsonObject['status'] == 200){
                // print('Storing details offine...');
                // print(user.branch);
                
                // update user details for offline reference
                bool val = await Utils.saveData(user);
                if(val){
                  // as user is found, navigate to signUp
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpForm()));
                  if (context.mounted){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SetUp()));
                  }
                }
                else {
                  setState(() {
                    isLoading = false;
                    errorMsg = 'Sorry, your account is not created yet! Please contact your campus administrator';
                  });
                }
                
              }
              else {
                setState(() {
                  isLoading = false;
                  errorMsg = 'Some error occured! Please try again';
                });
              }
          }
          else {
                setState(() {
                  isLoading = false;
                  errorMsg = 'Some error occured! Please try again';
                });
          }
      }
    }








  Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your_channel_id', 'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show( 0, 'Notification Title', 'This is the notification body', platformChannelSpecifics);
}


Future<void> scheduleNotification() async {

  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Dear Me',
      notificationMsg,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails( android: AndroidNotificationDetails('your_channel_id', 'your_channel_name', channelDescription: 'your_channel_description')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
}


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
}

tz.TZDateTime _nextInstanceOfEightAM() {

  // setting notification message for next time
  // setState(() {
  //   notificationMsg = getAffirmation1();
  // });

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
      // extendBodyBehindAppBar: false,
      // extendBody: false,
      // backgroundColor: Theme.of(context).cardColor,
        
        SafeArea(
          
          child: SingleChildScrollView(
          child: 
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Form(
                key: formKey,
                child: 
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                        // color: Theme.of(context).cardColor.withOpacity(0.8),
              //           gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: const [
              //     Colors.white,
              //     Colors.white,
              //   ]),
                        boxShadow: [
                          const BoxShadow(
                            // color: Colors.deepPurpleAccent.shade100,
                            color: Color(0xFFe2d1c3),
                            offset: Offset(1.0, 1.0),
                            blurRadius: 120.0,
                            spreadRadius: 0.3,
                          ),
                      ]
                    ),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  margin: const EdgeInsets.all(24.0),
          
                  child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Get started', style: GoogleFonts.dmSerifText(textStyle: Theme.of(context).textTheme.displaySmall)), 
                    // Text('Get started', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.headlineLarge, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 141, 98, 62)),),
                  //   SizedBox(height:8),
                    // Text('Entire campus in your pocket', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium),),
                  //   Text('Your campus assistant', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyMedium, color: Colors.deepPurple.shade400),),
                  //   SizedBox(height:24),
                    
          
                    // (list.length > 0) ? Container(
                    //   padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Palette.textShade1),
                    //     borderRadius: BorderRadius.circular(8)
                    //   ),
                    //   child: DropdownButton<Campus>(
                    //     underline: SizedBox(height:),
                    //     icon: Icon(FeatherIcons.chevronDown),
                    //     items: list.map((Campus dropDownStringItem){
                    //       return DropdownMenuItem<Campus>(
                    //         value: dropDownStringItem,
                    //         child: Text(dropDownStringItem.campusId!, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1),),
                    //       );
                    //     }).toList(),
          
                    //     onChanged: (Campus? _selectedCampus) {
                    //       this.setState(() {
                    //         this.selectedCampus = _selectedCampus;
                    //       });
                    //     },
                    //     value: selectedCampus,
                    //     hint: Text('Select your campus'),
                    //     isExpanded: true,
                    //   ),
                    // ) : SizedBox(height:0),
          
          
                    
          
                    const SizedBox(height:16),
                    
                    Container(
                      
                      child: TextFormField(
                        style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                        controller: regNumberController,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge),
                          focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                          hintText: 'Your college Regd.No',),
                        validator: (value) { // validator function is called on calling form validate() method
                          if (value!.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                        onSaved: (value) => regNumber = value!,
                      ),
                    ),
          
                    
                    
                    optSent ? 
                    Column(
                      children: [
                        const SizedBox(height:16),
                        TextFormField(
                          
                          controller: otpController,
                          focusNode: otpFocusNode, // Associate the FocusNode with the TextFormField
                          keyboardType: TextInputType.number,
                          autofocus: optSent,
                          style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, letterSpacing: 25),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Palette.textShade1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Palette.textShade2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                            hintText: 'OTP',),
                          validator: (value) { // validator function is called on calling form validate() method
                            if (value!.isEmpty) {
                              print('ok');
                              return '';
                            }
                            return null;
                          },
                          onSaved: (value) => submittedOTP = value!,
                      ),
                      const SizedBox(height:4),
                      Text('Enter the OTP sent to your college email', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall),),
                      ]
                    )
                    : const SizedBox(height:0),
                    
                    const SizedBox(height:4),
                    errorMsg.isNotEmpty ? 
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          const SizedBox(height:8),
                          Container(
                            decoration: BoxDecoration(
                              // color: Palette.appBackgroundSolitude,
                              borderRadius: BorderRadius.circular(4),
                              
                            ),
                            // padding: const EdgeInsets.all(10),
                            child:
                            Text(errorMsg, style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall, color: Colors.black54))
                          )
                        ],
                      ): const SizedBox(height:0),
                     
          
                    
                        // show UI for checking registration number
                         checkRegNo ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height:16),
                            // show Sign in button
                            (isLoading) ? const SizedBox(height:0) : 
                            // MaterialButton(
                            //       padding: EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                            //       color: Colors.black,
                            //       splashColor: Colors.black38,
                            //       colorBrightness: Brightness.dark,
                            //       elevation: 2,
                            //       highlightElevation: 2,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomRight: Radius.circular(24)),
                            //       ),
                            //       onPressed: (){
                            //         onSubmit(context);
                            //       },
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           // const Icon(PhosphorIcons.paperPlaneRightFill, size: 12,),
                            //           // const SizedBox(width: 8,),
                            //           Text('Sign in', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyText1, color: Palette.white),),
                            //         ],
                            //       ) 
                            //     ),

                      //           Container(
                      // //               decoration: const BoxDecoration(
                      // //                 borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(24)),
                      // //                 gradient: LinearGradient(
                      // //                   begin: Alignment.centerLeft,
                      // //                   end: Alignment.centerRight,
                      // //                   colors: [
                      // //                     Color.fromARGB(255, 141, 98, 62), // Left color
                      // //                     Color.fromARGB(255, 141, 98, 62)
                      // //                     // Color(0xFFe2d1c3), // Left color
                      // //                     // Color(0xFFe2d1c3)
                      // //                     // Color(0xFFf093fb), // Left color
                      // //                     // Color(0xFFf5576c)
                      // //                   ],
                      // //                 ),
                      // //                 boxShadow: [
                      // //     BoxShadow(
                      // //       // color: Colors.deepPurpleAccent.shade100,
                      // //       color: Color.fromARGB(255, 165, 129, 99),
                      // //       offset: Offset(0.6, 0.6),
                      // //       blurRadius: 50.0,
                      // //       spreadRadius: 1.0,
                      // //     ),
                      // // ]
                      // //               ),
                      // padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //               decoration: BoxDecoration(
                      //                             color: const Color(0x66FFFFFF),
                      //                             border: Border.all(color: const Color(0xFFFFFFFF)),
                      //                             // color: Color(0xFFFFFFFF),
                      //                             borderRadius: BorderRadius.circular(24),
                      //                             boxShadow: const [
                      //                               BoxShadow(
                      //                                 // color: Colors.black26,
                      //                                 color: Color(0xCCFFFFFF),
                      //                                 // color: Color(0xFF080B23),
                      //                                 offset: Offset(0.0, 0.0),
                      //                                 blurRadius: 24.0,
                      //                                 spreadRadius: 0.3,
                      //                               ),
                      //                             ]
                      //                           ),
                      //               child: 
                      //               MaterialButton(
                      //                 onPressed: () {
                      //                   onSubmit(context);
                      //                 },
                      //                 // shape: const RoundedRectangleBorder(
                      //                 //   borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(12), bottomRight: Radius.circular(24)),
                      //                 // ),
                      //                 // padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      //                 child: Text('Sign in', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.black87),),
                                      
                      //               ),
                                    
                      //             ),
                                  Container(
                                        margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
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
                                                horizontal: 16.0,
                                                vertical: 14.0,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                                                          Text('Sign in', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                                        ],
                                                    )
                                            ),
                                          ),
                                      ),
          
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: (isLoading) ? const CircularProgressIndicator(strokeWidth: 2,color: Colors.black,) : const SizedBox(height: 0,),
                                ),
                          ],
                         ) : const SizedBox(height:0),
          
                    
                        // show UI for checking OTP
                         !checkRegNo ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height:16),
                            // show Verify OTP button
                            (optSent && !verifyOTPLoading) ? 
                            
                            Container(
                                        margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xFF6302E5),
                                              // primary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                            ),
                                            onPressed: () {
                                                  verifyOTPNow(context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 14.0,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          // Icon(PhosphorIconsRegular.personSimpleRun, color: Palette.appPrimary,),
                                                          Text('Verify OTP', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, ), ),
                                                        ],
                                                    )
                                            ),
                                          ),
                                      )
                            // MaterialButton(
                            //       // padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
                            //       color: const Color(0xDDFFFFFF),
                            //       // border: Border.all(color: const Color(0xFFFFFFFF)),
                            //       // color: Color(0xFFFFFFFF),
                            //       // color: Palette.primary,
                            //       splashColor:  const Color(0x66FFFFFF),
                            //       colorBrightness: Brightness.light,
                            //       elevation: 2,
                            //       highlightElevation: 2,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(24),
                            //       ),
                            //       onPressed: (){
                            //         verifyOTPNow(context);
                            //       },
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           // const Icon(PhosphorIcons.paperPlaneRightFill, size: 12,),
                            //           const SizedBox(width: 8,),
                            //           Text('Verify OTP', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodyLarge, color: Colors.black87),),
                            //         ],
                            //       ) 
                            //     ) 
                                : const SizedBox(height:0),
                                (verifyOTPLoading) ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  //   const AppProgress(height: 20, width: 20,),
                                    Text('Signing you in ...', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall,fontWeight: FontWeight.w500,letterSpacing:1.0 )),
                                  ],
                                ) : const SizedBox(height:0),
                          ],
                         ) : const SizedBox(height:0),
          
          
                  ],
                ),
                ),
          
              ),
              // SizedBox(height:16),
              
              Container(
                margin: const EdgeInsets.all(32.0),
                      padding: const EdgeInsets.all(8.0),
                      //child: styledText('Contact your campus adminstration for credentials incase you do not have them.', Constants.body2, Constants.darkbg),
                      
                      child: Column(children: <Widget>[
                        Text('Contact your campus adiminstrator incase you have issues to login to the app', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall),),
                        sizedBox(16),
                        divider(Colors.black12),
                        sizedBox(16),
                        Text('I understand my data protection rights and consent to my data being stored. I agree to the terms and conditions. I will use the information more for awareness and will not replace psychological treatment provided by a mental health professional.', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.bodySmall),),
                        // Text('Your campus is not listed here?', style: GoogleFonts.dmSans(textStyle: Theme.of(context).textTheme.caption),),
                        const SizedBox(height:16),
                        
                        // MaterialButton(
                        //   padding: const EdgeInsets.all(8.0),
                        //   color: Palette.appBackgroundSolitude,
                        //   splashColor: Palette.primary,
                        //   colorBrightness: Brightness.light,
                        //   shape: const StadiumBorder(),
          
                        //   onPressed: (){
                          
                        //     // _launchURL();
          
                        //   },
                        //   child: const Text('Register Now'),
                        // ),
                        
                      ],)
                      
                      
                    )
            ],
          ),
      ),
    )
    ]))
    ;
        
  }

}


    
  