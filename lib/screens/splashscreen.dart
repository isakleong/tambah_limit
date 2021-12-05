import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:tambah_limit/screens/login.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  bool _initialized = false;
  bool _error = false;

  String fcmToken = "";

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  FirebaseMessaging messaging;
  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
        print("token: "+value);
        setState(() {
          fcmToken = value;
        });
    });
    startTimer();
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  @override
  Widget build(BuildContext context) {

    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

    // if(_error) {
    //   return SomethingWentWrong();
    // }

    // if (!_initialized) {
    //   return Loading();
    // }

    return Scaffold(
      body: Center(
        child: Container(
          width: mediaWidth-100,
          height: mediaHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: "logo",
                child: InkWell(
                  child: Image.asset(
                    "assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  startTimer() {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, navigate);
  }

  void navigate() {
    // Navigator.pushNamed(
    //   context,
    //   "login"
    // );

    Navigator.push(
                  context,
                  PageRouteBuilder(
                      transitionDuration: Duration(seconds: 4),
                      pageBuilder: (_, __, ___) => Login()));

  }

}