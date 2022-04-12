import 'dart:async';
import 'dart:convert';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/screens/historyLimitRequest.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/bottomBarLayout.dart';
import 'package:tambah_limit/widgets/bottombarWithIcon.dart';

import 'package:tambah_limit/widgets/button.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

enum CustomerBlockedType { NotBlocked, BlockedShip, BlockedInvoice, BlockedAll }  

class Dashboard extends StatefulWidget {
  final int indexMenu;

  Dashboard({Key key, this.indexMenu}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

// class DashboardState extends State<Dashboard> with TickerProviderStateMixin {
class DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  PersistentTabController tabController;
  List<BottomNavigationBarItem> bottomNavigationBarList = [];

  String user_login = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "snackBar");

  DateTime currentBackPressTime;

  final _ChangeBlockedStatusFormKey = GlobalKey<FormState>();

  CustomerBlockedType customerBlockedType = CustomerBlockedType.NotBlocked;

  Result resultLimit, resultBlocked;
  
  List<Color> backgroundActiveColor = [ config.grayColor, config.grayColor, config.grayColor ];
  String dashboardTitle = "Tambah Limit";
  int currentIndex = 0;

  String blockedTypeSelected = "";
  int selectedRadio = -1;

  bool customerIdValid = false;
  bool customerIdBlockedValid = false;
  bool searchLoading = false;
  bool searchBlockedLoading = false;
  bool updateLoading = false;

  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();

  final customerIdBlockedController = TextEditingController();
  final FocusNode customerIdBlockedFocus = FocusNode();

  final btnTitle = [ "Ubah Status Blocked", "Ubah Password", "Riwayat Permintaan Limit" ];

  bool unlockOldPassword = true;
  bool unlockNewPassword = true;
  bool unlockConfirmPassword = true;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FocusNode oldPasswordFocus = FocusNode();
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  bool oldPasswordValid = false;
  bool newPasswordValid = false;
  bool confirmPasswordValid = false;
  String oldPasswordErrorMessage = "", newPasswordErrorMessage = "", confirmPasswordErrorMessage = "";

  bool changePasswordLoading = false;

  bool isLimitCustomerSelected = true;
  bool isLimitCorporateSelected = false;
  
  Color borderCardColor_1 = config.darkOpacityBlueColor;
  Color backgroundCardColor_1 = config.lightBlueColor;
  Color textCardColor_1 = config.grayColor;
  Color borderCardColor_2 = config.grayNonActiveColor;
  Color backgroundCardColor_2 = config.lighterGrayColor;
  Color textCardColor_2 = config.grayNonActiveColor;

  bool isHomePage = true;
  int currentMenuIndex = 0;

  bool checkModulePrivilegeLoading = true;

  bool isAlertShowing = false;

  void _selectedTab(int index) {
    setState(() {
      if(index == 0){
        dashboardTitle = "Tambah Limit";

        customerIdBlockedController.clear();
        oldPasswordController.clear();
        confirmPasswordController.clear();
        newPasswordController.clear();
        resultBlocked = null;
      } else if(index == 1) {
        dashboardTitle = "Riwayat Permintaan Limit";

        customerIdController.clear();
        customerIdBlockedController.clear();
        oldPasswordController.clear();
        confirmPasswordController.clear();
        newPasswordController.clear();
        resultBlocked = null;
      } else if(index == 2) {
        dashboardTitle = "Ubah Status Blocked";

        customerIdController.clear();
        oldPasswordController.clear();
        confirmPasswordController.clear();
        newPasswordController.clear();
      } else if(index == 3) {
        dashboardTitle = "Ubah Password";

        customerIdController.clear();
        customerIdBlockedController.clear();
        resultBlocked = null;
      }
      currentIndex = index;
    });
  }

  void getBackgroundNotification() async {
    RemoteMessage message =
        await FirebaseMessaging.instance.getInitialMessage();

      if (message != null) {
        Result result_;
      
        if (message.data['body'].toString().toLowerCase().contains("terdapat request tambah limit")) {
          if(config.isAppLive == false){
            while(config.isScreenAtDashboard == false){
              await Future.delayed(Duration(milliseconds: 500));
            }
          }

          if(message.data['customer_code'].toString().length > 11) {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/4/0",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/1/0",
              arguments: result_,
            );
          }

        } else if(message.data['body'].toString().toLowerCase().contains("diterima")) {
          if(config.isAppLive == false){
            while(config.isScreenAtDashboard == false){
              await Future.delayed(Duration(milliseconds: 500));
            }
          }

          if(message.data['customer_code'].toString().length > 11) {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/5/0",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/2/0",
              arguments: result_,
            );

          }

        } else if(message.data['body'].toString().toLowerCase().contains("ditolak")) {
          if(config.isAppLive == false){
            while(config.isScreenAtDashboard == false){
              await Future.delayed(Duration(milliseconds: 500));
            }
          }

          if(message.data['customer_code'].toString().length > 11) {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/6/0",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            final userCodeData = encryptData(message.data['user_code']);
            final kodeCustomerData = encryptData(message.data['customer_code']);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/3/0",
              arguments: result_,
            );
          }
        }
      }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    tabController = PersistentTabController(initialIndex: 0);

    if(widget.indexMenu != null){
      setState(() {
        currentIndex = widget.indexMenu;
      });
    }

    //handling onbackground notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      printHelp("MASUK ONRESUME NOTIFICATION");
      Result result_;

      if (message.data['body'].toString().toLowerCase().contains("terdapat request tambah limit")) {
      
      if(config.isAppLive == false){
        while(config.isScreenAtDashboard == false){
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      if(message.data['customer_code'].toString().length > 11) {
        Alert(context: context, loading: true, disableBackButton: true);

        final userCodeData = encryptData(user_login);
        final kodeCustomerData = encryptData(message.data['customer_code']);

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
        
        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();
        
        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/4/0",
          arguments: result_,
        );
      } else {
        Alert(context: context, loading: true, disableBackButton: true);

        final userCodeData = encryptData(user_login);
        final kodeCustomerData = encryptData(message.data['customer_code']);

        result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();

        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/1/0",
          arguments: result_,
        );
      }
    } else if(message.data['body'].toString().toLowerCase().contains("diterima")) {
      if(config.isAppLive == false){
        while(config.isScreenAtDashboard == false){
          await Future.delayed(Duration(milliseconds: 5000));
        }
      }

      if(message.data['customer_code'].toString().length > 11) {
        Alert(context: context, loading: true, disableBackButton: true);

        final userCodeData = encryptData(user_login);
        final kodeCustomerData = encryptData(message.data['customer_code']);

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
        
        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();
        
        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/5/0",
          arguments: result_,
        );
      } else {
        Alert(context: context, loading: true, disableBackButton: true);

        final userCodeData = encryptData(user_login);
        final kodeCustomerData = encryptData(message.data['customer_code']);

        result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();

        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/2/0",
          arguments: result_,
        );
      }

      } else if(message.data['body'].toString().toLowerCase().contains("ditolak")) {
        if(config.isAppLive == false){
          while(config.isScreenAtDashboard == false){
            await Future.delayed(Duration(milliseconds: 500));
          }
        }

        if(message.data['customer_code'].toString().length > 11) {
          Alert(context: context, loading: true, disableBackButton: true);

          final userCodeData = encryptData(user_login);
          final kodeCustomerData = encryptData(message.data['customer_code']);

          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
          
          final SharedPreferences sharedPreferences = await _sharedPreferences;
          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
          await sharedPreferences.setString("user_code_request", message.data['user_code']);

          Navigator.of(context).pop();
          
          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${message.data['id']}/6/0",
            arguments: result_,
          );
        } else {
          Alert(context: context, loading: true, disableBackButton: true);

          final userCodeData = encryptData(user_login);
          final kodeCustomerData = encryptData(message.data['customer_code']);

          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

          final SharedPreferences sharedPreferences = await _sharedPreferences;
          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
          await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
          await sharedPreferences.setString("user_code_request", message.data['user_code']);

          Navigator.of(context).pop();

          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${message.data['id']}/3/0",
            arguments: result_,
          );
        }
      }
      
      
    });

    //handling in-app notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("message recieved yaaa (in-app)");
      print(message.notification.body);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop:(){},
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.5)),
              ),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20), 
                    child:Container(
                      child: FlareActor('assets/flare/warning.flr', animation: "Play"),
                      width: 40,
                      height: 40,
                    )
                  ),
                  Expanded(child: TextView("Notifikasi,", 2)),
                ],
              ),
              content: Text(message.notification.body),
              actions: [
                TextButton(
                  child: Button(
                    child: TextView("OK", 2, size: 12, caps: false, color: Colors.white),
                    fill: false,
                    onTap: () async {

                      Result result_;

                      if (message.data['body'].toString().toLowerCase().contains("terdapat request tambah limit")) {
                        printHelp("masuk notif request");

                        if(message.data['customer_code'].toString().length > 11) {
                          Alert(context: context, loading: true, disableBackButton: true);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
                          
                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          
                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/4",
                            arguments: result_,
                          );

                        } else {
                          //ontesting
                          Alert(context: context, loading: true, disableBackButton: true);

                          printHelp("message cust code "+message.data['customer_code']);
                          printHelp("message user code "+message.data['user_code']);
                          printHelp("message limit "+message.data['limit']);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/1",
                            arguments: result_,
                          );
                        }

                      } else if(message.data['body'].toString().toLowerCase().contains("diterima")) {
                        printHelp("masuk notif diterima");

                        if(message.data['customer_code'].toString().length > 11) {
                          Alert(context: context, loading: true, disableBackButton: true);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
                          
                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          
                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/5",
                            arguments: result_,
                          );

                        } else {
                          Alert(context: context, loading: true, disableBackButton: true);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/2",
                            arguments: result_,
                          );
                        }


                      } else if(message.data['body'].toString().toLowerCase().contains("ditolak")) {
                        printHelp("masuk notif ditolak");

                        if(message.data['customer_code'].toString().length > 11) {
                          Alert(context: context, loading: true, disableBackButton: true);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
                          
                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          
                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/6",
                            arguments: result_,
                          );

                        } else {
                          Alert(context: context, loading: true, disableBackButton: true);

                          final userCodeData = encryptData(user_login);
                          final kodeCustomerData = encryptData(message.data['customer_code']);

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
                          await sharedPreferences.setInt("request_limit_dmd", int.parse(message.data['limit_dmd']));
                          await sharedPreferences.setString("user_code_request", message.data['user_code']);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          Navigator.pushNamed(
                            context,
                            "historyLimitRequestDetail/${message.data['id']}/3",
                            arguments: result_,
                          );
                        }

                      }

                    },
                  ),
                  onPressed: () {},
                )
              ],
            ),
          );
        });
    });

    getBackgroundNotification();

    // if(user_login.toLowerCase().contains("kc")) {
    //   setState(() {
    //     bottomNavigationBarList = [
    //       BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_dollar), label: "Limit"),
    //       BottomNavigationBarItem(icon: Icon(Icons.change_circle), label: "Riwayat"),
    //       BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Password"),
    //     ];  
    //   });
    // } else {
    //   setState(() {
    //     bottomNavigationBarList = [
    //       BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_dollar), label: "Limit"),
    //       BottomNavigationBarItem(icon: Icon(Icons.change_circle), label: "Riwayat"),
    //       BottomNavigationBarItem(icon: Icon(Icons.not_interested), label: "Blocked"),
    //       BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Password"),
    //     ];  
    //   });
    // }
    
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        printHelp("resumed");
        
        // final SharedPreferences sharedPreferences = await _sharedPreferences;
        // if(sharedPreferences.containsKey("nik")) {
        //   Alert(context: context, loading: true, disableBackButton: true);

        //   String nik = sharedPreferences.getString("nik");

        //   String getAuth = await userAPI.checkAuth(context, parameter: 'json={"nik":"$nik"}');

        //   Navigator.of(context).pop();

        //   if(getAuth.contains("server")) {
        //     Alert(
        //       context: context,
        //       title: "Maaf,",
        //       content: Text(getAuth),
        //       cancel: false,
        //       type: "error",
        //       errorBtnTitle: "Coba Lagi",
        //       disableBackButton: true,
        //       defaultAction: () {
        //         retryAuth();
        //       }
        //     );
        //   } else {
        //     if(getAuth == "OK") {
        //       //welcome back
        //       printHelp("HMMMM");
        //     } else {
        //       Alert(
        //         context: context,
        //         title: "Maaf,",
        //         content: Text(getAuth),
        //         cancel: false,
        //         type: "error",
        //         // disableBackButton: true,
        //         defaultAction: () async {
        //           SharedPreferences prefs = await SharedPreferences.getInstance();
        //           await prefs.remove("limit_dmd");
        //           await prefs.remove("request_limit");
        //           await prefs.remove("user_code_request");
        //           await prefs.remove("user_code");
        //           await prefs.remove("max_limit");
        //           await prefs.remove("fcmToken");
        //           await prefs.remove("get_user_login");
        //           await prefs.remove("nik");
        //           await prefs.remove("module_privilege");
        //           await FirebaseMessaging.instance.deleteToken();
        //           await prefs.clear();
        //           Navigator.pushReplacementNamed(
        //             context,
        //             "login",
        //           );
        //         }
        //       );
        //     }
        //   } 
        // }

        retryAuth();

        break;
      case AppLifecycleState.inactive:
        printHelp("inactive");
        break;
      case AppLifecycleState.paused:
        printHelp("paused");
        break;
      case AppLifecycleState.detached:
        printHelp("detached");
        break;
    }
  }

  retryAuth() async {
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    if(sharedPreferences.containsKey("nik")) {
      Alert(context: context, loading: true, disableBackButton: true);

      String nik = sharedPreferences.getString("nik");

      final nikData = encryptData(nik);

      String getAuth = await userAPI.checkAuth(context, parameter: 'json={"nik":"$nikData"}');

      Navigator.of(context, rootNavigator: true).pop();

      if(getAuth.contains("server")) {
        showAlert(
          context: context,
          title: "Maaf,",
          content: Text(getAuth),
          cancel: false,
          type: "error",
          errorBtnTitle: "Coba Lagi",
          disableBackButton: true,
          defaultAction: () {
            retryAuth();
          }
        );
      } else {
        if(getAuth == "OK") {
          //welcome back
          if(isAlertShowing) {
            Navigator.of(context, rootNavigator: true).pop();
            isAlertShowing = false;
          }
        } else {
          showAlert(
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
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    config.isScreenAtDashboard = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_login = prefs.getString("get_user_login");  
    });

    if(checkModulePrivilegeLoading) {
      checkModulePrivilege();
    }
  }

  checkModulePrivilege() async {
    setState(() {
      checkModulePrivilegeLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> privilegeList = prefs.getStringList("module_privilege") ?? [];

    for(int i=0; i<privilegeList.length; i++) {
      if(privilegeList[i] == "ADDLIMIT") {
        bottomNavigationBarList.add(BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_dollar), label: "Limit"));
      }

      if(privilegeList[i] == "LIMITHISTORY") {
        bottomNavigationBarList.add(BottomNavigationBarItem(icon: Icon(Icons.change_circle), label: "Riwayat"));
      }

      if(privilegeList[i] == "CHANGESTATUSBLOCKED") {
        bottomNavigationBarList.add(BottomNavigationBarItem(icon: Icon(Icons.not_interested), label: "Blocked"));
      }

      if(privilegeList[i] == "EDITPASSWORD") {
        bottomNavigationBarList.add(BottomNavigationBarItem(icon: Icon(CupertinoIcons.lock), label: "Password"));
      }
    }

    setState(() {
      checkModulePrivilegeLoading = false;
      bottomNavigationBarList = bottomNavigationBarList;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> blockInfoDetailWidgetList = showBlockInfoDetail(config);

    List<Widget> menuList = [];

    for (int i = 0; i < bottomNavigationBarList.length; i++) {
      if(bottomNavigationBarList[i].label == "Limit") {
       menuList.add(
         Center(
           child: SingleChildScrollView(
             reverse: true,
             child: Column(
               children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    // customerIdController.clear();
                    
                                    isLimitCustomerSelected = true;
                                    isLimitCorporateSelected = false;
                    
                                    borderCardColor_1 = config.darkOpacityBlueColor;
                                    backgroundCardColor_1 = config.lightBlueColor;
                                    textCardColor_1 = config.grayColor;
                                    borderCardColor_2 = config.grayNonActiveColor;
                                    backgroundCardColor_2 = config.lighterGrayColor;
                                    textCardColor_2 = config.grayNonActiveColor;
                                  });
                                },
                                child: ClipPath(
                                  clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8))),
                                  child: Container(
                                    height: 100,
                                      decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(color: borderCardColor_1, width: 10)),
                                        color: backgroundCardColor_1,
                                      ),
                                      padding: EdgeInsets.all(20.0),
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                      child: TextView("Limit Customer", 3, color: textCardColor_1),
                                      )
                                    ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    // customerIdController.clear();
                    
                                    isLimitCustomerSelected = false;
                                    isLimitCorporateSelected = true;
                    
                                    borderCardColor_2 = config.darkOpacityBlueColor;
                                    backgroundCardColor_2 = config.lightBlueColor;
                                    textCardColor_2 = config.grayColor;
                                    borderCardColor_1 = config.grayNonActiveColor;
                                    backgroundCardColor_1 = config.lighterGrayColor;
                                    textCardColor_1 = config.grayNonActiveColor;
                                  });
                                },
                                child: ClipPath(
                                  clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8))),
                                  child: Container(
                                    height: 100,
                                      decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(color: borderCardColor_2, width: 10)),
                                        color: backgroundCardColor_2,
                                      ),
                                      padding: EdgeInsets.all(20.0),
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: TextView("Limit Corporate", 3, color: textCardColor_2),
                                      )
                                    ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: EditText(
                      useIcon: true,
                      key: Key("CustomerId"),
                      controller: customerIdController,
                      focusNode: customerIdFocus,
                      validate: customerIdValid,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      textCapitalization: TextCapitalization.characters,
                      hintText: isLimitCustomerSelected ? "Kode Pelanggan" : "Kode Corporate",
                      onSubmitted: (value) {
                        customerIdFocus.unfocus();
                        if(isLimitCustomerSelected) {
                          getLimit();
                        } else {
                          getLimitCorporate();
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          resultLimit = null;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Button(
                      loading: searchLoading,
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView("LANJUTKAN", 3, color: Colors.white),
                      onTap: () {
                        if(isLimitCustomerSelected) {
                          getLimit();
                        } else {
                          getLimitCorporate();
                        }
                      },
                    ),
                  ),
                ],
              ),
           ),
         )
       );
      }

      if(bottomNavigationBarList[i].label == "Riwayat") {
        menuList.add(HistoryLimitRequest());
      }

      if(bottomNavigationBarList[i].label == "Blocked") {
        menuList.add(//woi
          Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    child: EditText(
                      useIcon: true,
                      key: Key("CustomerId"),
                      controller: customerIdBlockedController,
                      focusNode: customerIdBlockedFocus,
                      validate: customerIdBlockedValid,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      textCapitalization: TextCapitalization.characters,
                      hintText: "Kode Pelanggan",
                      onSubmitted: (value) {
                        customerIdFocus.unfocus();
                        getBlockInfo();
                      },
                      onChanged: (value) {
                        setState(() {
                          resultBlocked = null;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Button(
                      loading: searchBlockedLoading,
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView("Cari", 3, color: Colors.white, caps: true),
                      onTap: () {
                        getBlockInfo();
                      },
                    ),
                  ),
                  blockInfoDetailWidgetList.length == 0
                  ? 
                  Container()
                  :
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          height: 60,
                          thickness: 4,
                          color: config.lighterGrayColor,
                        ),
                      ),
                      ListView(
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(0),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        children: blockInfoDetailWidgetList,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if(bottomNavigationBarList[i].label == "Password") {
        menuList.add(
          Center(
            child: SingleChildScrollView(
              reverse: true,
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: EditText(
                      useIcon: true,
                      key: Key("OldPassword"),
                      controller: oldPasswordController,
                      focusNode: oldPasswordFocus,
                      obscureText: unlockOldPassword,
                      validate: oldPasswordValid,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      hintText: "Password Lama",
                      alertMessage: oldPasswordErrorMessage,
                      suffixIcon:
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.remove_red_eye,
                            color:  unlockOldPassword ? config.lightGrayColor : config.grayColor,
                            size: 18,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            unlockOldPassword = !unlockOldPassword;
                          });
                        },
                      ),
                      onSubmitted: (value) {
                        _fieldFocusChange(context, oldPasswordFocus, newPasswordFocus);
                      },
                      onChanged: (value) {
                        
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: EditText(
                      useIcon: true,
                      key: Key("NewPassword"),
                      controller: newPasswordController,
                      focusNode: newPasswordFocus,
                      validate:  newPasswordValid,
                      obscureText: unlockNewPassword,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      hintText: "Password Baru",
                      alertMessage: newPasswordErrorMessage,
                      suffixIcon:
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.remove_red_eye,
                              color:  unlockNewPassword ? config.lightGrayColor : config.grayColor,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              unlockNewPassword = !unlockNewPassword;
                            });
                          },
                        ),
                      onSubmitted: (value) {
                        _fieldFocusChange(context, newPasswordFocus, confirmPasswordFocus);
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: EditText(
                      useIcon: true,
                      key: Key("ConfirmPassword"),
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocus,
                      validate: confirmPasswordValid,
                      keyboardType: TextInputType.text,
                      obscureText: unlockConfirmPassword,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      hintText: "Konfirmasi Password Baru",
                      alertMessage: confirmPasswordErrorMessage,
                      suffixIcon:
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.remove_red_eye,
                              color:  unlockConfirmPassword ? config.lightGrayColor : config.grayColor,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              unlockConfirmPassword = !unlockConfirmPassword;
                            });
                          },
                        ),
                      onSubmitted: (value) {
                        confirmPasswordFocus.unfocus();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Button(
                      loading: changePasswordLoading,
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView("UBAH", 3, color: Colors.white),
                      onTap: () {
                        submitValidation();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      }

    }

    return WillPopScope(
      onWillPop: willPopScope,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: currentIndex !=1 ?
        PreferredSize(
          preferredSize: Size.fromHeight(150),
          // preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * .20),
          child: AppBar(
            flexibleSpace: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextView("Selamat Datang, " + user_login.toUpperCase(), 3),
                        InkWell(
                          onTap: () {
                            Alert(
                              context: context,
                              title: "Konfirmasi,",
                              content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
                              cancel: true,
                              type: "warning",
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
                        },
                        child: Container(
                          child:Icon (Icons.logout, size: 30, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: TextView(dashboardTitle, 1)
                    ),
                  ],
                ),
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        )
        : null,
        body: menuList.length > 0 ?
        // Container(
        //   child: menuList[currentIndex],
        // ) : null,
        Container(
          // reverse: true,
          child: menuList[currentIndex], //disini
        ) : null,
        bottomNavigationBar: menuList.length > 0 ?
        BottomNavigationBar(
          selectedFontSize: 16,
          unselectedFontSize: 14,
          selectedIconTheme: IconThemeData(color: config.darkOpacityBlueColor),
          selectedItemColor: config.darkOpacityBlueColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedIconTheme: IconThemeData(color: config.grayColor),
          unselectedItemColor: config.grayColor,
          type: BottomNavigationBarType.fixed,  
          currentIndex: currentIndex,  
          onTap: _selectedTab,  
          elevation: 5,
          items: bottomNavigationBarList
        ) : null,
      )
    );
  }

  showBlockInfoDetail(Configuration config) {

    List<Widget> tempWidgetList = [];

    if(resultBlocked != null){
      final resultObject = jsonDecode(resultBlocked.data.toString());
      var blockedType;

      if(selectedRadio == -1){
        blockedType = resultObject[0]["blocked"];
        if(blockedType == 3) {
          blockedTypeSelected = "Blocked All";
          selectedRadio = 3;
        } else if(blockedType == 2) {
          blockedTypeSelected = "Blocked Invoice";
          selectedRadio = 2;
        } else if(blockedType == 1) {
          blockedTypeSelected = "Blocked Ship";
          selectedRadio = 1;
        } else {
          blockedTypeSelected = "Not Blocked";
          selectedRadio = 0;
        }
      } else {
        blockedType = selectedRadio;
        if(blockedType == 3) {
          blockedTypeSelected = "Blocked All";
        } else if(blockedType == 2) {
          blockedTypeSelected = "Blocked Invoice";
        } else if(blockedType == 1) {
          blockedTypeSelected = "Blocked Ship";
        } else {
          blockedTypeSelected = "Not Blocked";
        }
      }
      

      tempWidgetList.add(
        Container(
          child: Form(
            key: _ChangeBlockedStatusFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Kode Pelanggan",
                      hintText: resultObject[0]["No_"],
                      icon: Icon(Icons.bookmark, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Nama Pelanggan",
                      hintText: resultObject[0]["Name"],
                      icon: Icon(Icons.person, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Alamat Pelanggan",
                      hintText: resultObject[0]["Address"],
                      icon: Icon(Icons.location_on, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List<Widget>.generate(4, (int index) {
                                    var typeTitle = "";
                                    if(index == 0){
                                      typeTitle = "Not Blocked";
                                    } else if(index == 1){
                                      typeTitle = "Blocked Ship";
                                    } else if(index == 2){
                                      typeTitle = "Blocked Invoice";
                                    } else if(index == 3){
                                      typeTitle = "Blocked All";
                                    }
                                    return ListTile(
                                      title: Text('${typeTitle}'),
                                      leading: Radio(
                                        value: index,
                                        groupValue: selectedRadio,
                                        onChanged: (int value) {
                                          setState((){
                                            selectedRadio = value;
                                            blockedTypeSelected = typeTitle;
                                            Navigator.of(context, rootNavigator: true).pop();
                                          } );
                                        },
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          );
                        }
                      );
                    },
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Status Block",
                      hintText: blockedTypeSelected, //tanya ce elisa
                      icon: Icon(Icons.block, color: config.grayColor),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Button(
                      key: Key("submit"),
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView("UBAH", 3, caps: true,),
                      onTap: (){
                        blockedType != resultObject[0]["blocked"]
                        ?
                        Alert(
                          context: context,
                          title: "Konfirmasi,",
                          content: Text("Apakah Anda yakin ingin menyimpan data?"),
                          cancel: true,
                          type: "warning",
                          defaultAction: () {
                            updateBlock();
                          }
                        )
                        :
                        Alert(
                          context: context,
                          title: "Info,",
                          content: Text("Mohon untuk melakukan perubahan data terlebih dahulu"),
                          cancel: false,
                          type: "warning"
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      );
    }

    return tempWidgetList;
  }

  void updateBlock() async {
    setState(() {
      updateLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_login = sharedPreferences.getString('get_user_login');

    //http://192.168.10.213/dbrudie-2-0-0/updateBlock.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" , "block_lama" : 3, "block_baru" : 0}

    final resultObject = jsonDecode(resultBlocked.data.toString());
    var block_lama = resultObject[0]["blocked"];
    var block_baru = selectedRadio;

    final userCodeData = encryptData(user_login);
    final kodeCustomerData = encryptData(customerIdBlockedController.text);
    final blockLamaData = encryptData(block_lama);
    final blockBaruData = encryptData(block_baru.toString());

    Result result_ = await customerAPI.updateBlock(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData","block_lama":$blockLamaData,"block_baru":$blockBaruData}');

    Navigator.of(context).pop();

    if(result_.success == 1){
      Alert(
        context: context,
        title: "Terima kasih,",
        content: Text(result_.message),
        cancel: false,
        type: "success",
        defaultAction: (){
          setState(() {
            customerIdBlockedController.clear();
            resultBlocked = null;
          });
        }
      );
    } else{
      Alert(
        context: context,
        title: "Maaf,",
        content: Text(result_.message),
        cancel: false,
        type: "error"
      );
    }
    setState(() {
      updateLoading = false;
    });

  }

  void getLimitCorporate({String customerCorporateId=""}) async {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchLoading = true;
      });

      //var obj = {"kode_customerc": $$('#corporate_code').val(),"corporate_name":$$('#corporate_name').val(), "limit_baru": limit_baru.replace(/\./g,''), "user_code": localStorage.getItem('user_code'), "old_limit": localStorage.getItem('old_limitc')};

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences;
      _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      Result result_;
      if(customerCorporateId != "") {
        final userCodeData = encryptData(user_code);
        final kodeCustomerData = encryptData(customerCorporateId);

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
      } else {
        final userCodeData = encryptData(user_code);
        final kodeCustomerData = encryptData(customerIdController.text);

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');
      }

      Navigator.of(context).pop();

      if(result_.success == 1){
        setState(() {
          resultLimit = result_;
          customerIdController.clear();
        });

        Navigator.pushNamed(
          context,
          "addLimitCorporateDetail",
          arguments: resultLimit
        );
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error"
        );
        setState(() {
          resultLimit = null;
        });
      }

      setState(() {
        searchLoading = false;
      });

    } else {
      setState(() {
        resultLimit = null;
      });
    }

  }

  void getLimit() async {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchLoading = true;
      });

      //http://192.168.10.213/dbrudie-2-0-0/getLimit.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" }

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences;
      _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      final kodeCustomerData = encryptData(customerIdController.text);
      final userCodeData = encryptData(user_code);

      Result result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        setState(() {
          resultLimit = result_;
          customerIdController.clear();
        });

        Navigator.pushNamed(
          context,
          "addLimitDetail",
          arguments: resultLimit,
        );

        // showBlockInfoDetail(config);
      } else {
        if(result_.message.toLowerCase().contains("corporate")) {
          Alert(
            context: context,
            title: "Info,",
            content: Text(result_.message),
            cancel: false,
            type: "warning",
            actions: [
              Button(
                key: Key("detail"),
                child: TextView("Detail Limit", 2, size: 12, caps: false, color: Colors.white),
                fill: false,
                onTap: () async {
                  Navigator.of(context).pop();

                  Alert(context: context, loading: true, disableBackButton: true);

                  final userCodeData = encryptData(user_code);
                  final kodeCustomerData = encryptData(customerIdController.text);

                  Result detailResult = await customerAPI.getLimit(context, parameter: 'json={"guest_mode":"true","kode_customer":"$kodeCustomerData","user_code":"$userCodeData"}');

                  Navigator.of(context).pop();

                  if(detailResult.success == 1){
                    setState(() {
                      resultLimit = detailResult;
                      customerIdController.clear();
                    });

                    Navigator.pushNamed(
                      context,
                      "guestAddLimitDetail",
                      arguments: resultLimit,
                    );
                  }
                },
              ),
              Button(
                key: Key("ok"),
                child: TextView("Lanjutkan", 2, size: 12, caps: false, color: Colors.white),
                fill: false,
                onTap: () {
                  Navigator.of(context).pop();
                  getLimitCorporate(customerCorporateId: result_.data);
                },
              )
            ],
          );

        } else {
          Alert(
            context: context,
            title: "Maaf,",
            content: Text(result_.message),
            cancel: false,
            type: "error"
          );
        }
        setState(() {
          resultLimit = null;
        });
      }

      setState(() {
        searchLoading = false;
      });

    } else {
      setState(() {
        resultLimit = null;
      });
    }

  }

  void getBlockInfo() async {
    setState(() {
      customerIdBlockedController.text.isEmpty ? customerIdBlockedValid = true : customerIdBlockedValid = false;
    });

    if(!customerIdBlockedValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchBlockedLoading = true;
      });

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_login = sharedPreferences.getString('get_user_login');

      final kodeCustomerData = encryptData(customerIdBlockedController.text);
      final userLoginData = encryptData(user_login);

      Result result_ = await customerAPI.getBlockInfo(context, parameter: 'json={"kode_customer":"$kodeCustomerData","user_code":"$userLoginData"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        // final products = jsonDecode(result.data.toString());
        // products[0]["Name"]

        setState(() {
          resultBlocked = result_;
          selectedRadio = -1;
        });
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error"
        );
        setState(() {
          resultBlocked = null;
        });
      }

      setState(() {
        searchBlockedLoading = false;
      });

    } else {
      setState(() {
        resultBlocked = null;
      });
    }
  }

  void submitValidation() {

    setState(() {

      if(oldPasswordController.text.isEmpty){
        oldPasswordValid = true;
        oldPasswordErrorMessage = "tidak boleh kosong";
      } else {
        oldPasswordValid = false;
      }

      if(newPasswordController.text.isEmpty){
        newPasswordValid = true;
        newPasswordErrorMessage = "tidak boleh kosong";
      } else {
        newPasswordValid = false;
      }

      if(confirmPasswordController.text.isEmpty){
        confirmPasswordValid = true;
        confirmPasswordErrorMessage = "tidak boleh kosong";
      } else {
        confirmPasswordValid = false;
      }

      if(oldPasswordController.text.isEmpty){
        oldPasswordValid = true;
        oldPasswordErrorMessage = "tidak boleh kosong";
      } else {
        oldPasswordValid = false;
      }

      if (newPasswordController.text != confirmPasswordController.text){
        newPasswordValid = true;
        confirmPasswordValid = true;

        newPasswordErrorMessage = "tidak sama dengan Konfirmasi Password Baru";
        confirmPasswordErrorMessage = "tidak sama dengan Password Baru";

      }

    });

    if(!oldPasswordValid && !newPasswordValid && !confirmPasswordValid){
      Alert(
        context: context,
        title: "Konfirmasi,",
        content: Text("Apakah Anda yakin ingin mengubah password?"),
        cancel: true,
        type: "warning",
        defaultAction: () async {
          doChangePassword();
      });
      
      
    }

  }
  
  void doChangePassword() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      changePasswordLoading = true;
    });
    

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userCodeData = encryptData(prefs.getString('user_code'));
    final oldPasswordData = encryptData(oldPasswordController.text);

    String getOldPassword = await userAPI.getPassword(context, parameter: 'user_code=$userCodeData&old_pass=$oldPasswordData');

    Navigator.of(context).pop();

    if(getOldPassword == "OK"){

      final newPasswordData = encryptData(newPasswordController.text);
      final usercodeData = encryptData(prefs.getString('user_code'));

      String getChangePassword = await userAPI.changePassword(context, parameter: 'json={"new_pass":"$newPasswordData","user_code":"$usercodeData"}');


      if(getChangePassword == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Password berhasil diubah, silahkan lakukan login ulang"),
          cancel: false,
          type: "success",
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
              await FirebaseMessaging.instance.deleteToken();
              await prefs.clear();
              Navigator.pushReplacementNamed(
                context,
                "login",
              );
            // if (mounted) {
            //   SharedPreferences prefs = await SharedPreferences.getInstance();
            //   await prefs.remove("limit_dmd");
            //   await prefs.remove("request_limit");
            //   await prefs.remove("user_code_request");
            //   await prefs.remove("user_code");
            //   await prefs.remove("max_limit");
            //   await prefs.clear();
            //   Navigator.pushReplacementNamed(
            //     context,
            //     "login",
            //   );
            // }
          } 
        );
        
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(getChangePassword),
          cancel: false,
          type: "error"
        );
      }

      setState(() {
        changePasswordLoading = false;
      });

    } else {
      Alert(
          context: context,
          title: "Maaf,",
          content: Text(getOldPassword),
          cancel: false,
          type: "error"
        );
    }

    setState(() {
      changePasswordLoading = false;
    });
    

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
      // return Future.value(false);
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    return Future.value(false);
  }

  void showAlert({
      context, String title, Widget content, List<Widget> actions, VoidCallback defaultAction,
      bool cancel = true, String type = "warning", bool showIcon = true, bool disableBackButton = false,
      VoidCallback willPopAction, loading = false, double value, String errorBtnTitle = "Ok"
    }) {

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
      
      isAlertShowing = true;
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
                    isAlertShowing = false;
                    Navigator.of(context).pop();
                  },
                ) : Container(),
                Button(
                  key: Key("ok"),
                  child: cancel ? TextView("Ya", 2, size: 12, caps: false, color: Colors.white) : type == "error" ? TextView(errorBtnTitle, 2, size: 12, caps: false, color: Colors.white) : TextView("Ok", 2, size: 12, caps: false, color: Colors.white),
                  fill: true,
                  onTap: () {
                    isAlertShowing = false;
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
          );
        }
      );
    }

  }

}