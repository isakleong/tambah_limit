import 'dart:async';
import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/customerModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/screens/addLimit.dart';
import 'package:tambah_limit/screens/addLimitCorporate.dart';
import 'package:tambah_limit/screens/changeBlockedStatus.dart';
import 'package:tambah_limit/screens/historyLimitRequest.dart';
import 'package:tambah_limit/screens/profile.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/bottombarAdapter.dart';
import 'package:tambah_limit/widgets/bottomBarLayout.dart';
import 'package:tambah_limit/widgets/bottombarWithIcon.dart';
import 'package:tambah_limit/widgets/bottomBarLayout.dart';

import 'package:tambah_limit/widgets/button.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

enum CustomerBlockedType { NotBlocked, BlockedShip, BlockedInvoice, BlockedAll }  

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {

  String user_login = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "snackBar");

  DateTime currentBackPressTime;

  final _ChangeBlockedStatusFormKey = GlobalKey<FormState>();

  CustomerBlockedType customerBlockedType = CustomerBlockedType.NotBlocked;

  Result result;
  
  String _lastSelected = 'TAB: 0';
  List<Color> backgroundActiveColor = [ config.grayColor, config.grayColor, config.grayColor ];
  String dashboardTitle = "Blok Pelanggan";
  int currentIndex = 0;

  String blockedTypeSelected = "";
  int selectedRadio = -1;

  bool customerIdValid = false;
  bool searchLoading = false;
  bool updateLoading = false;

  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();

  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);

  final btnTitle = [ "Tambah Limit", "Tambah Limit Corporate", "Riwayat Permintaan Limit" ];

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

  void _selectedTab(int index) {
    setState(() {
      if(index == 0){
        dashboardTitle = "Blok Pelanggan";
      } else if(index == 1) {
        dashboardTitle = "Ubah Password";
      }
      _lastSelected = 'TAB: $index';
      currentIndex = index;
    });
  }

  void _selectedFab(int index) {
    setState(() {
      if(index == 0) {
        // dashboardTitle = "Tambah Limit";
        Navigator.popAndPushNamed(
            context,
            "addLimit"
        );
      } else if(index == 1) {
        dashboardTitle = "Tambah Limit Corporate";
      } else if(index == 2) {
        dashboardTitle = "Riwayat Permintaan Limit";
      }
      _lastSelected = 'FAB: $index';
      // currentIndex = index+2;
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

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/4",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/1",
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

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/5",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/2",
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

            result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
            
            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();
            
            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/6",
              arguments: result_,
            );
          } else {
            Alert(context: context, loading: true, disableBackButton: true);

            result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

            final SharedPreferences sharedPreferences = await _sharedPreferences;
            await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
            await sharedPreferences.setString("user_code_request", message.data['user_code']);

            Navigator.of(context).pop();

            Navigator.pushNamed(
              context,
              "historyLimitRequestDetail/${message.data['id']}/3",
              arguments: result_,
            );
          }
        }
      }
  }

  @override
  void initState() {
    _bottomBarController.itemsStream.listen((i) {
      setState(() {
        currentIndex = i;
        if(i == 0){
          dashboardTitle = "Blok Pelanggan";
        } else if(i == 1) {
          dashboardTitle = "Ubah Password";
        }
      });
    });

    // initializeNotification();

    //handling onbackground notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      Result result_;

      if (message.data['body'].toString().toLowerCase().contains("terdapat request tambah limit")) {
      
      if(config.isAppLive == false){
        while(config.isScreenAtDashboard == false){
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      if(message.data['customer_code'].toString().length > 11) {
        Alert(context: context, loading: true, disableBackButton: true);

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
        
        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();
        
        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/4",
          arguments: result_,
        );
      } else {
        Alert(context: context, loading: true, disableBackButton: true);

        result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();

        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/1",
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

        result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
        
        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();
        
        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/5",
          arguments: result_,
        );
      } else {
        Alert(context: context, loading: true, disableBackButton: true);
        printHelp("cek masuk sini ");

        result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

        final SharedPreferences sharedPreferences = await _sharedPreferences;
        await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
        await sharedPreferences.setString("user_code_request", message.data['user_code']);

        Navigator.of(context).pop();

        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${message.data['id']}/2",
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

          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
          
          final SharedPreferences sharedPreferences = await _sharedPreferences;
          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
          await sharedPreferences.setString("user_code_request", message.data['user_code']);

          Navigator.of(context).pop();
          
          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${message.data['id']}/6",
            arguments: result_,
          );
        } else {
          Alert(context: context, loading: true, disableBackButton: true);

          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

          final SharedPreferences sharedPreferences = await _sharedPreferences;
          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
          await sharedPreferences.setString("user_code_request", message.data['user_code']);

          Navigator.of(context).pop();

          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${message.data['id']}/3",
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
                          
                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
                          
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
                          Alert(context: context, loading: true, disableBackButton: true);

                          printHelp("message cust code "+message.data['customer_code']);
                          printHelp("message user code "+message.data['user_code']);
                          printHelp("message limit "+message.data['limit']);

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
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
                          
                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
                          
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

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
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
                          
                          result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');
                          
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

                          result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${message.data['customer_code']}","user_code":"${message.data['user_code']}"}');

                          final SharedPreferences sharedPreferences = await _sharedPreferences;
                          await sharedPreferences.setInt("request_limit", int.parse(message.data['limit']));
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
    
    super.initState();
    
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    config.isScreenAtDashboard = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_login = prefs.getString("get_user_login");  
    });
    
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> blockInfoDetailWidgetList = showBlockInfoDetail(config);

    final List<Widget> menuList = [
      Column(
        children: [
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
              hintText: "Kode Pelanggan",
              onSubmitted: (value) {
                customerIdFocus.unfocus();
                getBlockInfo();
              },
              onChanged: (value) {
                setState(() {
                  result = null;
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
              child: TextView("CARI", 3, color: Colors.white),
              onTap: () {
                getBlockInfo();
              },
            ),
          ),
          blockInfoDetailWidgetList.length == 0
          ? 
          Container()
          :
          ListView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(0),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: blockInfoDetailWidgetList,
          ),
        ],
      ),
      Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
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
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
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
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
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
      )


      // Profile(),
      
    ].where((c) => c != null).toList();

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: TextView(dashboardTitle, 1),
      //   automaticallyImplyLeading: false,
      //   actions: [
          // InkWell(
          //   onTap: () {
          //     Alert(
          //       context: context,
          //       title: "Konfirmasi,",
          //       content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          //       cancel: true,
          //       type: "warning",
          //       defaultAction: () async {
          //         SharedPreferences prefs = await SharedPreferences.getInstance();
          //         await prefs.remove("limit_dmd");
          //         await prefs.remove("request_limit");
          //         await prefs.remove("user_code_request");
          //         await prefs.remove("user_code");
          //         await prefs.remove("max_limit");
          //         await prefs.remove("fcmToken");
          //         await FirebaseMessaging.instance.deleteToken();
          //         await prefs.clear();
          //         Navigator.pushReplacementNamed(
          //           context,
          //           "login",
          //         );
          //     });
              
          //   },
          //   child: Container(
          //     margin: EdgeInsets.only(right: 10),
          //     child:Icon (Icons.logout, size: 28),
          //   ),
          // ),
          
      //   ],
      // ),
      body: WillPopScope(
        onWillPop: willPopScope,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                title: TextView(dashboardTitle, 3),
                centerTitle: true,
              ),
              title: Container(
                child: Row(
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
                      child:Icon (Icons.logout, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: Container(
            //     child: menuList[currentIndex]
            //   ),
            // ),

            // SliverList(
            //   delegate: SliverChildBuilderDelegate(
            //     (BuildContext context, int index) {
            //       return Container(
            //         child: menuList[currentIndex]
            //       );
            //     },
            //   ),
            // ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: menuList[currentIndex]
                );
              },  
              childCount: 1),
            ),

          ]
        ),
      ),
      bottomNavigationBar: BottomBarWithSheet(
        controller: _bottomBarController,
        autoClose: false,
        bottomBarTheme: BottomBarTheme(
          mainButtonPosition: MainButtonPosition.middle,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          heightOpened: 350,
          itemIconColor: config.grayColor,
          selectedItemIconColor: config.darkOpacityBlueColor,
          itemTextStyle: TextStyle(
            color: config.grayColor,
            fontSize: 12,
            fontFamily: "WorkSans"
          ),
          selectedItemTextStyle: TextStyle(
            color: config.darkOpacityBlueColor,
            fontSize: 14,
            fontFamily: "WorkSans"
          ),
        ),
        mainActionButtonTheme: MainActionButtonTheme(
          size: 60,
          color: config.darkOpacityBlueColor,
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
        onSelectItem: (index) {
          printHelp("get index "+index.toString());
          setState(() {
            if(index == 0){
              dashboardTitle = "Blok Pelanggan";
            } else if(index == 1) {
              dashboardTitle = "Ubah Password";
            }  
          });
          
        },
        sheetChild: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [                
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Button(
                    backgroundColor: config.darkOpacityBlueColor,
                    child: TextView("Tambah Limit", 3, color: Colors.white),
                    onTap: () {
                      _bottomBarController.toggleSheet();
                      setState(() {
                        customerIdController.text = "";
                        result = null;
                      });
                      Navigator.pushNamed(
                          context,
                          "addLimit"
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Button(
                    backgroundColor: config.darkOpacityBlueColor,
                    child: TextView("Tambah Limit Corporate", 3, color: Colors.white),
                    onTap: () {
                      _bottomBarController.toggleSheet();
                      setState(() {
                        customerIdController.text = "";
                        result = null;
                      });
                      Navigator.pushNamed(
                          context,
                          "addLimitCorporate"
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Button(
                    backgroundColor: config.darkOpacityBlueColor,
                    child: TextView("Riwayat Permintaan Limit", 3, color: Colors.white),
                    onTap: () {
                      _bottomBarController.toggleSheet();
                      Navigator.pushNamed(
                          context,
                          "historyLimitRequest"
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        items: [
          BottomBarWithSheetItem(icon: Icons.not_interested, label: "Status Blocked"),
          BottomBarWithSheetItem(icon: Icons.password, label: "Ubah Password"),
        ],
      )
      
      
      // FABBottomAppBar(
      //   centerItemText: '',
      //   color: config.grayColor,
      //   selectedColor: config.darkerBlueColor,
      //   notchedShape: CircularNotchedRectangle(),
      //   onTabSelected: _selectedTab,
      //   items: [
      //     FABBottomAppBarItem(iconData: Icons.not_interested, text: 'Status Block'),
      //     FABBottomAppBarItem(iconData: Icons.password, text: 'Ubah Password'),
      //   ],
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: _buildFab(
      //     context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showBlockInfoDetail(Configuration config) {

    List<Widget> tempWidgetList = [];

    if(result != null){
      final resultObject = jsonDecode(result.data.toString());
      var blockedType;
      
      // printHelp(resultObject[0]["blocked"]);
      // resultObject[0]["Name"];

      // String blockedTypeSelected = "coba";
      // var blockedType = resultObject[0]["blocked"];

      if(selectedRadio == -1){
        blockedType = resultObject[0]["blocked"];
        // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : blockedType == 2 ? "Blocked Invoice" : ""; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
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
        // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : "Blocked Invoice"; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
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
          margin: EdgeInsets.only(top:30),
          child: Form(
            key: _ChangeBlockedStatusFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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

  Widget _buildFab(BuildContext context) {
    final btnTitle = [ "Tambah Limit", "Tambah Limit Corporate", "Riwayat Permintaan Limit" ];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - btnTitle.length * 35.0),
          child: FabWithIcons(
            // backgroundColorActive: backgroundActiveColor,
            btnTitle: btnTitle,
            onIconTapped: _selectedFab,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () { printHelp("coba ya"); },
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }

  void updateBlock() async {
    setState(() {
      updateLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_code = sharedPreferences.getString('user_code');

    //http://192.168.10.213/dbrudie-2-0-0/updateBlock.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" , "block_lama" : 3, "block_baru" : 0}

    final resultObject = jsonDecode(result.data.toString());
    var block_lama = resultObject[0]["blocked"];
    var block_baru = selectedRadio;

    Result result_ = await customerAPI.updateBlock(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}","block_lama":${block_lama},"block_baru":${block_baru}}');

    Navigator.of(context).pop();

    if(result.success == 1){
      Alert(
        context: context,
        title: "Terima kasih,",
        content: Text(result_.message),
        cancel: false,
        type: "success"
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

  void getBlockInfo() async {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchLoading = true;
      });

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      Result result_ = await customerAPI.getBlockInfo(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        // final products = jsonDecode(result.data.toString());
        // products[0]["Name"]

        setState(() {
          result = result_;
          selectedRadio = -1;
        });

        // showBlockInfoDetail(config);
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error"
        );
        setState(() {
          result = null;
        });
      }

      setState(() {
        searchLoading = false;
      });

    } else {
      setState(() {
        result = null;
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

    String getOldPassword = await userAPI.getPassword(context, parameter: 'user_code=${prefs.getString('user_code')}&old_pass=${oldPasswordController.text}');

    Navigator.of(context).pop();

    if(getOldPassword == "OK"){

      String getChangePassword = await userAPI.changePassword(context, parameter: 'json={"new_pass":"${newPasswordController.text}","user_code":"${prefs.getString('user_code')}"}');

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
    // Navigator.popAndPushNamed(
    //       context,
    //       "login"
    //   );
    return Future.value(false);
  }

  // Future<bool> willPopScope() async{
  //   if (isExit == false) {
  //     isExit = true;
  //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //   content: Text("Tekan sekali lagi untuk keluar dari aplikasi", textAlign: TextAlign.center),
  //     // ));
  //     _scaffoldKey.currentState.showSnackBar(
  //         SnackBar(
  //           duration: Duration(seconds:1),
  //           content: Text("Tekan sekali lagi untuk keluar dari aplikasi"),
  //         )
  //       );
  //   } else if (isExit) {
  //     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //   }
  //   return false;
  // }

  Future<Null> refresh() async {
    // setState(() {
    //   dashboardListLoading = true;
    // });

    // initDashboardList();
    // await checkUser();
    
    // return null;
  }

}