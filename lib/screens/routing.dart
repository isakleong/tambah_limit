import 'package:flutter/material.dart';
import 'package:tambah_limit/screens/addLimit.dart';
import 'package:tambah_limit/screens/addLimitCorporate.dart';
import 'package:tambah_limit/screens/addLimitCorporateDetail.dart';
import 'package:tambah_limit/screens/addLimitDetail.dart';
import 'package:tambah_limit/screens/dashboard.dart';
import 'package:tambah_limit/screens/historyLimitRequest.dart';
import 'package:tambah_limit/screens/historyLimitRequestDetail.dart';
import 'package:tambah_limit/screens/login.dart';
import 'package:tambah_limit/screens/splashscreen.dart';

MaterialPageRoute routing(int mode, int id, List<String> pages, int notificationType, RouteSettings settings) {
  switch (pages[0]) {
    case '':
      return MaterialPageRoute(builder: (context)=> SplashScreen());
      break;
    case 'login':
      return MaterialPageRoute(builder: (context)=> Login(result: settings.arguments));
      break;
    case 'dashboard':
      return MaterialPageRoute(builder: (context)=> Dashboard(indexMenu: id));
      break;
    case 'addLimit':
      return MaterialPageRoute(builder: (context)=> AddLimit());
      break;
    case 'addLimitCorporate':
      return MaterialPageRoute(builder: (context)=> AddLimitCorporate());
      break;
    case 'historyLimitRequest':
      return MaterialPageRoute(builder: (context)=> HistoryLimitRequest());
      break;
    case 'historyLimitRequestDetail':
      return MaterialPageRoute(builder: (context)=> HistoryLimitRequestDetail(mode: mode, id: id, model: settings.arguments, notificationType: notificationType));
      break;
    case 'addLimitDetail':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "addLimitDetail", guestMode: false));
      break;
    case 'guestAddLimitDetail':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "addLimitDetail", guestMode: true));
      break;
    case 'addLimitCorporateDetail':
      return MaterialPageRoute(builder: (context)=> AddLimitCorporateDetail(model: settings.arguments));
      break;
    default:
      return MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text("Error")),
          body: Center(child: Text('Error page')),
        );
    });
  }
}