import 'package:flutter/material.dart';
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
    default:
      return MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text("Error")),
          body: Center(child: Text('Error page')),
        );
    });
  }
}