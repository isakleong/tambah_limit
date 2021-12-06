import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

class Login extends StatefulWidget {
  final Result result;

  const Login({Key key, this.result}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}


class LoginState extends State<Login> {
  static const platform = const MethodChannel("connectionTest");

  bool unlockPassword = true;
  bool loginLoading = false;

  bool usernameValid = false;
  bool passwordValid = false;

  final FocusNode usernameFocus = FocusNode();  
  final FocusNode passwordFocus = FocusNode();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  DateTime currentBackPressTime;

  @override
  void initState() {
    super.initState();

    // //get fcm token
    // String token = await FirebaseMessaging.instance.getToken();

    // //fcm handler
    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //     print("message recieved");
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
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('Message clicked!');
    // });
  }

  // Future<void> _messageHandler(RemoteMessage message) async {
  //   print('background message ${message.notification.body}');
  // }
  
  @override
  Widget build(BuildContext context) {
    Configuration config = Configuration.of(context);

    return Scaffold(
      body: WillPopScope(
        onWillPop: willPopScope,
        child: Stack(
          children:<Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset("assets/illustration/bg.png", alignment: Alignment.center, fit: BoxFit.fill),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: 'logo',
                          child: Container(
                            width: 220,
                            height: 220,
                            child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
                          ),
                        ),
                        Container(
                          child: EditText(
                            key: Key("Username"),
                            controller: usernameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            focusNode: usernameFocus,
                            validate: usernameValid,
                            hintText: "Username",
                            textCapitalization: TextCapitalization.characters,
                            onSubmitted: (value) {
                              _fieldFocusChange(context, usernameFocus, passwordFocus);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: EditText(
                            useIcon: true,
                            key: Key("Password"),
                            controller: passwordController,
                            obscureText: unlockPassword,
                            focusNode: passwordFocus,
                            validate: passwordValid,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.go,
                            hintText: "Password",
                            suffixIcon:
                            InkWell(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(
                                  Icons.remove_red_eye,
                                  color:  unlockPassword ? config.lightGrayColor : config.grayColor,
                                  size: 18,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  unlockPassword = !unlockPassword;
                                });
                              },
                            ),
                            onSubmitted: (value) {
                              passwordFocus.unfocus();
                              //submitValidation(2);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          width: MediaQuery.of(context).size.width,
                          child: Button(
                            loading: loginLoading,
                            backgroundColor: config.darkOpacityBlueColor,
                            child: TextView("MASUK", 3, color: Colors.white),
                            onTap: () {
                              submitValidation();
                              // Printy();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      )
    );
  }


  void doLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      loginLoading = true;
    });

    // Alert(context: context, loading: true, disableBackButton: true);

    // Result result = await userAPI.login(context, parameter: 'json={"user_code":"${usernameController.text}","user_pass":"${passwordController.text}","token":"tokencoba"}');
    // User user = await userAPI.login(context, parameter: 'json={"user_code":"${usernameController.text}","user_pass":"${passwordController.text}","token":"tokencoba"}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fcmToken = prefs.getString("fcmToken");

    String getLogin = await userAPI.login(context, parameter: 'json={"user_code":"${usernameController.text}","user_pass":"${passwordController.text}","token":"${fcmToken}"}');

    // Navigator.of(context).pop();

    if(getLogin == "OK"){
      Navigator.popAndPushNamed(
          context,
          "dashboard"
      );
    } else {
      Alert(
        context: context,
        title: "Alert",
        content: Text(getLogin),
        cancel: false,
        type: "warning"
      );
    }

    setState(() {
      loginLoading = false;
    });

  }

  void submitValidation() {

    setState(() {
      usernameController.text.isEmpty ? usernameValid = true : usernameValid = false;
      passwordController.text.isEmpty ? passwordValid = true : passwordValid = false;
    });

    if(!usernameValid && !passwordValid){
      doLogin();
    }

    // bool isFormValid = true;
    // List<String> validations = [
    //   "Username|empty|${usernameController.text}",
    //   "Password|empty|${passwordController.text}",
    // ];

    // validations.map((item) {
    //   if (isFormValid) {
    //     bool status = formValidation(context, [item]);
    //     if (status == false) {
    //       isFormValid = false;
    //     }
    //   }
    // }).toList();

    // if (isFormValid) {
    //   //login(status);
    //   //coba async login
    // }

  }

  void Printy() async {
    String value;
    try{
      value = await platform.invokeMethod("printy");
      print(value);
    } catch (e){
      print(e);
    }
    print(value);
  }


  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus); 
  }


  Future<bool> willPopScope() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Tekan sekali lagi untuk keluar dari aplikasi", textAlign: TextAlign.center),
      ));
      return Future.value(false);
    }
    return Future.value(true);
  }

}