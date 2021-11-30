import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tambah_limit/screens/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {

    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

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
                      transitionDuration: Duration(seconds: 5),
                      pageBuilder: (_, __, ___) => Login()));

  }

}