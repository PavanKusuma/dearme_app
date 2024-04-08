import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Destination {
  const Destination(this.title, this.icon);
  final String title;
  final IconData icon;

 
}

const List<Destination> allDestinations = <Destination>[
  Destination('Home', PhosphorIconsRegular.houseSimple),
  // Destination('Learn', PhosphorIconsRegular.list),
  // Destination('New', Icons.add_circle_outline),
  //  Destination('Feed', PhosphorIconsRegular.clipboardText),
   Destination('Book', PhosphorIconsRegular.calendarCheck),
   Destination('Chat', PhosphorIconsRegular.chatCircle),
  //  Destination('Help', PhosphorIconsRegular.lifebuoy),
   Destination('Profile', PhosphorIconsRegular.user)
];