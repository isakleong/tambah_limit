import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tambah_limit/resources/messageHandler.dart';

import 'package:tambah_limit/screens/routing.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

import 'models/resultModel.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
  // Messagehandler messagehandler = new Messagehandler();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
  //     print("message recieved yaaa hehehe");
  //     print(event.notification.body);
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Notification"),
  //           content: Text(event.notification.body),
  //           actions: [
  //             TextButton(
  //               child: Text("Ok"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //         );
  //       });
  // });
  

  HttpOverrides.global = MyHttpOverrides();
  runApp(
    Configuration(
      child: OverlaySupport.global(
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
            // customNavigator(context, "quizInfo/${item.id}/3", arguments: item);
            if (pages.length > 1) {
              id = int.tryParse(pages[1]);
            }
            if (pages.length > 2) {
              mode = int.tryParse(pages[2]);
            }
      
            return routing(mode, id, pages, settings);
          },
        ),
      ),
    )
  );

}
