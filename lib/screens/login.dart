import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class Login extends StatefulWidget {
  final Result result;

  const Login({Key key, this.result}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}


class LoginState extends State<Login> {
  String version = "";

  bool unlockPassword = true;
  bool loginLoading = false;

  bool usernameValid = false;
  bool passwordValid = false;

  final FocusNode usernameFocus = FocusNode();  
  final FocusNode passwordFocus = FocusNode();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  DateTime currentBackPressTime;

  String fcmToken = "";

  FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();

    // messaging = FirebaseMessaging.instance;
    // messaging.getToken().then((value){
    //     print("token: "+value);
    //     setState(() {
    //       fcmToken = value;
    //     });
    // });
    getFCMToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getFCMToken() {
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
        print("token: "+value);
        setState(() {
          fcmToken = value;
        });
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Configuration config = Configuration.of(context);
    
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;

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
            Center(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // AnimatedContainer(
                      //   duration: Duration(milliseconds: 250),
                      //   child: Container(
                      //     width: 220,
                      //     height: 220,
                      //     child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
                      //   ),
                      // ),
                      Hero(
                        // flightShuttleBuilder: (_,
                        //     Animation<double> animation,
                        //     HeroFlightDirection flightDirection,
                        //     BuildContext fromHeroContext,
                        //     BuildContext toHeroContext) {
                        //     return AnimatedBuilder(
                        //         animation: animation,
                        //         child: Container(
                        //           width: 220,
                        //           height: 220,
                        //           child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                        margin: EdgeInsets.symmetric(vertical: 20),
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
                            submitValidation();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        width: MediaQuery.of(context).size.width,
                        child: Button(
                          loading: loginLoading,
                          backgroundColor: config.darkOpacityBlueColor,
                          child: TextView("MASUK ", 3, color: Colors.white),
                          onTap: () {
                            submitValidation();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Theme(
                            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                            child: TextView("v"+version, 3, color: config.grayColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  void doLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      loginLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fcmToken = prefs.getString("fcmToken");

    final usernameData = encryptData(usernameController.text.toUpperCase());
    final passwordData = encryptData(passwordController.text);
    final tokenData = encryptData(fcmToken);

    String getLogin = await userAPI.login(context, parameter: 'json={"user_code":"$usernameData","user_pass":"$passwordData","token":"$tokenData"}');

    Navigator.of(context).pop();

    if(getLogin == "OK"){
      // final SharedPreferences sharedPreferences = await _sharedPreferences;
      // await sharedPreferences.setString("get_user_login", usernameController.text);
      Navigator.pushReplacementNamed(
          context,
          "dashboard"
      );
    } else {
      Alert(
        context: context,
        title: "Maaf,",
        content: Text(getLogin),
        cancel: false,
        type: "error"
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

    printHelp("cek token ya "+fcmToken);

    if(fcmToken == "") {
      Alert(
        context: context,
        title: "Maaf,",
        content: Text("Gagal terhubung dengan server"),
        cancel: false,
        type: "error",
        defaultAction: () {
          getFCMToken();
        }
      );
    } else {
      if(!usernameValid && !passwordValid){
        doLogin();
      }
    }
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