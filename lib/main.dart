import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tambah_limit/screens/routing.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    Configuration(
      child: MaterialApp (
        title: config.apkName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0),
          )
        ),
        onGenerateRoute: (RouteSettings settings) {
          List<String> pages = [];
          int mode = 0;
          int id = 0;

          pages = settings.name.split("/");

          // contohnya route/id/mode
          // optional : arguments

          // mode 0 = gk dari mana2
          // mode 1 = api
          // mode 2 = local storage
          // mode 3 = dari model
          if (pages.length > 1) {
            id = int.tryParse(pages[1]);
          }
          if (pages.length > 2) {
            mode = int.tryParse(pages[2]);
          }
          
          return routing(mode, id, pages, settings);
        },
      ),
    )
  );
}
