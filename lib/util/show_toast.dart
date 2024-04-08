import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:psych_app/util/palette.dart';
import 'package:psych_app/util/sizedbox.dart';
import 'package:psych_app/util/constants.dart' as Constants;

void showToast(BuildContext context, String message, String type){
  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),));

  ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//   behavior: SnackBarBehavior.floating,
//   content: Text(message),
//   action: SnackBarAction(
//     label: 'Okay',
//     onPressed: () {},
//   ),
// )

  SnackBar(
    //  margin: const EdgeInsets.all(16.0),
      // padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),                 
    // backgroundColor: Colors.white.withOpacity(0.1),
    // backgroundColor: Palette.white.withOpacity(0),
    backgroundColor: Theme.of(context).cardColor,
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    elevation: 2.0,
    content: 
    Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // width: double.infinity,
          // constraints: BoxConstraints(maxWidth: double.infinity),
          // padding: const EdgeInsets.fromLTRB(8,8,16,8),
          // decoration: BoxDecoration(
          //   // borderRadius: BorderRadius.circular(25),
          //   color: Theme.of(context).cardColor,
          //   border: Border.all(
          //     color: Palette.appBackgroundSolitude,
          //     width: 1,
          //   ),
          // ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              (type == Constants.success) ?
              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), color: Palette.green)
              :
              (type == Constants.error) ?
              Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.bold), color: Palette.error)
              :
              Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), color: Palette.yellow),
              const SizedBox(width: 8),
              Flexible(child:       
                Text(message, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge,)),),
            ],
          ),
        ),
      ],
    ) 
  ),
);
  // Scaffold.of(context).showSnackBar(SnackBar(content: Text(message),));
}