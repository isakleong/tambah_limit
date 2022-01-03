import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_range_download/dio_range_download.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' show Client, Request;
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/resources/PushNotificationService.dart';
import 'package:tambah_limit/resources/customerAPI.dart';

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
  String getCheckVersion = "";
  bool isLoadingVersion = false;

  bool isDownloadNewVersion = false;
  bool isRetryDownload = false;
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

  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

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
  @override
  void initState() {
    initializeFlutterFire();

    final firebaseMessaging = PushNotificationService();
    firebaseMessaging.setNotifications();

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    _permissionReady = false;
    _prepare();
    
    super.initState();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (_tasks != null && _tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }


  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    String downloadPath = await getFilePath(config.apkName+".apk");

    final _documents = [
    {
      'name': 'TambahLimit.apk',
      'link': downloadPath
    }
  ];

    _tasks.addAll(_documents.map((document) =>
        _TaskInfo(name: document['name'], link: document['link'])));

    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await checkAppsPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath = await getFilePath(config.apkName+".apk");
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  // Future<String> _findLocalPath() async {
  //   var externalStorageDirPath;
  //   if (Platform.isAndroid) {
  //     try {
  //       externalStorageDirPath = await AndroidPathProvider.downloadsPath;
  //     } catch (e) {
  //       final directory = await getExternalStorageDirectory();
  //       externalStorageDirPath = directory?.path;
  //     }
  //   } else if (Platform.isIOS) {
  //     externalStorageDirPath =
  //         (await getApplicationDocumentsDirectory()).absolute.path;
  //   }
  //   return externalStorageDirPath;
  // }


  didChangeDependencies() async {
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);

    setState(() {
      user_code = sharedPreferences.getString("user_code");
    });

    final isPermissionStatusGranted = await checkAppsPermission();
    if(isPermissionStatusGranted) {
      doCheckVersion();
    } else {
      checkAppsPermission();
    }
    
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<void> downloadNewVersion() async {
    setState(() {
      isRetryDownload = false;
    });

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
      // isGetVersionSuccess = "Gagal terhubung dengan server";
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
        // isGetVersionSuccess = "Gagal terhubung dengan server";
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
          Dio dio = Dio();

          String downloadPath = await getFilePath(config.apkName+".apk");

          printHelp("download path "+downloadPath);
          printHelp("url download "+ url);

          // final response = await client.get(url);
          // // Response response = await client.get(url);
          // printHelp("content length "+response.headers.toString());

          var fileSize=0;
          var totalDownloaded = 0;
          var totalProgress = 0;

          final request = new Request('HEAD', Uri.parse(url))..followRedirects = false;
          final response = await client.send(request).timeout(
            Duration(seconds: 5),
              onTimeout: () {
                return null;
              },
          );
          printHelp("full header "+response.headers.toString());
          printHelp("content length "+response.headers['content-length'].toString());

          fileDownloaded = isInCompleteDownload(downloadPath);
          printHelp("tes fileDownloaded "+fileDownloaded.toString());
          if(fileDownloaded > 0) {
            printHelp("masuk if");
            totalDownloaded = fileDownloaded;
            fileSize = fileDownloaded;
          }
          fileSize += int.parse(response.headers['content-length']);



          // await rangeDownload(url, downloadPath);

          // _setState(() {
          //   if (progressText == '100') {
          //     isDownloadNewVersion = true;
          //   }

          //   isDownloadNewVersion = false;
          // });

          // Navigator.of(context).pop();
          // // var directory = await getApplicationDocumentsDirectory(); OpenFile.open(downloadPath);

          // setState(() {
          //   isLoadingVersion = false;
          //   isDownloadNewVersion = false;
          // });

          // printHelp("MASUK SELESAI");
          // // String downloadPath = await getFilePath(config.apkName+".apk");
          // OpenFile.open(downloadPath);

          // dio.download(url, downloadPath,
          //   onReceiveProgress: (rcv, total) {
          //     print(
          //         'received: ${rcv.toStringAsFixed(0)} out of total WOI: ${total.toStringAsFixed(0)}');
          //     _setState(() {
          //       // totalDownloaded+=rcv;
          //       progressValue = (rcv / total * 100)/100;
          //       progressText = ((rcv / total) * 100).toStringAsFixed(0);
          //     });

          //     if (progressText == '100') {
          //       _setState(() {
          //         isDownloadNewVersion = true;
          //       });
          //     } else if (double.parse(progressText) < 100) {}
          //   },
          //   deleteOnError: false,
          // ).then((_) async {
          //   _setState(() {
          //     if (progressText == '100') {
          //       isDownloadNewVersion = true;
          //     }

          //     isDownloadNewVersion = false;
          //   });

          //   Navigator.of(context).pop();
          //   // var directory = await getApplicationDocumentsDirectory(); OpenFile.open(downloadPath);

          //   setState(() {
          //     isLoadingVersion = false;
          //     isDownloadNewVersion = false;
          //   });

          //   printHelp("MASUK SELESAI");
          //   String downloadPath = await getFilePath(config.apkName+".apk");
          //   OpenFile.open(downloadPath);

          // });

          // dio.interceptors.add(
          //   RetryOnConnectionChangeInterceptor(
          //     requestRetrier: DioConnectivityRequestRetrier(
          //       dio: dio,
          //       connectivity: Connectivity(),
          //     ),
          //   ),
          // );

          // try {
          //   await downloadWithChunks(url, downloadPath, total: totalDownloaded, onReceiveProgress: (received, total) {
          //     if (total != -1) {
          //       print('${(received / total * 100).floor()}%');
          //       _setState(() {
          //         // totalDownloaded+=rcv;
          //         // progressValue = (received / total * 100)/100;
          //         // progressText = ((received / total) * 100).toStringAsFixed(0);

          //         progressValue = (received / fileSize * 100)/100;
          //         progressText = ((received / fileSize) * 100).toStringAsFixed(0);
          //       });

          //       if (progressText == '100') {
          //         _setState(() {
          //           isDownloadNewVersion = true;
          //         });
          //       } else if (double.parse(progressText) < 100) {}


          //     }
          //   });

          //   _setState(() {
          //     if (progressText == '100') {
          //       isDownloadNewVersion = true;
          //     }

          //     isDownloadNewVersion = false;
          //   });

          //   Navigator.of(context).pop();
          //   // var directory = await getApplicationDocumentsDirectory(); OpenFile.open(downloadPath);

          //   setState(() {
          //     isLoadingVersion = false;
          //     isDownloadNewVersion = false;
          //   });

          //   printHelp("MASUK SELESAI");
          //   // String downloadPath = await getFilePath(config.apkName+".apk");
          //   OpenFile.open(downloadPath);

          // } catch (e) {
          //   printHelp("masuk resume");
          //   print(e);
          //   setState(() {
          //     isRetryDownload = true;
          //   });
          // }    

        } catch (e) {

        }

      }

    } else {
      //gagal terhubung
    }
  }

  DateTime startTime;
  rangeDownload(String url, String downloadPath) async {
    print("start");
    bool isStarted = false;
    CancelToken cancelToken = CancelToken();

    try {
      Response res = await RangeDownload.downloadWithChunks(url, downloadPath,
        //isRangeDownload: false,//Support normal download
        // maxChunk: 6,
        // dio: Dio(),//Optional parameters "dio".Convenient to customize request settings.
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (!isStarted) {
            startTime = DateTime.now();
            isStarted = true;
          }
          if (total != -1) {
            print("${(received / total * 100).floor()}%");
            if (received / total * 100.floor() > 50) {
              cancelToken.cancel();
            }

            _setState(() {
              progressValue = (received / total * 100)/100;
              progressText = ((received / total) * 100).toStringAsFixed(0);
            });

            if (progressText == '100') {
              _setState(() {
                isDownloadNewVersion = true;
              });
            } else if (double.parse(progressText) < 100) {}

          }
          if ((received / total * 100).floor() >= 100) {
            var duration = (DateTime.now().millisecondsSinceEpoch -
                    startTime.millisecondsSinceEpoch) /
                1000;
            print(duration.toString() + "s");
            print(
                (duration ~/ 60).toString() + "m" + (duration % 60).toString() + "s");
          }
        });
        print(res.statusCode);
        print(res.statusMessage);
        print(res.data);
    } catch(e) {
      cancelToken.cancel();
      printHelp("tes on catch "+ e.toString());
    }
  }

  Future downloadWithChunks(url, savePath, {ProgressCallback onReceiveProgress, var total}) async {
    const firstChunkSize = 102;
    const maxChunk = 3;

    // var total = 0;
    var dio = Dio();
    var progress = <int>[];

    void Function(int, int) createCallback(no) {
      return (int received, int _) {
        progress[no] = received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no) async {
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + 'temp$no',
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {'range': 'bytes=$start-$end'},
          // headers: {'range': 'bytes=$start-'},
        ),
      );
    }

    Future mergeTempFiles(chunk) async {
      var f = File(savePath + 'temp0');
      var ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (var i = 1; i < chunk; ++i) {
        var _f = File(savePath + 'temp$i');
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    var response = await downloadChunk(url, 0, firstChunkSize, 0);
    if (response.statusCode == 206) {
      total = int.parse(
          response.headers.value(HttpHeaders.contentRangeHeader).split('/').last);
      var reserved =
          total - int.parse(response.headers.value(Headers.contentLengthHeader));
      var chunk = (reserved / firstChunkSize).ceil() + 1;
      if (chunk > 1) {
        var chunkSize = firstChunkSize;
        if (chunk > maxChunk + 1) {
          chunk = maxChunk + 1;
          chunkSize = (reserved / maxChunk).ceil();
        }
        var futures = <Future>[];
        for (var i = 0; i < maxChunk; ++i) {
          var start = firstChunkSize + i * chunkSize;
          futures.add(downloadChunk(url, start, start + chunkSize, i + 1));
        }
        await Future.wait(futures);
      }
      await mergeTempFiles(chunk);
    }
  }

  int isInCompleteDownload(String downloadPath) {
    if(FileSystemEntity.typeSync(downloadPath) != FileSystemEntityType.notFound){
      var file = File(downloadPath);
      printHelp("masuk exist "+file.lengthSync().toString());
      return file.lengthSync();
    }
    printHelp("masuk not exist");
    return 0;
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
                    valueColor: AlwaysStoppedAnimation<Color>(config.darkOpacityBlueColor),
                  ),
                ),
              ),
              Center(
                child: Visibility(
                  maintainSize: true, 
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isDownloadNewVersion,
                  child: CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 13.0,
                    animation: true,
                    percent: progressValue,
                    center: Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    footer: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: config.primaryColor,
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

    setState(() {
      isLoadingVersion = false;
    });

    if(checkVersion == "OK") {
      if(getCheckVersion != config.apkVersion) {
        printHelp("getcheckversion "+getCheckVersion);
        printHelp("apkVersion "+config.apkVersion);
        Alert(
          context: context,
          title: "Info,",
          content: Text("Terdapat pembaruan versi aplikasi. Otomatis mengunduh pembaruan aplikasi setelah tekan OK"),
          cancel: false,
          type: "warning",
          defaultAction: () {
            preparingNewVersion();
            // String downloadPath = await getFilePath(config.apkName+".apk");
            // OpenFile.open(downloadPath);

            // Navigator.of(context).pop();
            

            // setState(() {
            //   isLoadingVersion = false;
            //   isDownloadNewVersion = true;
            // });
            // downloadNewVersion();
            // showDialog (
            //   context: context,
            //   barrierDismissible: false,
            //   builder: (context){
            //     return WillPopScope(
            //       onWillPop: null,
            //       child: AlertDialog(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(7.5)),
            //         ),
            //         content: StatefulBuilder(
            //           builder: (BuildContext context, StateSetter setState) {
            //           _setState = setState;
            //           return Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Center(
            //                 child: CircularPercentIndicator(
            //                   radius: 120.0,
            //                   lineWidth: 13.0,
            //                   animation: false,
            //                   percent: progressValue,
            //                   center: new Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            //                   footer: Padding(
            //                     padding: EdgeInsets.only(top: 10),
            //                     child: new Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
            //                   ),
            //                   circularStrokeCap: CircularStrokeCap.round,
            //                   progressColor: config.primaryColor,
            //                 ),
            //               ),
            //             ],
            //           );
            //         }),
            //       )
            //     );
            //   }
            // );

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
                      center: Text("${progressText}%", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      footer: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Text("Mengunduh pembaruan aplikasi", style: new TextStyle(fontWeight: FontWeight.bold)),
                            Visibility(
                              maintainSize: true, 
                              maintainAnimation: true,
                              maintainState: true,
                              visible: !isRetryDownload,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                width: MediaQuery.of(context).size.width,
                                child: Button(
                                  // loading: loginLoading,
                                  backgroundColor: config.darkOpacityBlueColor,
                                  child: TextView("Coba Lagi", 3, color: Colors.white),
                                  onTap: () {
                                    downloadNewVersion();
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
        response = await client.get(url);

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
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      await sharedPreferences.setString("get_user_login", sharedPreferences.getString("user_code"));
      Navigator.pushReplacementNamed(
        context,
        'dashboard'
      );
    } else {
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 4),
            pageBuilder: (_, __, ___) => Login()));
    }
  }

}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}