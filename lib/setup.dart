
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psych_app/appointments.dart';
import 'package:psych_app/appointments_admin.dart';
import 'package:psych_app/chat_detail.dart';
import 'package:psych_app/chat_admin.dart';
import 'package:psych_app/chat_start.dart';
import 'package:psych_app/dashboard_admin.dart';
import 'package:psych_app/dashboard_admin2.dart';
import 'package:psych_app/library2.dart';
import 'package:psych_app/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psych_app/dashboard.dart';
import 'package:psych_app/library.dart';
import 'package:psych_app/tools.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/destination.dart';
// import 'package:smart_campus/circular_new.dart';
// import 'package:smart_campus/destination.dart';
// import 'package:smart_campus/feed.dart';
// import 'package:smart_campus/home.dart';
// import 'package:smart_campus/profile.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/constants.dart' as Constants;


class SetUp extends StatefulWidget {
  @override
  _SetUpState createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> with TickerProviderStateMixin<SetUp> {
  int _currentIndex = 0;
  String role = '';
  final PageController controller = PageController(); 

   @override
  void initState() {
    
    getUserData();
    super.initState();
  }

  // get user data
  void getUserData() async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
      if(preferences.containsKey(Constants.username)){
        setState(() {
          role = preferences.getString(Constants.role)!;
        });
        
      }
  }
  


  int currentIndex = 0;
  final tabPages = [
    const Dashboard(),
    const Appointments(),
    const Tools(),
    const ChatStart(),
    const Profile(),
  ];
  final tabPagesAdmin = [
    const DashboardAdmin2(),
    const AppointmentsAdmin(),
    const ChatAdmin(),
    const Profile(),
  ];


// Widget _buildCurrentScreen(int index) {
//   switch (index) {
//     case 0:
//       return Dashboard();
//     case 2:
//       return Appointments();
//     // Add more cases for other indices/screens
//     default:
//       return Dashboard();
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // helps to customise bottom navigation 
      
      body: 
      PageView(        /// Wrapping the tabs with PageView
        controller: controller,
        children: (role == Constants.admin) ? tabPagesAdmin : tabPages,
        // children: (role == Constants.admin) ? tabPagesAdmin : tabPages,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;     /// Switching bottom tabs
          });
        },
      ),
      // SafeArea(maintainBottomViewPadding: true,
      //   top: false,
      //   child: IndexedStack(
      //     index: _currentIndex,
      //     children:  
      //     // allDestinations.map<Widget>((Destination destination) {
      //     //   return _buildCurrentScreen(_currentIndex);
            
      //     // }).toList(),
      //     allDestinations.map<Widget>((Destination destination) {
            
      //       switch (destination.title) {
      //         case 'Home':
      //           return Dashboard();
      //         case 'Book':
      //           return Appointments();
                
      //         default: 
      //           return Dashboard();
      //       }
            
      //     }).toList(),
      //   ),
      // ),
      bottomNavigationBar: Theme(
        data: 
      Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedIconTheme: IconThemeData(color: Palette.appPrimary),
            selectedItemColor: Palette.appPrimary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            
            // backgroundColor: Palette.white.withOpacity(0.4),
            elevation: 8,
            // shape: const RoundedRectangleBorder(
            //   borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(16.0),
            //     topRight: Radius.circular(16.0),
            //   ),
            // ),
          ),
        ), 
        child:
        Opacity(
          opacity: 1,
        child: 
        Container( 
            // padding: EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                Colors.white.withOpacity(0.8),
                Colors.white,
              ]),
              // color: Colors.black,
              // color: Palette.white,
              borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
              ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 20.0,
                offset: Offset(0,3),
              )
            ],
            ),

            
            // decoration: BoxDecoration(
            //   // color: Colors.black,
            //   color: Palette.white,
            //   borderRadius: const BorderRadius.only(
            //                 topLeft: Radius.circular(12.0),
            //                 topRight: Radius.circular(12.0),
            //                 bottomLeft: Radius.circular(12.0),
            //                 bottomRight: Radius.circular(12.0),
            //   ),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Colors.black12,
            //     spreadRadius: 2,
            //     blurRadius: 20.0,
            //   )
            // ],
            // ),


            child:
      BottomNavigationBar(
        backgroundColor: Palette.white.withOpacity(0.8),
        type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            // if(index == 4){ // this will launch a new screen
            //   Navigator.of(context).push(_createRoute());
            //   // _showModalBottomSheet(context, 'ok');
            //   // Navigator.push(context, MaterialPageRoute(builder: (context) => NewCircular()));
            // }
            // else {
            //   _currentIndex = index;
            // }
            _currentIndex = index;
            controller.jumpToPage(index);  
          });
        },
        // elevation: 18.0,
        
        items: ((role == Constants.admin) ? adminDestinations : allDestinations).map((Destination destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),
            label: destination.title,
          );
        }).toList(),
        )),
        )
        )
      
    
    );
  }

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Dashboard(),
    // pageBuilder: (context, animation, secondaryAnimation) => NewCircular(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

  // show bottom sheet
  _showModalBottomSheet(BuildContext context, String message){
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          decoration: BoxDecoration(
            
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
          ),
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedBox(8),
              Text('Disclaimer', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.headline5)),
              sizedBox(16),
              Text(message, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyText1)),
            ],
          ),
          
          
        );

    });
  }
}