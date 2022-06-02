import 'dart:io';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:open_file/open_file.dart';
// import 'package:ota_update/ota_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' show Client, Request;
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/screens/login.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();
const debug = true;

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  OtaEvent currentEvent;

  String getCheckVersion = "";
  bool isLoadingVersion = false;

  bool isDownloadNewVersion = false;
  bool isRetryDownload = false;
  bool toInstall = false;
  bool isPermissionPermanentlyDenied = false;
  double progressValue = 0.0;
  String progressText = "";

  StateSetter _setState;

  bool _initialized = false;
  bool _error = false;
  bool isNotificationOpened = false;

  String fcmToken = "";
  String user_code = "";

  String notificationBody = '';
  String notificationId = '';
  String notificationCustomerCode = '';
  String notificationUserCode = '';
  String notificationLimit = '';

  var fileDownloaded = 0;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });

    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      printHelp("error firebase " + e.toString());
      setState(() {
        _error = true;
      });
    }
  }

  FirebaseMessaging messaging;
  Timer timer;
  @override
  void initState() {
    initializeFlutterFire();

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
        print("token splash : "+value);
        setState(() {
          fcmToken = value;
        });
    });
    
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);

    setState(() {
      user_code = sharedPreferences.getString("user_code");
    });

    await getAppsReady();
    
  }

  getAppsReady() async {
    var isNeedOpenSetting = false;
    isPermissionPermanentlyDenied = false;
    final isPermissionStatusGranted = await checkAppsPermission();
    
    if(isPermissionStatusGranted) {
      doCheckVersion();
    } else {
      var isPermissionStatusGranted = false;
      

      while(!isPermissionStatusGranted) {
        if(!isPermissionPermanentlyDenied) {
          isPermissionStatusGranted = await checkAppsPermission();
        } else {
          isNeedOpenSetting = true;
          break;
        }
      }
      if(isNeedOpenSetting) {
        Alert(
          context: context,
          title: "Info,",
          content: Text("Mohon izinkan aplikasi mengakses file di perangkat"),
          cancel: false,
          type: "error",
          errorBtnTitle: "Pengaturan",
          defaultAction: () async {
            isNeedOpenSetting = false;
            await getAppsReady();
            Navigator.of(context).pop();
          }
        );
      } else {
        getAppsReady();
      }
    }
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<bool> isInternet() async {
    printHelp("isinternet");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // connected to mobile network
      if (await DataConnectionChecker().hasConnection) {
        // mobile data detected & internet connection confirmed.
        return true;
      } else {
        // mobile data detected but no internet connection found.
        _setState(() {
          isRetryDownload = true;
        });
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // connected to wifi network
      if (await DataConnectionChecker().hasConnection) {
        // wifi detected & internet connection confirmed.
        return true;
      } else {
        // wifi detected but no internet connection found.
        _setState(() {
          isRetryDownload = true;
        });
        return false;
      }
    } else {
      // neither mobile data or wifi detected, not internet connection found.
      _setState(() {
        isRetryDownload = true;
      });
      return false;
    }
  }

  Future<void> downloadApps() async {
    setState(() {
      isRetryDownload = false;
    });

    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + config.apkName+".apk";
    String url_address_2 = config.baseUrlAlt + "/" + config.apkName+".apk";

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      printHelp("GET STATUS 1 apps "+conn_1);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
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
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      final isPermissionStatusGranted = await checkAppsPermission();
      Client client = Client();

      if(isPermissionStatusGranted) {
        try {
          OtaUpdate().execute(
            url,
            destinationFilename: config.apkName+".apk"
          ).listen(
            (OtaEvent event) async{
              _setState(() {
                  progressValue = double.parse(event.value)/100;
                  progressText = event.value;
              });
            }, onDone: () => timer.cancel()
          );
        } catch (e) {
            print('Failed to make OTA update. Details: $e');
            _setState(() {
              isRetryDownload = true;
            });
        }
      }

    } else {
      //gagal terhubung
      _setState(() {
        isRetryDownload = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          width: mediaWidth-120,
          height: mediaHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AnimatedContainer(
              //   duration: Duration(milliseconds: 250),
              //   child: InkWell(
              //       child: Image.asset(
              //         "assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain,
              //       ),
              //     ),
              // ),
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
                // flightShuttleBuilder: (_,
                //     Animation<double> animation,
                //     HeroFlightDirection flightDirection,
                //     BuildContext fromHeroContext,
                //     BuildContext toHeroContext) {
                //     return AnimatedBuilder(
                //         animation: animation,
                //         child: Visibility(
                //           maintainSize: !isDownloadNewVersion, 
                //           maintainAnimation: !isDownloadNewVersion,
                //           maintainState: !isDownloadNewVersion,
                //           visible: !isDownloadNewVersion,
                //           child: InkWell(
                //             child: Image.asset(
                //               "assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain,
                //             ),
                //           ),
                //         ),
                //         builder: (_, _child) {
                //             return DefaultTextStyle.merge(
                //                 child: _child,
                //                 style: TextStyle.lerp(DefaultTextStyle
                //                     .of(fromHeroContext)
                //                     .style, DefaultTextStyle
                //                     .of(toHeroContext)
                //                     .style, flightDirection == HeroFlightDirection.pop ? 1 - animation.value :
                //                             animation.value),
                //             );
                //         },
                //     );
                // },
              ),
              SizedBox(height: 100),
              Center(
                child: Visibility(
                  maintainSize: !isDownloadNewVersion, 
                  maintainAnimation: !isDownloadNewVersion,
                  maintainState: !isDownloadNewVersion,
                  visible: isLoadingVersion,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(config.darkOpacityBlueColor),
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
              //       center: Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              //       footer: Padding(
              //         padding: EdgeInsets.only(top: 30),
              //         child: Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
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

    setState(() {
      isLoadingVersion = false;
    });

    if(checkVersion == "OK") {
      String apkVersion = "";
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      apkVersion = packageInfo.version;
      if(getCheckVersion != apkVersion) {
        Alert(
          context: context,
          title: "Info,",
          content: Text("Terdapat pembaruan versi aplikasi. Otomatis mengunduh pembaruan aplikasi setelah tekan OK"),
          cancel: false,
          type: "warning",
          defaultAction: () async {
            preparingNewVersion();
          }
        );
      } else {
        startTimer();
      }
    } else {
      Alert(
        context: context,
        title: "Maaf,",
        content: Text(checkVersion),
        cancel: false,
        type: "error",
        errorBtnTitle: "Coba Lagi",
        defaultAction: () {
          doCheckVersion();
        }
      );
    }
  }

  void preparingNewVersion() {
    setState(() {
      isLoadingVersion = false;
      isDownloadNewVersion = true;
    });
    // downloadNewVersion();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => isInternet());
    downloadApps();
    showDialog (
      context: context,
      barrierDismissible: false,
      builder: (context){
        return WillPopScope(
          onWillPop: () async {
            if(isRetryDownload) {
              timer.cancel();
            }
            return false;
          },
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
                      center: Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      footer: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
                            Visibility(
                              // maintainSize: true, 
                              // maintainAnimation: true,
                              // maintainState: true,
                              visible: isRetryDownload,
                              child: Container(
                                margin: EdgeInsets.only(top: 15),
                                width: MediaQuery.of(context).size.width,
                                child: Button(
                                  // loading: loginLoading,
                                  backgroundColor: config.darkOpacityBlueColor,
                                  child: TextView("Coba Lagi", 3, color: Colors.white),
                                  onTap: () {
                                    downloadApps();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Future<bool> checkAppsPermission() async {
    setState(() {
      isPermissionPermanentlyDenied = false;
    });
    var status = await Permission.storage.request();

    if(status != PermissionStatus.granted) {
      if(status == PermissionStatus.denied) {
        setState(() {
          isPermissionPermanentlyDenied = true;
        });
      } else {
        openAppSettings();
        return status == PermissionStatus.granted;
      }
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
    String isGetVersionSuccess = "";
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
        var urlData = Uri.parse(url);
        response = await client.get(urlData);

        if(response.body.toString() != "false") {
          isGetVersionSuccess = "OK";
          setState(() {
            getCheckVersion = response.body.toString();
          });
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

  void navigate() async {
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    if(sharedPreferences.containsKey("user_code")) {
      await sharedPreferences.setString("get_user_login", sharedPreferences.getString("user_code"));

      if(sharedPreferences.containsKey("nik")) {
        String nik = sharedPreferences.getString("nik");

        final nikData = encryptData(nik);

        String getAuth = await userAPI.checkAuth(context, parameter: 'json={"nik":"$nikData"}');

        if(getAuth.contains("server")) {
          Alert(
            context: context,
            title: "Maaf,",
            content: Text("Gagal terhubung dengan server"),
            cancel: false,
            type: "error",
            errorBtnTitle: "Coba Lagi",
            defaultAction: () {
              startTimer();
            }
          );
        } else {
          if(getAuth == "OK") {
            Navigator.pushReplacementNamed(
              context,
              'dashboard'
            );
          } else {
            Alert(
              context: context,
              title: "Maaf,",
              content: Text(getAuth),
              cancel: false,
              type: "error",
              disableBackButton: true,
              defaultAction: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("limit_dmd");
                await prefs.remove("request_limit");
                await prefs.remove("user_code_request");
                await prefs.remove("user_code");
                await prefs.remove("max_limit");
                await prefs.remove("fcmToken");
                await prefs.remove("get_user_login");
                await prefs.remove("nik");
                await prefs.remove("module_privilege");
                await FirebaseMessaging.instance.deleteToken();
                await prefs.clear();
                Navigator.pushReplacementNamed(
                  context,
                  "login",
                );
              }
            );
          }
        }  
      } else {
        Navigator.pushReplacementNamed(
          context,
          'dashboard'
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 3),
            pageBuilder: (_, __, ___) => Login()));
    }
  }

}