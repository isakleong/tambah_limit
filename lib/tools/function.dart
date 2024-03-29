import 'dart:async';
import 'package:encrypt/encrypt.dart' as EncryptionPackage;
import 'package:crypto/crypto.dart' as CryptoPackage;
import 'dart:convert' as ConvertPackage;
import 'package:http/http.dart' show Client, Request;
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'dart:io';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/button.dart';


printHelp(final print) {
  debugPrint("---------------------------------");
  debugPrint(print.toString());
  debugPrint("---------------------------------");
}

String decryptData(String data) {
  String strPwd = "snwO+67pWwpuypbyeazkkK6CNAfpsOivLuSwR/rd4uM=";
  String strIv = 'K8IgRZtkuepdGc1VnOp6eA==';
  var iv = CryptoPackage.sha256
    .convert(ConvertPackage.utf8.encode(strIv))
    .toString()
    .substring(0, 16); // Consider the first 16 bytes of all 64 bytes
  var key = CryptoPackage.sha256
    .convert(ConvertPackage.utf8.encode(strPwd))
    .toString()
    .substring(0, 32); // Consider the first 32 bytes of all 64 bytes
  EncryptionPackage.IV ivObj = EncryptionPackage.IV.fromUtf8(iv);
  EncryptionPackage.Key keyObj = EncryptionPackage.Key.fromUtf8(key);
  final encrypter = EncryptionPackage.Encrypter(
      EncryptionPackage.AES(keyObj, mode: EncryptionPackage.AESMode.cbc)); // Apply CBC mode
  String firstBase64Decoding = new String.fromCharCodes(
      ConvertPackage.base64.decode(data)); // First Base64 decoding
  final decrypted = encrypter.decrypt(
      EncryptionPackage.Encrypted.fromBase64(firstBase64Decoding),
      iv: ivObj); // Second Base64 decoding (during decryption)
  return decrypted;
}

  String encryptData(String data) {
    // String strPwd = "6P8yHVfeZ5JKaXQ6AyaBge";
    // String strIv = 'cHaa5y7pQF5uqA2N';
    String strPwd = "snwO+67pWwpuypbyeazkkK6CNAfpsOivLuSwR/rd4uM=";
      String strIv = 'K8IgRZtkuepdGc1VnOp6eA==';
    var iv = CryptoPackage.sha256
        .convert(ConvertPackage.utf8.encode(strIv))
        .toString()
        .substring(0, 16); // Consider the first 16 bytes of all 64 bytes
    var key = CryptoPackage.sha256
        .convert(ConvertPackage.utf8.encode(strPwd))
        .toString()
        .substring(0, 32); // Consider the first 32 bytes of all 64 bytes
    EncryptionPackage.IV ivObj = EncryptionPackage.IV.fromUtf8(iv);
    EncryptionPackage.Key keyObj = EncryptionPackage.Key.fromUtf8(key);

    final encrypter = EncryptionPackage.Encrypter(
        EncryptionPackage.AES(keyObj, mode: EncryptionPackage.AESMode.cbc));

    final encrypted = encrypter.encrypt(data.toString(), iv: ivObj);

    // return encrypted.base64; //try base16 too
    return ConvertPackage.base64.encode(ConvertPackage.utf8.encode(encrypted.base64)); // Base64 encode twice // ZFNkckFEL2R5cW5ycTJpbWs0Ky9xQT09
  }

Future<String> ConnectionTest(String url, BuildContext context) async {
  Client client = Client();
  String testResult = "ERROR";
  // final response = await client.head(url).timeout(
  //   Duration(seconds: 3),
  //     onTimeout: () {
  //       // time has run out, do what you wanted to do
  //       return Response("Timeout", 500);
  //     },
  // );

  final request = new Request('HEAD', Uri.parse(url))..followRedirects = false;
  try {
    final response = await client.send(request).timeout(
      Duration(seconds: 10),
        onTimeout: () {
          // time has run out, do what you wanted to do
          return null;
        },
    );

    if(response.statusCode == 200){
      testResult = "OK";
    } else {
      testResult = "ERROR";
    }  
  } catch (e) {
    testResult = "ERROR";
  }

  return testResult;

  // HttpClient httpClient = new HttpClient();
  // await httpClient.headUrl(Uri.parse(url))
  //   .then((HttpClientRequest request) {
  //     // Optionally set up headers...
  //     // Optionally write to the request object...
  //     // Then call close.
  //     request..followRedirects = false;
  //     return request.close();
  //   })
  //   .then((HttpClientResponse response) {
  //     // Process the response.

  //     printHelp("cek debug "+url.toString()+"-----"+response.statusCode.toString());
      
  //     if(response.statusCode == 200){
  //       testResult = "OK";
  //     } else {
  //       testResult = "ERROR";
  //     }

  //     return testResult;

  //   });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

String APIUrl(String url, {String parameter = "", bool print = false, BuildContext context}) {
  Configuration config;
  if (context != null) {
    config = Configuration.of(context);
  } else {
    config = config;
  }

  // String link = config.baseUrl + "/" + url + (parameter == "" ? "" : "?" + parameter);
  if(print)
    debugPrint("change url api "+url);
  return url;
}

void Alert({
    context, String title, Widget content, List<Widget> actions, VoidCallback defaultAction,
    bool cancel = true, String type = "warning", bool showIcon = true, bool disableBackButton = false,
    VoidCallback willPopAction, loading = false, double value, String errorBtnTitle = "Ok"
  }) {

    bool isShowing = false;

  Configuration config = new Configuration();
  
  if (loading == false) {
    if (actions == null) {
      actions = [];
    }

    if (defaultAction == null) {
      defaultAction = () {};
    }

    Widget icon;
    double iconWidth = 40, iconHeight = 40;
    if (type == "success") {
      icon = Container(
        child: FlareActor('assets/flare/success.flr', animation: "Play"),
        width: iconWidth,
        height: iconHeight,
      );
    } else if (type == "warning") {
      icon = Container(
        child: FlareActor('assets/flare/warning.flr', animation: "Play"),
        width: iconWidth,
        height: iconHeight,
      );
    } else if (type == "error") {
      icon = Container(
        child: FlareActor('assets/flare/error.flr', animation: "Play"),
        width: iconWidth,
        height: iconHeight,
      );
    }

    Widget titleWidget;
    // kalau titlenya gak null, judulnya ada
    if (title != null) {
      // kalau titlenya kosongan, brarti gk ada judulnya
      if (title == "") {
        titleWidget = null;
      } else {
        titleWidget = Row(
          children: <Widget>[
            showIcon ? Padding(padding: EdgeInsets.only(right: 20), child:icon) : Container(),
            Expanded(child: TextView(title, 2)),
          ],
        );
        
      }
    } else {
      // kalau titlenya null berarti auto generate tergantung typenya
      titleWidget = Row(
        children: <Widget>[
          showIcon ? Padding(padding: EdgeInsets.only(right: 20), child:icon) : Container(),
          Expanded(child: TextView("Warning", 2)),
        ],
      );
    }
    
    showDialog (
      context: context,
      barrierDismissible: false,
      builder: (context){
        return WillPopScope(
          onWillPop: disableBackButton ? () {
          }:willPopAction,
          child:AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.5)),
            ),
            title: titleWidget,
            content: content == null ? null:content,
            // kalau actions nya kosong akan otomatis mengeluarkan tombol ok untuk menutup alert
            actions: actions.length == 0 ?
            [
              defaultAction != null && cancel ?
              Button(
                key: Key("cancel"),
                child: TextView("Tidak", 2, size: 12, caps: false, color: Colors.white),
                fill: false,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ) : Container(),
              Button(
                key: Key("ok"),
                child: cancel ? TextView("Ya", 2, size: 12, caps: false, color: Colors.white) : type == "error" ? TextView(errorBtnTitle, 2, size: 12, caps: false, color: Colors.white) : TextView("Ok", 2, size: 12, caps: false, color: Colors.white),
                fill: true,
                onTap: () {
                  Navigator.of(context).pop();
                  defaultAction();
                },
              ),
              // kalau ada default action akan otomatis menampilkan tombol cancel, jadi akan muncul ok dan cancel
            ]
            :
            [
              // kalau ada pilihan tombol lain, akan otomatis mengeluarkan tulisan cancel
              // Button(
              //   key: Key("cancel"),
              //   child: TextView("Tidak", 2, size: 12, caps: false, color: Colors.white),
              //   fill: false,
              //   onTap: () {
              //     Navigator.of(context).pop();
              //   },
              // )
            ]..addAll(actions)..add(Padding(padding: EdgeInsets.only(right:5)))
          )
        );
      }
    );    
  } else if (loading) {
    showDialog (
      context: context,
      barrierDismissible: false,
      builder: (context){
        return WillPopScope(
          onWillPop: disableBackButton ? () {

          }:null,
          child: ListView(
            children: [
              SizedBox(height: 30),
              Container(
                child: Lottie.asset('assets/illustration/waiting.json', width: 220, height: 220, fit: BoxFit.contain)
              ),
            ],
          )

          
          
          // Lottie.asset('assets/illustration/loading.json', width: 80, height: 80, fit: BoxFit.contain, options: LottieOptions(enableMergePaths: false)),
          
          // Center(
          //   child: CircularProgressIndicator(
          //     backgroundColor: config.primaryColor,
          //     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //     value: value,
          //   ),
          // )
        );
      }
    );
  }

}



bool formValidation(context, List<String> validate) {
  bool isValid = true;
  
  validate.map((item) {
    List<String> tempItem = item.split("|");
    String name = tempItem[0];
    String type = tempItem[1];
    String text = tempItem[2];
    String rule = "";
    String message = "";

    String validationResult = "";

    if(type == "empty") {
      if(text.length == 0) {
        if(message != "0"){
          message = "harus diisi";
        } else {
          message = "";
        }

        validationResult = "$name $message";
        isValid = false;
      }
    }

    if (isValid == false) {
      Alert(
        context: context,
        content: TextView(validationResult, 7),
        cancel: false,
      );
    }
  }).toList();
}