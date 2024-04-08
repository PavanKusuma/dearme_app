import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psych_app/audio_handler.dart';
import 'package:psych_app/verify.dart';
// import 'package:psych_app/firstcheck.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io' show Platform;

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:psych_app/dashboard.dart';

import 'package:psych_app/setup.dart';
import 'package:psych_app/verify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:psych_app/welcome2.dart';
import 'package:psych_app/welcoming.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';

late MyAudioHandler _audioHandler;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> main() async {

    WidgetsFlutterBinding.ensureInitialized();

    // initialize timezone data
    tzdata.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    tz.setLocalLocation(locations['Asia/Kolkata']!); // set your local timezone

    // initialize the notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.piltovr.dearme',
        androidNotificationChannelName: 'Playback'
      ),
    );

    
    _audioHandler.pause();

  // runApp(const GreetUser());
  // runApp(MyWelcome(audioHandler: _audioHandler));

  runApp(Provider<AudioHandler>.value(
    value: _audioHandler,
    child: MyWelcome(),
  ));
  
  // runApp(MyApp());
  // runApp(const Verify());

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = false;

    //Remove this method to stop OneSignal Debugging 
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    
    OneSignal.initialize("0858bdf0-8cdf-45ed-9fce-4e231fbbc6d3");
    // OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: false);
    // OneSignal.shared.setLaunchURLsInApp(true);


    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.permissionNative().then((accepted) {
        
        // if accepted is "False", it means the permission is not provided yet.
        print("Accepted permission: $accepted");

        // check if the platform is IOS and prompt for the permission.
        // if(Platform.isIOS){
        //   if(!accepted) {
        //     print("False");
        //       checkNotificationPermission();
        //   }
        //   else {
        //     print("Already done!");
        //   }
        // }
    });




    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
            event.notification;                                 
    });

    OneSignal.Notifications.addClickListener((event) {
      // Will be called whenever a notification is opened/button pressed.
    });

    OneSignal.Notifications.addPermissionObserver((permission) {
        // Will be called whenever the permission changes
        // (ie. user taps Allow on the permission prompt in iOS)
        log('Permission state changed: ${permission.toString()}');

        //  OSPermissionState permissionState = changes.to;
        // print('Permission state changed: ${permissionState.status}');

        // if(permissionState.status != OSNotificationPermission.authorized){
        //   print("Calling to open prompt");
        //   // checkNotificationPermission();

        //   OneSignal.shared.promptUserForPushNotificationPermission();
        // }

    });

    // OneSignal.Notifications. shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    //     // Will be called whenever the subscription changes 
    //     // (ie. user gets registered with OneSignal and gets a user ID)
    // });

}


void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  runApp(MyWelcome());
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: Text(title??''),
  //     content: Text(body??''),
  //     actions: [
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: Text('Ok'),
  //         onPressed: () async {
  //           Navigator.of(context, rootNavigator: true).pop();
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => Welcome(),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   ),
  // );
}


// prompt the permission prompt
// void checkNotificationPermission() async{
  
//   // If you want to know if the user allowed/denied permission,
//   // the function returns a Future<bool>:
//   bool allowed = await OneSignal.not.promptUserForPushNotificationPermission(fallbackToSettings: true);
  
//   if(!allowed){
//     // print("About to prompt");
//     OneSignal.shared.promptUserForPushNotificationPermission();
    
//   }
//   else {
//     // do nothing
//     // print("Not Allowed");
//   }
// }
