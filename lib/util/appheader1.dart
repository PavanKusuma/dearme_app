import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/sizedbox.dart';

class AppHeader1 extends StatelessWidget {

  int backNeeded = 0;
  String header = "", subHeader ="";
  bool connectionStatus = true;
  AppHeader1(String header, String subHeader, int backNeeded, bool connectionStatus, [String? theme]){
    this.header = header;
    this.subHeader = subHeader;
    this.backNeeded = backNeeded;
    this.connectionStatus = connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 16, 8, 8),
      child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          
          backNeeded == 0 ? Container(width: 0, height: 0,) : 
          IconButton(icon: Icon(PhosphorIconsBold.arrowBendUpLeft, color: Theme.of(context).hintColor, size: 24,),
          // IconButton(icon: Icon(Icons.keyboard_backspace, color: Theme.of(context).hintColor, size: 24,),
          onPressed: () => 
              Navigator.pop(context)
            ,
          ),

          Container(
            padding: backNeeded == 1 ? EdgeInsets.fromLTRB(0, 0, 0, 0) : EdgeInsets.all(0), 
            child: Column(
            
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            
            children: <Widget>[
              Text(header, style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold)), 
              // Text(header, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleLarge, fontWeight: FontWeight.w800)),
              subHeader.isNotEmpty ? const SizedBox(
                height: 4.0,
              ) : sizedBox(0),

              subHeader.isNotEmpty ? 
              Text(subHeader, style: GoogleFonts.caveat(textStyle: Theme.of(context).textTheme.titleLarge))
              // Text(subHeader, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall)) 
              : sizedBox(0),
              connectionStatus ? sizedBox(0) : Text('No network detected. Try again later!', style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall, color: Palette.red, fontWeight: FontWeight.bold))
              
            ],
          ),)
        ],
      ),
        
    );
  }
}