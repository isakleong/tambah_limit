import 'package:flutter/material.dart';
import 'package:tambah_limit/models/customerModel.dart';

class Configuration extends InheritedWidget {
  Configuration({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  String ip_public = "203.142.77.243";
  String ip_public_alt = "103.76.27.124";
  String ip_port = "80" ;
  String serverName = "dbrudie-2-0-0";
  String apkName = "Tambah Limit";
  String apkVersion = "1.1";

  String get baseUrl => "http://"+ip_public+":"+ip_port+"/"+serverName;
  String get baseUrlAlt => "http://"+ip_public_alt+":"+ip_port+"/"+serverName;

  String initRoute = "";

  bool updateShouldNotify(oldWidget) => true;
  
  static Configuration of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType());
  }

  Color topBarBackgroundColor = Color(0xFF0094DA);
  Color topBarTextColor = Color(0xFFF8F8F8);

  Color bottomBarBackgroundColor = Color(0xFFF0F0F0);
  Color bottomBarTextColor = Color(0xFF333333);

  Color bodyBackgroundColor = Color(0xFFF7F7F7);

  Color primaryColor = Color(0xFF2BB7FC);
  Color primaryTextColor = Color(0xFFF8F8F8);
  Color secondaryColor = Colors.orange;
  Color secondaryTextColor = Color(0xFF333333);

  Color grayColor = Color(0xFF545454);
  Color lightGrayColor = Color(0xFFC4C4C4);
  Color lighterGrayColor = Color(0xFFDDDDDD);
  Color whiteGrayColor = Color(0xFFF0F0F0);

  //gradient color
  Color blueColor = Color(0xFF0094DA);
  Color lightBlueColor = Color(0xFFEAF8FF);
  Color lightOpactityBlueColor = Color(0xFFD2EEFA);
  Color lightBlueColorNonActive = Color(0xFFE5F2F8);
  Color orangeColor = Color(0xFFFBB04B);
  Color lightOrangeColor = Color(0xFFFFF1DD);
  Color darkGreenColor = Color(0xFF27AE60);
  Color lightDarkGreenColor = Color(0xFFE7FFF1);
  Color purpleColor = Color(0xFF9B51E0);
  Color lightPurpleColor = Color(0xFFFAEDFF);
  Color limeColor = Color(0xFFA5D03E);
  Color lightLimeColor = Color(0xFFF0FFCE);
  Color greenColor = Color(0xFF60CBB0);
  Color lightGreenColor = Color(0xFFDFFFF7);
  Color pinkColor = Color(0xFFE252BA);
  Color lightPinkColor = Color(0xFFFFEDFA);
  Color darkOrangeColor = Color(0xFFFF8227);
  Color lightDarkOrangeColor = Color(0xFFFFE0C9);
  Color brownColor = Color(0xFF9B5D00);
  Color lightBrownColor = Color(0xFFFFF2E5);
  Color darkBlueColor = Color(0xFF0840CE);
  Color darkOpacityBlueColor = Color(0xFF0077AF);
  Color darkerBlueColor = Color(0xFF006EA3);
  Color lightDarkBlueColor = Color(0xFFEAF0FF);
  Color grayNonActiveColor = Color(0xFFBDBDBD);

}

final config = Configuration();