import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
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

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

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

  String fcmToken = "";

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
        print("token: "+value);
        setState(() {
          fcmToken = value;
        });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("fcmToken", fcmToken);
  }
  
  @override
  Widget build(BuildContext context) {
    Configuration config = Configuration.of(context);

    return Scaffold(
      body: WillPopScope(
        onWillPop: willPopScope,
        child: _connectionStatus != ConnectivityResult.none ?
        Stack(
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
                            child: TextView("v"+config.apkVersion, 3, color: config.grayColor),
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
        :
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget>[
            Center(
              child: Container(
                child: FlareActor('assets/flare/networking.flr', animation: "no_netwrok"),
                width: MediaQuery.of(context).size.width*0.8,
                height: MediaQuery.of(context).size.width*0.8,
              ),
            ),
            Container(
              child: TextView('Oops, koneksi internet tidak tersedia\nPastikan Anda terhubung dengan internet', 3, color: config.grayColor, align: TextAlign.center),
            ),
          ]
        ),
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

    String getLogin = await userAPI.login(context, parameter: 'json={"user_code":"${usernameController.text}","user_pass":"${passwordController.text}","token":"${fcmToken}"}');

    Navigator.of(context).pop();

    if(getLogin == "OK"){
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      await sharedPreferences.setString("get_user_login", usernameController.text);
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

    if(!usernameValid && !passwordValid){
      doLogin();
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