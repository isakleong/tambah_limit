import 'package:flutter/material.dart';
import 'package:tambah_limit/models/customerModel.dart';

class Configuration extends InheritedWidget {
  Configuration({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  String ip_public = "103.76.27.110";
  // String ip_public_alt = "192.168.10.216";
  String ip_public_alt = "apps.tirtakencana.com";
  // String ip_port = "80" ;
  String serverName = "dbrudie-2-0-0-dev";
  String apkName = "Tambah Limit";
  String apkVersion = "1.1";
  String getMessage = "";

  // String get baseUrl => "http://"+ip_public+":"+ip_port+"/"+serverName;
  // String get baseUrlAlt => "http://"+ip_public_alt+":"+ip_port+"/"+serverName;

  String get baseUrl => "http://"+ip_public+"/"+serverName;
  String get baseUrlAlt => "http://"+ip_public_alt+"/"+serverName;


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
  Color darkBlueColor = Color(0xFF0840CE);
  Color darkOpacityBlueColor = Color(0xFF0077AF);
  Color darkerBlueColor = Color(0xFF006EA3);
  Color lightDarkBlueColor = Color(0xFFEAF0FF);
  Color grayNonActiveColor = Color(0xFFBDBDBD);

  bool isAppLive = false;
  bool isScreenAtDashboard = false;

}

final config = Configuration();