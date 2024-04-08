import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_campus/util/darkthemeprovider.dart';
import 'dart:math';

class Palette {
  // update this file for creating dark and light theme
  //static Color textPrimary, textSecondary, caption, good, bad, warning, appBackground;
  Palette(){
    
    // checkTheme();

    // get the selected theme
    // var themeChange = Provider.of<DarkThemeProvider>(BuildContext());
    // static bool darkTheme = DarkThemeProvider().darkTheme;
    // bool value = themeChange.darkTheme;
    
  }
// static bool darkTheme = DarkThemeProvider().darkTheme;

//   static void checkTheme() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     if(preferences.containsKey('theme')){
//       preferences.getString('theme');

//     }
//     else {
//         print('no theme');
//     }
//   }

//   static Color randomColor() {
//       return darkTheme ? Color((Random().nextDouble()*0xAAAA33).toInt() << 0).withOpacity(1) : Color((Random().nextDouble()*0xAAAA33).toInt() << 0).withOpacity(0.2);
//   }
//   static Color randomColor2() {
//       return Color((Random().nextDouble()*0xAAAA33).toInt() << 0).withOpacity(1);
//   }





  // feature colors
  static Color primary = Color(0xFF2567F6);
  static Color primaryDark = Color(0xFF2845E0);
  static Color background = Color(0xFF101426);
  static Color accent = Color(0xFFF6A225);
  static Color blue = Color(0xFF2567F6);
  static Color red = Color(0xFFF26255);
  static Color error = Color(0xFFC81100);
  static Color redLight = Color(0xFFFCDCD9);
  static Color green = Color(0xFF14961A);
  static Color greenLight = Color(0xFFD7FDD9);
  static Color one = Color(0xFF5FDAD0);
  static Color two = Color(0xFFAEB8FA);

  
  // feature colors
  static Color leaveBg = Color(0xFFFFD54F);
  static Color outingBg = Color(0xFFDA4743);
  static Color lightRedBg = Color(0xFFFAE2E8);

  // texts on light background
  static Color text1Dark = Color(0xDE000000);
  static Color text2Dark = Color(0x99000000);
  static Color text3Dark = Color(0x5E000000);

  // texts on dark background
  static Color text1Light = Color(0xDEFFFFFF);
  static Color text2Light = Color(0x99FFFFFF);
  static Color text3Light = Color(0x5EFFFFFF);

  static Color white = Color(0xFFFFFFFF);
  static Color black = Color(0xFF000000);
  static Color transparent = Color(0x00FFFFFF);
  


  static Color textPrimaryDark = Color(0xFF223547);
  static Color textPrimary = Color(0xDEFFFFFF);
  static Color textSecondary = Color(0x99FFFFFF);
  static Color text3 = Color(0x61FFFFFF);

  static Color appBackground = Color(0xFF101426);
  //static Color textPrimary = Color(0xFF333333);
  static Color textMiddle = Color(0xFF666666);
  //static Color textSecondary = Color(0xFF999999);
  static Color textThird = Color(0xFFcccccc);
  static Color lightBackground = Color(0xFFE8F0FE);
  static Color lightBackground2 = Color(0xFFFEE8E8);
  static Color lightBackground3 = Color(0xFFFEF8E8);
  static Color line = Color(0x65101426);
  static Color appPrimary = Color(0xFF2567F6);
  static Color appPrimaryLight = Color.fromRGBO(228, 236, 252, 1);
  static Color appPrimaryDark = Color(0xFF2845E0);
  static Color yellow = Color(0xFFF6A225);
  static Color orange = Color(0xFFF67025);
  static Color orangeLight = Color(0xFFFFE9DD);
  static Color violet = Color(0xFF4C51BF);
  static Color violetLight = Color.fromARGB(255, 215, 216, 249);
  static Color yellow1 = Color(0xFFFFD54F);
  static Color blue1 = Color(0xFF4FB5FF);

  static Color paletteRed = Color(0xFFF26255);
  static Color paletteOrange = Color(0xFFFF9159);
  static Color paletteYellow = Color(0xFFFFBF66);


  //static Color appPrimary = Color(0xFF3574F1);
  static Color appPrimaryDark1 = Color(0xFF2567F6);
  static Color appPrimaryDark2 = Color(0xFF2845E0);
  //static Color textPrimary = Color(0xFF223547);
  //static Color textSecondary = Color(0xFF333333);
  static Color textTeritory = Color(0xFF666666);
  static Color textShade1 = Color(0xFF999999);
  static Color textShade2 = Color(0xFFE5E5E5);
  // static Color backgroundShade = Color(0xFFF9F9F9);
//   static Color backgroundShade = (darkTheme ? Color(0xFFF9F9F9) :  Color(0xFF2567F6)) ;
  static Color appBackgroundSolitude = Color(0xFFF3F5F9);
  static Color appBackgroundSolitudeRed = Color(0x99F9D2CB);
  static Color darkText1 = Color(0x65FFFFFF);
  static Color background1 = Color(0x00E1EBF5);

  
}