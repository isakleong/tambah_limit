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

MaterialPageRoute routing(int mode, int id, List<String> pages, RouteSettings settings) {
  switch (pages[0]) {
    case '':
      return MaterialPageRoute(builder: (context)=> SplashScreen());
      break;
    case 'login':
      return MaterialPageRoute(builder: (context)=> Login(result: settings.arguments));
      break;
    case 'dashboard':
      return MaterialPageRoute(builder: (context)=> Dashboard());
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
      return MaterialPageRoute(builder: (context)=> HistoryLimitRequestDetail(model: settings.arguments));
      break;
    case 'getHistoryLimitDetail1':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitDetail", type: 1));
      break;
    case 'getHistoryLimitDetail2':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitDetail", type: 2));
      break;
    case 'getHistoryLimitDetail3':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitDetail", type: 3));
      break;
    case 'getHistoryLimitGabunganDetail1':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitGabunganDetail", type: 1));
      break;
    case 'getHistoryLimitGabunganDetail2':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitGabunganDetail", type: 2));
      break;
    case 'getHistoryLimitGabunganDetail3':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "historyLimitGabunganDetail", type: 3));
      break;
    case 'addLimitDetail':
      return MaterialPageRoute(builder: (context)=> AddLimitDetail(model: settings.arguments, callMode: "addLimitDetail"));
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