import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;

import 'package:tambah_limit/screens/login.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String isGetVersionSuccess = "";
  bool isLoadingVersion = true;

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
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);

    doCheckVersion();
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  @override
  Widget build(BuildContext context) {

    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          width: mediaWidth-100,
          height: mediaHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: InkWell(
                  child: Image.asset(
                    "assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain,
                  ),
                ),
              ),
              Center(
                child: Visibility(
                  maintainSize: true, 
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isLoadingVersion,
                  child: CircularProgressIndicator(
                    backgroundColor: config.primaryColor,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  doCheckVersion() async {
    setState(() {
      isLoadingVersion = true;
    });
    
    //get apk version
    String checkVersion = await getVersion(context);

    printHelp("cek error "+isGetVersionSuccess);

    setState(() {
      isLoadingVersion = false;
    });

    if(isGetVersionSuccess == "OK") {
      if(checkVersion != config.apkVersion) {
        Alert(
          context: context,
          title: "Info,",
          content: Text("Terdapat pembaruan versi aplikasi. Otomatis mengunduh pembaruan aplikasi setelah tekan OK"),
          cancel: false,
          type: "warning",
          defaultAction: (){
            requestCameraPermission();
          }
        );
      } else {
        startTimer();
      }
    } else {
      Alert(
        context: context,
        title: "Oops,",
        content: Text(isGetVersionSuccess),
        cancel: false,
        type: "error",
        defaultAction: () {
          // doCheckVersion();
        }
      );
    }
  }

  Future<void> requestCameraPermission() async {
    
    final serviceStatus = await Permission.camera.isGranted ;
 
    bool isCameraOn = serviceStatus == ServiceStatus.enabled;
 
    final status = await Permission.camera.request();
 
    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Future<void> checkPermissionYaaa() async {
    final serviceStatus = await Permission.storage.isGranted;

    bool isPermissionGranted = serviceStatus == ServiceStatus.enabled;

    final status = await Permission.storage.request();

    if(status == PermissionStatus.granted) {
      print("granted");
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }

  }

  Future<void> downloadNewVersion() async {
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getVersion.php";
    String url_address_2 = config.baseUrlAlt + "/" + "getVersion.php";

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      printHelp("GET STATUS 1 "+conn_1);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isGetVersionSuccess = "Gagal terhubung dengan server";
    }

    if(isUrlAddress_1) {
      url = url_address_1;
    } else {
      try {
        final conn_2 = await ConnectionTest(url_address_2, context);
        printHelp("GET STATUS 2 "+conn_2);
        if(conn_2 == "OK"){
          isUrlAddress_2 = true;
        }
      } on SocketException {
        isUrlAddress_2 = false;
        isGetVersionSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }


  }

  Future<String> getVersion(final context, {String parameter=""}) async {
    Client client = Client();
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getVersion.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getVersion.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      printHelp("GET STATUS 1 "+conn_1);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isGetVersionSuccess = "Gagal terhubung dengan server";
    }

    if(isUrlAddress_1) {
      url = url_address_1;
    } else {
      try {
        final conn_2 = await ConnectionTest(url_address_2, context);
        printHelp("GET STATUS 2 "+conn_2);
        if(conn_2 == "OK"){
          isUrlAddress_2 = true;
        }
      } on SocketException {
        isUrlAddress_2 = false;
        isGetVersionSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      try {
        final response = await client.get(url);

        if(response.body.toString() != "false") {
          isGetVersionSuccess = "OK";
        } else {
          isGetVersionSuccess = "Gagal terhubung dengan server";
        }
      } catch (e) {
        isGetVersionSuccess = "Gagal terhubung dengan server";
        printHelp(e);
      }
    } else {
      isGetVersionSuccess = "Gagal terhubung dengan server";
    }

    return isGetVersionSuccess;
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

    Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      transitionDuration: Duration(seconds: 4),
                      pageBuilder: (_, __, ___) => Login()));

  }

}