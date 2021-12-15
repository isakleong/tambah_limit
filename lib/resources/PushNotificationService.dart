
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/tools/function.dart';


Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final bodyCtlr = StreamController<String>.broadcast();
  final idCtlr = StreamController<String>.broadcast();
  final userCodeCtlr = StreamController<String>.broadcast();
  final customerCodeCtlr = StreamController<String>.broadcast();
  final limitCtlr = StreamController<String>.broadcast();

  setNotifications() async {
    // With this token you can test it easily on your phone
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    // final token = firebaseMessaging.getToken().then((value) async => await sharedPreferences.setString("fcmToken", value));

    final getToken = firebaseMessaging.getToken().then((value) {
        print("token: "+value);
    });
    //get fcm token
    String token = await FirebaseMessaging.instance.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmToken", token);

    String fcmToken = prefs.getString("fcmToken");
    printHelp("simpan "+fcmToken);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) async {
        if (message.data.containsKey('id')) {
          idCtlr.sink.add(message.data['id']);
        }
        if (message.data.containsKey('user_code')) {
          userCodeCtlr.sink.add(message.data['uder_code']);
        }
        if (message.data.containsKey('customer_code')) {
          customerCodeCtlr.sink.add(message.data['customer_code']);
        }
        if (message.data.containsKey('limit')) {
          limitCtlr.sink.add(message.data['limit']);
        }

        // Or do other work.
        bodyCtlr.sink.add(message.notification.body);
      },
    );

  }

  dispose() {
    idCtlr.close();
    userCodeCtlr.close();
    customerCodeCtlr.close();
    limitCtlr.close();
    bodyCtlr.close();
  }



}