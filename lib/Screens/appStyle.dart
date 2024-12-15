import 'package:flutter/material.dart';

import '../utils/app_layout.dart';


Color primary = const Color(0xFF687daf);
class Styles{
  static Color primaryColor = primary;
  static Color textColor = const Color(0xFF3b3b3b);
  static Color bgColor = const Color(0xFFeeedf2);
  static Color blueColor = const Color(0xFF526799);
  static Color orangeColor = const Color(0xFFF37B67);
  static Color kakiColor = const Color(0xFFd2bdb6);
  static TextStyle textStyle = TextStyle(fontSize: AppLayout.getWidth(15), color: textColor, fontWeight: FontWeight.w500);
  static TextStyle textStyle2 = TextStyle(fontSize: AppLayout.getWidth(25), color: textColor, fontWeight: FontWeight.bold);
  static TextStyle textStyle3 = TextStyle(fontSize: AppLayout.getWidth(20), color: textColor, fontWeight: FontWeight.bold);
  static TextStyle textStyle4 = TextStyle(fontSize: AppLayout.getWidth(16), color: Colors.grey.shade500, fontWeight: FontWeight.w500);
  static TextStyle textStyle5 = TextStyle(fontSize: AppLayout.getWidth(13), color: Colors.grey.shade500, fontWeight: FontWeight.w500);



}