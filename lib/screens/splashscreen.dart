import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
  bool isLoadingVersion = false;

  bool isDownloadNewVersion = false;
  double progressValue = 0.0;
  String progressText = "";

  StateSetter _setState;

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

    final isPermissionStatusGranted = await checkAppsPermission();
    if(isPermissionStatusGranted) {
      doCheckVersion();
    } else {
      checkAppsPermission();
    }
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<void> downloadNewVersion() async {
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + config.apkName+".apk";
    String url_address_2 = config.baseUrlAlt + "/" + config.apkName+".apk";

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
      final isPermissionStatusGranted = await checkAppsPermission();

      if(isPermissionStatusGranted) {
        try {
          Dio dio = Dio();

          String downloadPath = await getFilePath(config.apkName+".apk");

          printHelp("download path "+downloadPath);
          printHelp("url download "+ url);

          // await dio.download(url, downloadPath, onReceiveProgress: (received, total){
          //   if(total != -1) {
          //     setState(() {
          //       // progressValue = (received / total * 100).toStringAsFixed(0) + "%";
          //       isDownloadNewVersion = true;
          //       progressValue = (received / total * 100)/100;
          //       progressText = (received / total * 100).toStringAsFixed(0) + "%";
          //     });
          //   }
          // });

          dio.download(url, downloadPath,
            onReceiveProgress: (rcv, total) {
              print(
                  'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

              _setState(() {
                progressValue = (rcv / total * 100)/100;
                progressText = ((rcv / total) * 100).toStringAsFixed(0);
              });

              if (progressText == '100') {
                _setState(() {
                  isDownloadNewVersion = true;
                });
              } else if (double.parse(progressText) < 100) {}
            },
            deleteOnError: true,
          ).then((_) async {
            _setState(() {
              if (progressText == '100') {
                isDownloadNewVersion = true;
              }

              isDownloadNewVersion = false;
            });

            Navigator.of(context).pop();
            var directory = await getApplicationDocumentsDirectory(); OpenFile.open(downloadPath);

            setState(() {
              isLoadingVersion = false;
              isDownloadNewVersion = false;
            });
          });

        } catch (e) {

        }

      }

    } else {
      //gagal terhubung
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: Visibility(
                  maintainSize: !isDownloadNewVersion, 
                  maintainAnimation: !isDownloadNewVersion,
                  maintainState: !isDownloadNewVersion,
                  visible: !isDownloadNewVersion,
                  child: InkWell(
                    child: Image.asset(
                      "assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Center(
                child: Visibility(
                  maintainSize: !isDownloadNewVersion, 
                  maintainAnimation: !isDownloadNewVersion,
                  maintainState: !isDownloadNewVersion,
                  visible: isLoadingVersion,
                  child: CircularProgressIndicator(
                    backgroundColor: config.primaryColor,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              // Center(
              //   child: Visibility(
              //     maintainSize: true, 
              //     maintainAnimation: true,
              //     maintainState: true,
              //     visible: isDownloadNewVersion,
              //     child: CircularPercentIndicator(
              //       radius: 120.0,
              //       lineWidth: 13.0,
              //       animation: true,
              //       percent: progressValue,
              //       center: new Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              //       footer: Padding(
              //         padding: EdgeInsets.only(top: 30),
              //         child: new Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
              //       ),
              //       circularStrokeCap: CircularStrokeCap.round,
              //       progressColor: config.primaryColor,
              //     ),
              //   ),
              // ),

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
        printHelp("hmm check version "+ checkVersion);
        printHelp("hmm check version "+ config.apkVersion);
        Alert(
          context: context,
          title: "Info,",
          content: Text("Terdapat pembaruan versi aplikasi. Otomatis mengunduh pembaruan aplikasi setelah tekan OK"),
          cancel: false,
          type: "warning",
          defaultAction: (){
            setState(() {
              isLoadingVersion = false;
              isDownloadNewVersion = true;
            });
            downloadNewVersion();
            showDialog (
              context: context,
              barrierDismissible: false,
              builder: (context){
                return WillPopScope(
                  onWillPop: null,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.5)),
                    ),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                      _setState = setState;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: CircularPercentIndicator(
                              radius: 120.0,
                              lineWidth: 13.0,
                              animation: false,
                              percent: progressValue,
                              center: new Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              footer: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: new Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: config.primaryColor,
                            ),
                          ),
                        ],
                      );
                    }),
                  )
                );
              }
            );

            
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

  Future<bool> checkAppsPermission() async {
    final serviceStatus = await Permission.storage.isGranted;

    bool isPermissionGranted = serviceStatus == ServiceStatus.enabled;

    final status = await Permission.storage.request();

    // if(status == PermissionStatus.granted) {
    // } else if (status == PermissionStatus.denied) {
    //   print('Permission denied');
    // } else if (status == PermissionStatus.permanentlyDenied) {
    //   print('Permission Permanently Denied');
    // }

    if(status != PermissionStatus.granted) {
      await openAppSettings();
    }

    return status == PermissionStatus.granted;

  }

  Future<String> getFilePath(filename) async {
    String path = '';

    Directory dir = await getExternalStorageDirectory();

    path = '${dir.path}/$filename';

    return path;
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

    var response;
    if(url != "") {
      try {
        response = await client.get(url);

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

    printHelp("lempar "+response.body.toString());

    return response.body.toString();
  }

  startTimer() {
    var _duration = Duration(milliseconds: 1000);
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
                      transitionDuration: Duration(seconds: 5),
                      pageBuilder: (_, __, ___) => Login()));

  }

}