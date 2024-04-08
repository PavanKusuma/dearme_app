import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/modal/user.dart';
import 'dart:math';
import 'package:psych_app/util/constants.dart' as Constants;

// save into sharedpreferences
Future<bool> saveData(User user) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

   await prefs.setString(Constants.universityId, user.universityId!);
    await prefs.setString(Constants.campusId, user.campusId!);
    await prefs.setString(Constants.username, user.username!);
    await prefs.setString(Constants.email, user.email!);
    await prefs.setString(Constants.collegeId, user.collegeId!);
    await prefs.setString(Constants.branch, user.branch!);
    await prefs.setString(Constants.phoneNumber, user.phoneNumber!);
    await prefs.setString(Constants.role, user.role!);
    await prefs.setInt(Constants.year, user.year!);
    await prefs.setInt(Constants.semester, user.semester!);
    await prefs.setInt(Constants.mediaCount, user.mediaCount!);
    await prefs.setString(Constants.userImage, user.userImage!);
    await prefs.setString(Constants.gcmRegId, user.gcmRegId!);
    await prefs.setString(Constants.course, user.course!);
    await prefs.setString(Constants.section, user.section!);
    await prefs.setString(Constants.type, user.type!);
    await prefs.setString(Constants.outingType, user.outingType!);
    await prefs.setInt(Constants.profileUpdated, user.profileUpdated!);


    await prefs.setString(Constants.fatherName, user.fatherName!);
    await prefs.setString(Constants.fatherPhoneNumber, user.fatherPhoneNumber!);
    await prefs.setString(Constants.motherName, user.motherName!);
    await prefs.setString(Constants.motherPhoneNumber, user.motherPhoneNumber!);
    await prefs.setString(Constants.guardianName, user.guardianName!);
    await prefs.setString(Constants.guardianPhoneNumber, user.guardianPhoneNumber!);
    await prefs.setString(Constants.guardian2Name, user.guardian2Name!);
    await prefs.setString(Constants.guardian2PhoneNumber, user.guardian2PhoneNumber!);
    await prefs.setString(Constants.address, user.address!);
    await prefs.setString(Constants.hostelId, user.hostelId!);
    await prefs.setString(Constants.roomNumber, user.roomNumber!);
    await prefs.setString(Constants.hostelName, user.hostelName!);
    await prefs.setBool(Constants.notify, false);
    
    return true;
    
}

// save notification sharedpreferences
Future<bool> saveNotificationPreference(bool pref) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(Constants.notify, pref);
    return true;
    
}

// clear notification sharedpreferences
Future<bool> removeNotificationPreference() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.notify);
    
    return true;
    
}


// void setGlobalTheme(bool value) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(Constants.themeStatus, value);
// }

// clear all data
void clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

// get OTP
String randomOTP() {

  const chars = "0123456789";

  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 4; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  print(result);
  return result;
}
// get objectId
String randomString(String s) {

  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 9; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  print(s+result);
  return s+result;
}
// get acronym of names
String getAcronym(String s){

  String acronym = '';
  String newS = s.replaceAll(RegExp(r'  '), ' ');

  // try{
    
      var words = newS.trim().split(" ");

      for(int i=0; i<words.length && i<2; i++){
        //print(words[i]);
        acronym = acronym + words[i][0];
      }
    

  return acronym;
}

// get list from string array
List<String> getListFromArray(String s){

  List<String> list = [];

  //try{
    
      var words = s.trim().split(",");

      
      for(int i=0; i<words.length; i++){
        //print(words[i]);
        list.add(words[i]);
      }
    

  return list;
}

// get the student type
// 0 – Inactive - out of college
// 1 – Totally active
// 2 - Totally active - but profile not updated
// 3 – Totally active – Outing blocked
// 4 - Totally active – Temporary day scholar
String getStudentType(int profileUpdated, String type){

  switch (profileUpdated) {
    case 0:
      return 'Inactive - out of college';
    case 1:
      if(type.toLowerCase() == 'hostel'){
        return 'Hosteler';
      }
      else {
        return 'Day Scholar';
      }
    case 4:
      return 'Temporary Day Scholar';
    default:
    return '';
  }

  
}

// get formatted datetime
DateTime getDate(String date){
  // parse UTC time sent by server
  if(date.contains('T'))
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 'en_US').parseUTC(date);
  else {
    return DateFormat("yyyy-MM-dd HH:mm:ss", 'en_US').parseUTC(date);
  }
}

// get formatted datetime
TimeOfDay getTime(String date){
  // parse UTC time sent by server

    return TimeOfDay.fromDateTime(DateTime.parse(date));

}

// get formatted datetime
int getDuration(DateTime fromDate, DateTime toDate){
  DateTime from = DateTime(fromDate.year, fromDate.month, fromDate.day);
  DateTime to = DateTime(toDate.year, toDate.month, toDate.day);

  return to.difference(from).inDays + 1;
}

// get date
DateTime formatDateNow(String dateString){


  // Parse the date string from the server
// final dateString = '2023-05-10 08:16:14';

// Create a DateTime object from the parsed string
final date = DateTime.parse(dateString);
return DateTime(date.year, date.month, date.day);
// Format the date in a specific way using the intl package
// final formatter = DateFormat('yyyy-MM-dd');
// final formattedDate = formatter.format(date);

// return DateTime(formattedDate.year, formattedDate.month, formattedDate.day);

  // DateTime date = DateTime.parse(date1).toLocal();
  // int year = date.year;
  // int month = date.month;
  // int day = date.day;
  // return '$year-$month-$day';
}

// greet with time
String getGreeting(){
  DateTime time = DateTime.now();
  int hour = time.hour;

  if (hour < 12)
   return "Great morning";
  else if (hour < 17 && !(hour == 12))
   return "Good afternoon";
  else if (hour == 12)
   return "Good noon";
  else
   return "Good evening";
 }

// greet with time
String getGreeting1(){
  DateTime time = DateTime.now();
  int hour = time.hour;

  if (hour < 12)
   return "morning";
  else if (hour < 17 && !(hour == 12))
   return "afternoon";
  else if (hour == 12)
   return "noon";
  else
   return "evening";
 }


// get time difference
String getTimeDiff(DateTime now, DateTime datetime){
  
  int d = now.difference(datetime).inDays;
  // print(now);
  // print(datetime);
  if(d == 0){

    int h = now.difference(datetime).inHours;
    if(h == 0){
      int m = now.difference(datetime).inMinutes;
      
      if(m == 0){
        int s = now.difference(datetime).inSeconds;
        
        return '${(s)} sec(s)';  
      }
    else {
      
      return '${(m)} min(s)';
      }
    }
    else {
      
      return '${(h)} hr(s)';
    }
    
    
  }
  else {

    if(d > 31 && d < 366){
      int mo = d ~/30;
      return '${(mo)} mo';

    }
    else if (d > 365){
      int y = d~/365;
      return '${(y)} yr(s)';
    }
    else{
      
      return '${(d)} day(s)';
    }
  }
  
}

// get the day for the given tab index
String getDayTab(int index){
  switch (index) {
    case 0:
      return 'Monday';
    case 1:
      return 'Tuesday';
      
    case 2:
      return 'Wednesday';
      
    case 3:
      return 'Thursday';
      
    case 4:
      return 'Friday';
      
    case 5:
      return 'Saturday';
      
    case 6:
      return 'Sunday';
      
      
    default:
      return 'Monday';
  }

}

String getHourTime(int hour){
  String hourTime = '';
  switch (hour) {
        case 1:
            hourTime = '09:30:00';
            break;
        case 2:
            hourTime = '10:30:00';
            break;
        case 3:
            hourTime = '11:30:00';
            break;
        case 4:
            hourTime = '12:30:00';
            break;
        case 5:
            hourTime = '13:30:00';
            break;
        case 6:
            hourTime = '14:30:00';
            break;
        case 7:
            hourTime = '15:30:00';
            break;
        case 8:
            hourTime = '16:30:00';
            break;
        case 9:
            hourTime = '17:30:00';
            break;
    
        default:
            break;
    }

    return hourTime;
}

// truncate the string and add ellipsis
String truncateWithEllipsis(String text){
  if(text.length > 75)
    return text.replaceRange(75, text.length, '...');
  else 
    return text;
}
// truncate the string and add ellipsis
String truncate2Lines(String text){
  if(text.length > 40)
    return text.replaceRange(33, text.length, '...');
  else 
    return text;
}
// truncate the string and add ellipsis
String truncate2LinesShort(String text){
  if(text.length > 20)
    return text.replaceRange(20, text.length, '...');
  else 
    return text;
}


List<String> getPastMonths(int count) {
  List<String> monthsList = [];

  DateTime now = DateTime.now();
  for (int i = 0; i < count; i++) {
    DateTime month = DateTime(now.year, now.month - i);
    String monthYear = '${_getMonthName(month.month)}-${month.year}';
    monthsList.add(monthYear);
  }

  return monthsList;
}
String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}

String convertMonthYearToYearMonth(String monthYear) {
  List<String> parts = monthYear.split('-');
  if (parts.length != 2) {
    // Invalid format, return empty string or throw an exception
    return '';
  }

  String month = parts[0].trim();
  String year = parts[1].trim();

  int monthNumber = _getMonthNumber(month);
  if (monthNumber == 0) {
    // Invalid month name, return empty string or throw an exception
    return '';
  }

  String formattedMonth = monthNumber.toString().padLeft(2, '0');
  String formattedYear = year;

  return '$formattedYear-$formattedMonth-01';
}
int _getMonthNumber(String month) {
  switch (month.toLowerCase()) {
    case 'january':
      return 1;
    case 'february':
      return 2;
    case 'march':
      return 3;
    case 'april':
      return 4;
    case 'may':
      return 5;
    case 'june':
      return 6;
    case 'july':
      return 7;
    case 'august':
      return 8;
    case 'september':
      return 9;
    case 'october':
      return 10;
    case 'november':
      return 11;
    case 'december':
      return 12;
    default:
      return 0;
  }
}

// check the internet connectivity
  Future<bool> checkInternetConnectivity() async {
    try {
    final result = await InternetAddress.lookup('google.com');
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
    } on SocketException catch (_) {
      
      return false;
      
    }
  }


/*
// fetch username 
Future<String> getUsername() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.containsKey('username')){
      return preferences.getString('username').toString();
    }
    return '';
}

// fetch userObjectId
Future<String> getUserObjectId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.containsKey('userObjectId')){
      return preferences.getString('userObjectId');
    }
    return '';
}

// fetch phoneNumber
Future<String> getPhoneNumber() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.containsKey('phoneNumber')){
      return preferences.getString('phoneNumber').toString();
    }
    return '';
} */



