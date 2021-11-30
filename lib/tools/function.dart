import 'package:http/http.dart' show Client;
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
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

Future<String> ConnectionTest(String url, BuildContext context) async {
  Client client = Client();
  String testResult = "ERROR";

  final response = await client.get(url);

  if(response.statusCode == 200){
    testResult = "OK";
  }

  return testResult;

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
    VoidCallback willPopAction, loading = false
  }) {

  Configuration config = new Configuration();
  
  // kalau bukan mode loading
  if (loading == false) {
    if (actions == null) {
      actions = [];
    }

    // if (willPopAction == null) {
    //   willPopAction = () {};
    // }

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
    } else {
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
            TextView(title, 2),
          ],
        );
        
      }
    } else {
      // kalau titlenya null berarti auto generate tergantung typenya
      titleWidget = Row(
        children: <Widget>[
          showIcon ? Padding(padding: EdgeInsets.only(right: 20), child:icon) : Container(),
          TextView("Warning", 2),
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
                child: TextView("Tidak", 2, size: 10, caps: true,),
                fill: false,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ) : Container(),
              Button(
                key: Key("ok"),
                child: TextView("Ya", 2, size: 10, caps: true, color: Colors.white),
                backgroundColor: config.primaryColor,
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
              Button(
                key: Key("cancel"),
                child: TextView("Tidak", 2, size: 10, caps: true,),
                fill: false,
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
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
          child:AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.5)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.green,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    TextView("Loading", 5)
                  ],
                ),
              ]
            )
          )
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