import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tambah_limit/screens/routing.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  await Firebase.initializeApp();

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
          int notificationType = 0;
    
          pages = settings.name.split("/");
    
          // contohnya route/id/mode
          // optional : arguments
    
          // mode 0 = gk dari mana2
          // mode 1 = api
          // mode 2 = local storage
          // mode 3 = dari model
          
          // notificationType 0 = onbackground / terminate
          // notificationType 1 = in-app
          // customNavigator(context, "quizInfo/${item.id}/3", arguments: item);
          if (pages.length > 1) {
            id = int.tryParse(pages[1]);
          }
          if (pages.length > 2) {
            mode = int.tryParse(pages[2]);
          }
          if (pages.length > 3) {
            notificationType = int.tryParse(pages[3]);
          }
    
          return routing(mode, id, pages, notificationType, settings);
        },
      ),
    )
  );

}
